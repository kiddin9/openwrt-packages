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

#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <syslog.h>
#include <fcntl.h>
#include <sys/resource.h>
#include <limits.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <linux/limits.h>

#include "daemonize.h"
extern void log2file(const char *fmt, ...);

void daemonize(const char *cmd)
{
    int i, fd0, fd1, fd2;
    pid_t pid;
    struct rlimit rl;
    struct sigaction sa;

    /*
     * Clear file creation mask.
     */
    umask(0);

    /*
     * Get maximum number of file descriptors.
     */
    if (getrlimit(RLIMIT_NOFILE, &rl) < 0) {
        log2file("%s: can't get file limit\n", cmd);
        exit(1);
    }

    /*
     * Become a session leader to lose controlling TTY.
     */
    if ((pid = fork()) < 0) {
        log2file("%s: can't fork\n", cmd);
        exit(1);
    } else if (pid != 0) /* parent */ {
        exit(0);
    }
    
    setsid();

    /*
     * Ensure future opens won't allocate controlling TTYs.
     */
    sa.sa_handler = SIG_IGN;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGHUP, &sa, NULL) < 0) {
        log2file("%s: can't ignore SIGHUP\n");
        exit(1);
    }
    
    if ((pid = fork()) < 0) {
        log2file("%s: can't fork\n", cmd);
        exit(1);
    } else if (pid != 0) /* parent */ {
        exit(0);
    }

    /*
     * Change the current working directory to the root so
     * we won't prevent file systems from being unmounted.
     */
    if (chdir("/") < 0) {
        log2file("%s: can't change directory to /\n");
        exit(1);
    }

    /*
     * Close all open file descriptors.
     */
    if (rl.rlim_max == RLIM_INFINITY) {
        rl.rlim_max = 1024;
    }
    
    for (i = 0; (unsigned int)i < rl.rlim_max; i++) {
        close(i);
    }

    /*
     * Attach file descriptors 0, 1, and 2 to /dev/null.
     */
    fd0 = open("/dev/null", O_RDWR);
    fd1 = dup(0);
    fd2 = dup(0);

    /*
     * Initialize the log file.
     */
    openlog(cmd, LOG_CONS, LOG_DAEMON);
    if (fd0 != 0 || fd1 != 1 || fd2 != 2) {
        log2file("unexpected file descriptors %d %d %d\n",
                fd0, fd1, fd2);
        exit(1);
    }
}


#define LOCKMODE (S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH)

int lockfile(int fd)
{
    struct flock fl;

    fl.l_type = F_WRLCK;
    fl.l_start = 0;
    fl.l_whence = SEEK_SET;
    fl.l_len = 0;
    return(fcntl(fd, F_SETLK, &fl));
}

int isAlreadyRunning()
{
   int fd;
   char buf[16];

   fd = open(LOCKFILE, O_RDWR|O_CREAT, LOCKMODE);
   if (fd < 0) {
       log2file("can't open %s: %s\n", LOCKFILE, strerror(errno));
       exit(1);
   }

   if (lockfile(fd) < 0){
       if (errno == EACCES || errno == EAGAIN) {
           close(fd);
           return(1);
       }
       log2file("can't lock %s: %s\n", LOCKFILE, strerror(errno));
       exit(1);
   }
   ftruncate(fd, 0);
   sprintf(buf, "%ld", (long)getpid());
   write(fd, buf, strlen(buf)+1);
   return (0);
}

