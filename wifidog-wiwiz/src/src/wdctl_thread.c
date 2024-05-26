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
/** @file wdctl_thread.c
    @brief Monitoring and control of wifidog, server part
    @author Copyright (C) 2004 Alexandre Carmel-Veilleux <acv@acv.ca>
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <syslog.h>
#include <signal.h>
#include <errno.h>

#include "common.h"
#include "httpd.h"
#include "util.h"
#include "conf.h"
#include "debug.h"
#include "auth.h"
#include "centralserver.h"
#include "fw_iptables.h"
#include "firewall.h"
#include "client_list.h"
#include "wdctl_thread.h"
#include "gateway.h"
#include "safe.h"

/* Defined in clientlist.c */
extern	pthread_mutex_t	client_list_mutex;
extern	pthread_mutex_t	config_mutex;

/* Defined in util.c */
extern long served_this_session;	/* added by Wiwiz */

int wdctl_socket_server;	/* added by Wiwiz */

/* From commandline.c: */
extern char ** restartargv;
static void *thread_wdctl_handler(void *);
static void wdctl_status(int);
static void wdctl_stop(int);
static void wdctl_reset(int, const char *);
static void wdctl_auth(int, const char *);	/* added by Wiwiz */
static void wdctl_restart(int);

/** Launches a thread that monitors the control socket for request
@param arg Must contain a pointer to a string containing the Unix domain socket to open
@todo This thread loops infinitely, need a watchdog to verify that it is still running?
*/  
void
thread_wdctl(void *arg)
{
	int	*fd;
	char	*sock_name;
	struct 	sockaddr_un	sa_un;
	int result;
	pthread_t	tid;
	socklen_t len;

	debug(LOG_DEBUG, "Starting wdctl.");

	memset(&sa_un, 0, sizeof(sa_un));
	sock_name = (char *)arg;
	debug(LOG_DEBUG, "Socket name: %s", sock_name);

	if (strlen(sock_name) > (sizeof(sa_un.sun_path) - 1)) {
		/* TODO: Die handler with logging.... */
		debug(LOG_ERR, "WDCTL socket name too long");
		exit(1);
	}
	

	debug(LOG_DEBUG, "Creating socket");
	wdctl_socket_server = socket(PF_UNIX, SOCK_STREAM, 0);

	debug(LOG_DEBUG, "Got server socket %d", wdctl_socket_server);

	/* If it exists, delete... Not the cleanest way to deal. */
	unlink(sock_name);

	debug(LOG_DEBUG, "Filling sockaddr_un");
	strcpy(sa_un.sun_path, sock_name); /* XXX No size check because we
					    * check a few lines before. */
	sa_un.sun_family = AF_UNIX;
	
	debug(LOG_DEBUG, "Binding socket (%s) (%d)", sa_un.sun_path,
			strlen(sock_name));
	
	/* Which to use, AF_UNIX, PF_UNIX, AF_LOCAL, PF_LOCAL? */
	if (bind(wdctl_socket_server, (struct sockaddr *)&sa_un, strlen(sock_name) 
				+ sizeof(sa_un.sun_family))) {
		debug(LOG_ERR, "Could not bind control socket: %s",
				strerror(errno));
		pthread_exit(NULL);
	}

	if (listen(wdctl_socket_server, 5)) {
		debug(LOG_ERR, "Could not listen on control socket: %s",
				strerror(errno));
		pthread_exit(NULL);
	}

	while (1) {
		len = sizeof(sa_un);
		memset(&sa_un, 0, len);
		fd = (int *) safe_malloc(sizeof(int));
		if ((*fd = accept(wdctl_socket_server, (struct sockaddr *)&sa_un, &len)) == -1){
			debug(LOG_ERR, "Accept failed on control socket: %s",
					strerror(errno));
			free(fd);
		} else {
			debug(LOG_DEBUG, "Accepted connection on wdctl socket %d (%s)", fd, sa_un.sun_path);
			result = pthread_create(&tid, NULL, &thread_wdctl_handler, (void *)fd);
			if (result != 0) {
				debug(LOG_ERR, "FATAL: Failed to create a new thread (wdctl handler) - exiting");
				free(fd);
				termination_handler(0);
			}
			pthread_detach(tid);
		}
	}
}


static void *
thread_wdctl_handler(void *arg)
{
	int	fd,
		done,
		i;
	char	request[MAX_BUF];
	ssize_t	read_bytes,
		len;

	debug(LOG_DEBUG, "Entering thread_wdctl_handler....");

	fd = *((int *) arg);
	free(arg);
	debug(LOG_DEBUG, "Read bytes and stuff from %d", fd);

	/* Init variables */
	read_bytes = 0;
	done = 0;
	memset(request, 0, sizeof(request));
	
	/* Read.... */
	while (!done && read_bytes < (sizeof(request) - 1)) {
		len = read(fd, request + read_bytes,
				sizeof(request) - read_bytes);

		/* Have we gotten a command yet? */
		for (i = read_bytes; i < (read_bytes + len); i++) {
			if (request[i] == '\r' || request[i] == '\n') {
				request[i] = '\0';
				done = 1;
			}
		}
		
		/* Increment position */
		read_bytes += len;
	}

	if (strncmp(request, "status", 6) == 0) {
		wdctl_status(fd);
	} else if (strncmp(request, "stop", 4) == 0) {
		wdctl_stop(fd);
	} else if (strncmp(request, "reset", 5) == 0) {
		wdctl_reset(fd, (request + 6));

	/* starts: added by Wiwiz */
	} else if (strncmp(request, "auth", 4) == 0) {
		wdctl_auth(fd, (request + 5));
	/* end: added by Wiwiz */
	} else if (strncmp(request, "restart", 7) == 0) {
		wdctl_restart(fd);
	}

	if (!done) {
		debug(LOG_ERR, "Invalid wdctl request.");
		shutdown(fd, 2);
		close(fd);
		pthread_exit(NULL);
	}

	debug(LOG_DEBUG, "Request received: [%s]", request);
	
	shutdown(fd, 2);
	close(fd);
	debug(LOG_DEBUG, "Exiting thread_wdctl_handler....");

	return NULL;
}

static void
wdctl_status(int fd)
{
	char * status = NULL;
	int len = 0;

	status = get_status_text();
	len = strlen(status);

	if(write(fd, status, len) == -1)
		debug(LOG_CRIT, "Write error: %s", strerror(errno));

	free(status);
}

/** A bit of an hack, self kills.... */
static void
wdctl_stop(int fd)
{
	pid_t	pid;

	pid = getpid();
	kill(pid, SIGINT);
}

static void
wdctl_restart(int afd)
{
	int	sock,
		fd;
	char	*sock_name;
	struct 	sockaddr_un	sa_un;
	s_config * conf = NULL;
	t_client * client = NULL;
	char * tempstring = NULL;
	pid_t pid;
	ssize_t written;
	socklen_t len;

	conf = config_get_config();

	debug(LOG_NOTICE, "Will restart myself");

	/*
	 * First, prepare the internal socket
	 */
	memset(&sa_un, 0, sizeof(sa_un));
	sock_name = conf->internal_sock;
	debug(LOG_DEBUG, "Socket name: %s", sock_name);

	if (strlen(sock_name) > (sizeof(sa_un.sun_path) - 1)) {
		/* TODO: Die handler with logging.... */
		debug(LOG_ERR, "INTERNAL socket name too long");
		return;
	}

	debug(LOG_DEBUG, "Creating socket");
	sock = socket(PF_UNIX, SOCK_STREAM, 0);

	debug(LOG_DEBUG, "Got internal socket %d", sock);

	/* If it exists, delete... Not the cleanest way to deal. */
	unlink(sock_name);

	debug(LOG_DEBUG, "Filling sockaddr_un");
	strcpy(sa_un.sun_path, sock_name); /* XXX No size check because we check a few lines before. */
	sa_un.sun_family = AF_UNIX;
	
	debug(LOG_DEBUG, "Binding socket (%s) (%d)", sa_un.sun_path, strlen(sock_name));
	
	/* Which to use, AF_UNIX, PF_UNIX, AF_LOCAL, PF_LOCAL? */
	if (bind(sock, (struct sockaddr *)&sa_un, strlen(sock_name) + sizeof(sa_un.sun_family))) {
		debug(LOG_ERR, "Could not bind internal socket: %s", strerror(errno));
		return;
	}

	if (listen(sock, 5)) {
		debug(LOG_ERR, "Could not listen on internal socket: %s", strerror(errno));
		return;
	}
	
	/*
	 * The internal socket is ready, fork and exec ourselves
	 */
	debug(LOG_DEBUG, "Forking in preparation for exec()...");
	pid = safe_fork();
	if (pid > 0) {
		/* Parent */

		/* Wait for the child to connect to our socket :*/
		debug(LOG_DEBUG, "Waiting for child to connect on internal socket");
		len = sizeof(sa_un);
		if ((fd = accept(sock, (struct sockaddr *)&sa_un, &len)) == -1){
			debug(LOG_ERR, "Accept failed on internal socket: %s", strerror(errno));
			close(sock);
			return;
		}

		close(sock);

		debug(LOG_DEBUG, "Received connection from child.  Sending them all existing clients");

		/* The child is connected. Send them over the socket the existing clients */
		LOCK_CLIENT_LIST();
		client = client_get_first_client();
		while (client) {
			/* Send this client */
			safe_asprintf(&tempstring, "CLIENT|ip=%s|mac=%s|token=%s|fw_connection_state=%u|fd=%d|counters_incoming=%llu|counters_outgoing=%llu|counters_last_updated=%lu\n", client->ip, client->mac, client->token, client->fw_connection_state, client->fd, client->counters.incoming, client->counters.outgoing, client->counters.last_updated);
			debug(LOG_DEBUG, "Sending to child client data: %s", tempstring);
			len = 0;
			while (len != strlen(tempstring)) {
				written = write(fd, (tempstring + len), strlen(tempstring) - len);
				if (written == -1) {
					debug(LOG_ERR, "Failed to write client data to child: %s", strerror(errno));
					free(tempstring);
					break;
				}
				else {
					len += written;
				}
			}
			free(tempstring);
			client = client->next;
		}
		UNLOCK_CLIENT_LIST();

		close(fd);

		debug(LOG_INFO, "Sent all existing clients to child.  Committing suicide!");

		shutdown(afd, 2);
		close(afd);

		/* Our job in life is done. Commit suicide! */
		wdctl_stop(afd);
	}
	else {
		/* Child */
		close(wdctl_socket_server);
		close(icmp_fd);
		close(sock);
		shutdown(afd, 2);
		close(afd);
		debug(LOG_NOTICE, "Re-executing myself (%s)", restartargv[0]);
		setsid();
		execvp(restartargv[0], restartargv);
		/* If we've reached here the exec() failed - die quickly and silently */
		debug(LOG_ERR, "I failed to re-execute myself: %s", strerror(errno));
		debug(LOG_ERR, "Exiting without cleanup");
		exit(1);
	}

}

static void
wdctl_reset(int fd, const char *arg)
{
	t_client	*node;

	debug(LOG_DEBUG, "Entering wdctl_reset...");
	
	LOCK_CLIENT_LIST();
	debug(LOG_DEBUG, "Argument: %s (@%x)", arg, arg);
	
	/* We get the node or return... */
	if ((node = client_list_find_by_ip(arg)) != NULL);
	else if ((node = client_list_find_by_mac(arg)) != NULL);
	else {
		debug(LOG_DEBUG, "Client not found.");
		UNLOCK_CLIENT_LIST();
		if(write(fd, "No", 2) == -1)
			debug(LOG_CRIT, "Unable to write No: %s", strerror(errno));

		return;
	}

	debug(LOG_DEBUG, "Got node %x.", node);
	
	/* deny.... */
	/* TODO: maybe just deleting the connection is not best... But this
	 * is a manual command, I don't anticipate it'll be that useful. */
	fw_deny(node->ip, node->mac, node->fw_connection_state);
	client_list_delete(node);

	UNLOCK_CLIENT_LIST();

	if(write(fd, "Yes", 3) == -1)
		debug(LOG_CRIT, "Unable to write Yes: %s", strerror(errno));

	debug(LOG_DEBUG, "Exiting wdctl_reset...");
}

/* start: added by Wiwiz */
static void
wdctl_auth(int fd, const char *arg)
{
	t_client	*client;

	debug(LOG_DEBUG, "Entering wdctl_auth...");

	debug(LOG_DEBUG, "Argument: %s", arg);

	char str[3][80];
	int cnt = split(str, arg, ",");
	if(cnt < 3) {
		debug(LOG_DEBUG, "cnt is less than 3, exiting wdctl_auth...");
		return;
	}

	char *mac = str[0];
	char *ip = str[1];
	char *token = str[2];

	debug(LOG_DEBUG, "str[][] = %s, %s, %s", str[0], str[1], str[2]);

	char s[80];
	strcpy(s, mac);
	strcat(s, ",");
	strcat(s, ip);
	strcat(s, ",");
	strcat(s, token);

	LOCK_CLIENT_LIST();

	if ((client = client_list_find(ip, mac)) == NULL) {
		debug(LOG_DEBUG, "New client for %s, %s", ip, mac);

		client = client_list_append(ip, mac, token);

		client->fw_connection_state = FW_MARK_KNOWN;
		fw_allow(ip, mac, FW_MARK_KNOWN);
		served_this_session++;

		strcat(s, " Authenticated.\n");
	} else {
		debug(LOG_DEBUG, "Old client for %s, %s", ip, mac);
		strcat(s, " NOT authenticated.\n");
	}

	UNLOCK_CLIENT_LIST();

	if(write(fd, s, strlen(s)) == -1)
		debug(LOG_CRIT, "Unable to write arg: %s", strerror(errno));

	debug(LOG_DEBUG, "Exiting wdctl_auth...");
}

int split(char dst[][80], char* str, const char* spl)
{
    int n = 0;
    char *result = NULL;
    char *p;
    result = strtok_r(str, spl, &p);
    while( result != NULL )
    {
        strcpy(dst[n++], result);
        result = strtok_r(NULL, spl, &p);
    }
    return n;
}

/* end: added by Wiwiz */
