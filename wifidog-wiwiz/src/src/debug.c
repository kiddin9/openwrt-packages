/********************************************************************\
 * This program is free software; you can redistribute it and/or    *
 * modify it under the terms of the GNU General Public License as   *
 * published by the Free Software Foundation; either version 2 of   *
 * the License, or (at your option) any later version.              *
 *                                                                  *
 * This program is distributed in the hope that it will be useful,  *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of   *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    *
 * GNU General Public License for more details.                     *
 *                                                                  *
 * You should have received a copy of the GNU General Public License*
 * along with this program; if not, contact:                        *
 *                                                                  *
 * Free Software Foundation           Voice:  +1-617-542-5942       *
 * 59 Temple Place - Suite 330        Fax:    +1-617-542-2652       *
 * Boston, MA  02111-1307,  USA       gnu@gnu.org                   *
 *                                                                  *
\********************************************************************/

/* $Id$ */
/** @file debug.c
    @brief Debug output routines
    @author Copyright (C) 2004 Philippe April <papril777@yahoo.com>
*/

#include <stdio.h>
#include <errno.h>
#include <syslog.h>
#include <stdarg.h>
#include <time.h>
#include <unistd.h>

#include "conf.h"

/** @internal
Do not use directly, use the debug macro */
void
_debug(const char *filename, int line, int level, const char *format, ...)
{
    char buf[28];
    va_list vlist;
    s_config *config = config_get_config();
    time_t ts;

    time(&ts);

    if (config->debuglevel >= level) {

        if (level <= LOG_WARNING) {
            fprintf(stderr, "[%d][%.24s][%u](%s:%d) ", level, ctime_r(&ts, buf), getpid(),
			    filename, line);
            va_start(vlist, format);
            vfprintf(stderr, format, vlist);
            va_end(vlist);
            fputc('\n', stderr);
        } else if (!config->daemon) {
            fprintf(stdout, "[%d][%.24s][%u](%s:%d) ", level, ctime_r(&ts, buf), getpid(),
			    filename, line);
            va_start(vlist, format);
            vfprintf(stdout, format, vlist);
            va_end(vlist);
            fputc('\n', stdout);
            fflush(stdout);
        }

        if (config->log_syslog) {
            openlog("wifidog", LOG_PID, config->syslog_facility);
            va_start(vlist, format);
            vsyslog(level, format, vlist);
            va_end(vlist);
            closelog();
        }
    }
}

