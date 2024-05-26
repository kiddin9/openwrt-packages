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
/** @file ping_thread.c
    @brief Periodically checks in with the central auth server so the auth
    server knows the gateway is still up.  Note that this is NOT how the gateway
    detects that the central server is still up.
    @author Copyright (C) 2004 Alexandre Carmel-Veilleux <acv@miniguru.ca>
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <syslog.h>
#include <signal.h>
#include <errno.h>

#include "../config.h"
#include "safe.h"
#include "common.h"
#include "conf.h"
#include "debug.h"
#include "ping_thread.h"
#include "util.h"
#include "centralserver.h"

static void ping(void);

extern time_t started_time;

/** Launches a thread that periodically checks in with the wifidog auth server to perform heartbeat function.
@param arg NULL
@todo This thread loops infinitely, need a watchdog to verify that it is still running?
*/  
void
thread_ping(void *arg)
{
	pthread_cond_t		cond = PTHREAD_COND_INITIALIZER;
	pthread_mutex_t		cond_mutex = PTHREAD_MUTEX_INITIALIZER;
	struct	timespec	timeout;
	
	while (1) {
		/* Make sure we check the servers at the very begining */
		debug(LOG_DEBUG, "Running ping()");
		ping();
		
		/* Sleep for config.checkinterval seconds... */
		timeout.tv_sec = time(NULL) + config_get_config()->checkinterval;
		timeout.tv_nsec = 0;

		/* Mutex must be locked for pthread_cond_timedwait... */
		pthread_mutex_lock(&cond_mutex);
		
		/* Thread safe "sleep" */
		pthread_cond_timedwait(&cond, &cond_mutex, &timeout);

		/* No longer needs to be locked */
		pthread_mutex_unlock(&cond_mutex);
	}
}

/** @internal
 * This function does the actual request.
 */
static void
ping(void)
{
        ssize_t			numbytes;
        size_t	        	totalbytes;
	int			sockfd, nfds, done;
	char			request[MAX_BUF];
	fd_set			readfds;
	struct timeval		timeout;
	FILE * fh;
	unsigned long int sys_uptime  = 0;
	unsigned int      sys_memfree = 0;
	float             sys_load    = 0;
	t_auth_serv	*auth_server = NULL;
	auth_server = get_auth_server();
	
	debug(LOG_DEBUG, "Entering ping()");
	
	/*
	 * The ping thread does not really try to see if the auth server is actually
	 * working. Merely that there is a web server listening at the port. And that
	 * is done by connect_auth_server() internally.
	 */
	sockfd = connect_auth_server();
	if (sockfd == -1) {
		/*
		 * No auth servers for me to talk to
		 */
		return;
	}

	/*
	 * Populate uptime, memfree and load
	 */
	if ((fh = fopen("/proc/uptime", "r"))) {
		if(fscanf(fh, "%lu", &sys_uptime) != 1)
			debug(LOG_CRIT, "Failed to read uptime");

		fclose(fh);
	}
	if ((fh = fopen("/proc/meminfo", "r"))) {
		while (!feof(fh)) {
			if (fscanf(fh, "MemFree: %u", &sys_memfree) == 0) {
				/* Not on this line */
				while (!feof(fh) && fgetc(fh) != '\n');
			}
			else {
				/* Found it */
				break;
			}
		}
		fclose(fh);
	}
	if ((fh = fopen("/proc/loadavg", "r"))) {
		if(fscanf(fh, "%f", &sys_load) != 1)
			debug(LOG_CRIT, "Failed to read loadavg");

		fclose(fh);
	}

	/*
	 * Prep & send request
	 */
	snprintf(request, sizeof(request) - 1,
			"GET %s%sgw_id=%s&sys_uptime=%lu&sys_memfree=%u&sys_load=%.2f&wifidog_uptime=%lu HTTP/1.0\r\n"
			"User-Agent: WiFiDog %s\r\n"
			"Host: %s\r\n"
			"\r\n",
			auth_server->authserv_path,
			auth_server->authserv_ping_script_path_fragment,
			config_get_config()->gw_id,
			sys_uptime,
			sys_memfree,
			sys_load,
			(long unsigned int)((long unsigned int)time(NULL) - (long unsigned int)started_time),
			VERSION,
			auth_server->authserv_hostname);

	debug(LOG_DEBUG, "HTTP Request to Server: [%s]", request);
	
	send(sockfd, request, strlen(request), 0);

	debug(LOG_DEBUG, "Reading response");
	
	numbytes = totalbytes = 0;
	done = 0;
	do {
		FD_ZERO(&readfds);
		FD_SET(sockfd, &readfds);
		timeout.tv_sec = 30; /* XXX magic... 30 second */
		timeout.tv_usec = 0;
		nfds = sockfd + 1;

		nfds = select(nfds, &readfds, NULL, NULL, &timeout);

		if (nfds > 0) {
			/** We don't have to use FD_ISSET() because there
			 *  was only one fd. */
			numbytes = read(sockfd, request + totalbytes, MAX_BUF - (totalbytes + 1));
			if (numbytes < 0) {
				debug(LOG_ERR, "An error occurred while reading from auth server: %s", strerror(errno));
				/* FIXME */
				close(sockfd);
				return;
			}
			else if (numbytes == 0) {
				done = 1;
			}
			else {
				totalbytes += numbytes;
				debug(LOG_DEBUG, "Read %d bytes, total now %d", numbytes, totalbytes);
			}
		}
		else if (nfds == 0) {
			debug(LOG_ERR, "Timed out reading data via select() from auth server");
			/* FIXME */
			close(sockfd);
			return;
		}
		else if (nfds < 0) {
			debug(LOG_ERR, "Error reading data via select() from auth server: %s", strerror(errno));
			/* FIXME */
			close(sockfd);
			return;
		}
	} while (!done);
	close(sockfd);

	debug(LOG_DEBUG, "Done reading reply, total %d bytes", totalbytes);

	request[totalbytes] = '\0';

	debug(LOG_DEBUG, "HTTP Response from Server: [%s]", request);
	
	if (strstr(request, "Pong") == 0) {
		debug(LOG_WARNING, "Auth server did NOT say pong!");
		/* FIXME */
	}
	else {
		debug(LOG_DEBUG, "Auth Server Says: Pong");
	}

	return;	
}
