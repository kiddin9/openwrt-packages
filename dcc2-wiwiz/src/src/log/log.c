/*
 * MIT License
 *
 * Copyright (c) 2021 Jianhui Zhao <zhaojh329@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <time.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#include "log.h"

int __log_level__ = LOG_ERR;
static const char *ident;

void (*log_write)(int priority, const char *fmt, va_list ap);

static const char *prioritynames[] = {
    [LOG_EMERG] = "emerg",
    [LOG_ALERT] = "alert",
    [LOG_CRIT] = "crit",
    [LOG_ERR] = "err",
    [LOG_WARNING] = "warn",
    [LOG_NOTICE] = "notice",
    [LOG_INFO] = "info",
    [LOG_DEBUG] = "debug"
};

void log_level(int level)
{
    __log_level__ = level;
}

void ___log(const char *filename, int line, int priority, const char *fmt, ...)
{
    char new_fmt[256];
    va_list ap;

    priority = LOG_PRI(priority);

    if (priority > __log_level__)
        return;

    snprintf(new_fmt, sizeof(new_fmt), "(%s:%d) %s", filename, line, fmt);

    va_start(ap, fmt);
    log_write(priority, new_fmt, ap);
    va_end(ap);
}

static inline void log_to_stdout(int priority, const char *fmt, va_list ap)
{
    time_t now;
    struct tm tm;
    char buf[32];

    now = time(NULL);
    localtime_r(&now, &tm);
    strftime(buf, sizeof(buf), "%Y/%m/%d %H:%M:%S", &tm);

    fprintf(stderr, "%s %s ", buf, prioritynames[priority]);
    vfprintf(stderr, fmt, ap);
}

static inline void log_to_syslog(int priority, const char *fmt, va_list ap)
{
    vsyslog(priority, fmt, ap);
}

static void __attribute__((constructor)) init()
{
    static char line[64];
    FILE *self;
    char *p = NULL;
    char *sbuf;

    if ((self = fopen("/proc/self/status", "r")) != NULL) {
        while (fgets(line, sizeof(line), self)) {
            if (!strncmp(line, "Name:", 5)) {
                strtok_r(line, "\t\n", &sbuf);
                p = strtok_r(NULL, "\t\n", &sbuf);
                break;
            }
        }
        fclose(self);
    }

    ident = p;

    if (isatty(STDOUT_FILENO)) {
        log_write = log_to_stdout;
    } else {
        log_write = log_to_syslog;

        openlog(ident, 0, LOG_DAEMON);
    }
}
