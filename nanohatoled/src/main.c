/*
NanoHat OLED example
http://wiki.friendlyarm.com/wiki/index.php/NanoHat_OLED
*/

/*
The MIT License (MIT)
Copyright (C) 2017 FriendlyELEC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/epoll.h>
#include <sys/types.h>
#include <signal.h>
#include <time.h>  
#include <pthread.h>
#include <dirent.h>
#include <stdarg.h>
#include <linux/limits.h>
#include "daemonize.h"

//{{ daemon
static int _debug = 1;
#define LOG_FILE_NAME "/tmp/nanohat-oled.log"
static void _log2file(const char* fmt, va_list vl)
{
        FILE* file_out;
        file_out = fopen(LOG_FILE_NAME,"a+");
        if (file_out == NULL) {
                return;
        }
        vfprintf(file_out, fmt, vl);
        fclose(file_out);
}
void log2file(const char *fmt, ...)
{
        if (_debug) {
                va_list vl;
                va_start(vl, fmt);
                _log2file(fmt, vl);
                va_end(vl);
        }
}
//}}

const char* python_file = "bakebit_nanohat_oled.py";
static int get_work_path(char* buff, int maxlen) {
    ssize_t len = readlink("/proc/self/exe", buff, maxlen);
    if (len == -1 || len == maxlen) {                         
        return -1;                                            
    }                                
    buff[len] = '\0';
                        
    char *pos = strrchr(buff, '/');
    if (pos != 0) {                   
       *pos = '\0';                   
    }              
                   
    return 0;
}            
static char workpath[255];
static int py_pids[128];
static int pid_count = 0;
extern int find_pid_by_name( char* ProcName, int* foundpid);
void send_signal_to_python_process(int signal) {
    int i, rv;
    if (pid_count == 0) {
        rv = find_pid_by_name( "python3.x", py_pids);
        for(i=0; py_pids[i] != 0; i++) {
            log2file("found python pid: %d\n", py_pids[i]);
            pid_count++;
        }
    }
    if (pid_count > 0) {
        for(i=0; i<pid_count; i++) {
            if (kill(py_pids[i], signal) != 0) { //maybe pid is invalid
                pid_count = 0;
                break;
            }
        }
    }
}

pthread_t view_thread_id = 0;
void* threadfunc(char* arg) {
    pthread_detach(pthread_self());
    if (arg) {
        char* cmd = arg;
        system(cmd);
        free(arg);
    }
}

int load_python_view() {
    int ret;
    char* cmd = (char*)malloc(255);
    sprintf(cmd, "cd %s && python3 %s 2>&1 | tee /tmp/nanoled-python.log", workpath, python_file);
    ret = pthread_create(&view_thread_id, NULL, (void*)threadfunc,cmd);
    if(ret) {
        log2file("create pthread error \n");
        return 1;
    }
    return 0;
}

int find_pid_by_name( char* ProcName, int* foundpid) {
    DIR             *dir;
    struct dirent   *d;
    int             pid, i;
    char            *s;
    int pnlen;

    i = 0;
    foundpid[0] = 0;
    pnlen = strlen(ProcName);

    /* Open the /proc directory. */
    dir = opendir("/proc");
    if (!dir)
    {
        log2file("cannot open /proc");
        return -1;
    }

    /* Walk through the directory. */
    while ((d = readdir(dir)) != NULL) {

        char exe [PATH_MAX+1];
        char path[PATH_MAX+1];
        int len;
        int namelen;

        /* See if this is a process */
        if ((pid = atoi(d->d_name)) == 0)       continue;

        snprintf(exe, sizeof(exe), "/proc/%s/exe", d->d_name);
        if ((len = readlink(exe, path, PATH_MAX)) < 0)
            continue;
        path[len] = '\0';

        /* Find ProcName */
        s = strrchr(path, '/');
        if(s == NULL) continue;
        s++;

        /* we don't need small name len */
        namelen = strlen(s);
        if(namelen < pnlen)     continue;

        if(!strncmp(ProcName, s, pnlen)) {
            /* to avoid subname like search proc tao but proc taolinke matched */
            if(s[pnlen] == ' ' || s[pnlen] == '\0') {
                foundpid[i] = pid;
                i++;
            }
        }
    }
    foundpid[i] = 0;
    closedir(dir);
    return  0;
}

int init_gpio(int gpio, char* edge) {
    char path[42];
    FILE *fp;
    int fd;

    // export gpio to userspace
    fp = fopen("/sys/class/gpio/export", "w");
    if (fp) {
        fprintf(fp, "%d\n", gpio);
        fclose(fp);
    }

    // set output direction
    sprintf(path, "/sys/class/gpio/gpio%d/direction", gpio);
    fp = fopen(path, "w");
    if (fp) {
        fprintf(fp, "%s\n", "in");
        fclose(fp);
    }

    // falling edge
    sprintf(path, "/sys/class/gpio/gpio%d/edge", gpio);
    fp = fopen(path, "w");
    if (fp) {
        fprintf(fp, "%s\n", edge);
        fclose(fp);
    }

    sprintf(path, "/sys/class/gpio/gpio%d/value", gpio);
    fd = open(path, O_RDWR | O_NONBLOCK);
    if (fd < 0) {
        log2file("open of gpio %d returned %d: %s\n",
                gpio, fd, strerror(errno));
    }

    return fd;
}

void release_gpio(int gpio) {
    FILE* fp = fopen("/sys/class/gpio/unexport", "w");
    if (fp) {
        fprintf(fp, "%d\n", gpio);
        fclose(fp);
    }
}

static int gpio_d0=0, gpio_d1=2, gpio_d2=3;
static int epfd=-1;
static int fd_d0=-1, fd_d1=-1, fd_d2=-1;
void sig_handler( int sig)
{
    if(sig == SIGINT){
        if (epfd>=0) {
            close(epfd);
        }
        if (fd_d0>=0) {
            close(fd_d0);
            release_gpio(gpio_d0);
        }
        if (fd_d1>=0) {
            close(fd_d1);
            release_gpio(gpio_d1);
        }
        if (fd_d2>=0) {
            close(fd_d2);
            release_gpio(gpio_d2);
        }
        log2file("ctrl+c has been keydownd\n");
        exit(0);
    }
}

int main(int argc, char** argv) {
    struct epoll_event ev_d0, ev_d1, ev_d2;
    struct epoll_event events[10];
    unsigned int value = 0;
    unsigned int k1 = 0,k2 = 0,k3 = 0;
    int i, n;
    char ch;

    if (isAlreadyRunning() == 1) {
        exit(3);
    }
    daemonize( "nanohat-oled" );

    int ret = get_work_path(workpath, sizeof(workpath));
    if (ret != 0) {
        log2file("get_work_path ret error\n");
        return 1;
    }
    sleep(3);

    epfd = epoll_create(1);
    if (epfd < 0) {
        log2file("error creating epoll\n");
        return 1;
    }

    fd_d0 = init_gpio(gpio_d0, "rising");
    if (fd_d0 < 0) {
        log2file("error opening gpio sysfs entries\n");
        return 1;
    }

    fd_d1 = init_gpio(gpio_d1, "rising");
    if (fd_d1  < 0) {
        log2file("error opening gpio sysfs entries\n");
        return 1;
    }

    fd_d2 = init_gpio(gpio_d2, "rising");
    if (fd_d2 < 0) {
        log2file("error opening gpio sysfs entries\n");
        return 1;
    }

    ev_d0.events = EPOLLET;
    ev_d1.events = EPOLLET;
    ev_d2.events = EPOLLET;
    ev_d0.data.fd = fd_d0;
    ev_d1.data.fd = fd_d1;
    ev_d2.data.fd = fd_d2;

    n = epoll_ctl(epfd, EPOLL_CTL_ADD, fd_d0, &ev_d0);
    if (n != 0) {
        log2file("epoll_ctl returned %d: %s\n", n, strerror(errno));
        return 1;
    }

    n = epoll_ctl(epfd, EPOLL_CTL_ADD, fd_d1, &ev_d1);
    if (n != 0) {
        log2file("epoll_ctl returned %d: %s\n", n, strerror(errno));
        return 1;
    }

    n = epoll_ctl(epfd, EPOLL_CTL_ADD, fd_d2, &ev_d2);
    if (n != 0) {
        log2file("epoll_ctl returned %d: %s\n", n, strerror(errno));
        return 1;
    }

    load_python_view();
    while (1) {
        n = epoll_wait(epfd, events, 10, 15);

        for (i = 0; i < n; ++i) {
            if (events[i].data.fd == ev_d0.data.fd) {
                lseek(fd_d0, 0, SEEK_SET);
                if (read(fd_d0, &ch, 1)>0) {
                    log2file("k1 events: %c\n", ch);

                    if (ch == '1') {
                        send_signal_to_python_process(SIGUSR1);
                    }
                }
            } else if (events[i].data.fd == ev_d1.data.fd) {
                lseek(fd_d1, 0, SEEK_SET);
                if (read(fd_d1, &ch, 1)>0) {
                    log2file("k2 events: %c\n", ch);

                    if (ch == '1') {
                        send_signal_to_python_process(SIGUSR2);
                    }
                }
            } else if (events[i].data.fd == ev_d2.data.fd) {
                lseek(fd_d2, 0, SEEK_SET);
                if (read(fd_d2, &ch, 1)>0) {
                    log2file("k3 events: %c\n", ch);
                    if (ch == '1') {
                        send_signal_to_python_process(SIGALRM);
                    }
                }
            }
        }
    }

    return 0;
}

