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
/** @file auth.c
    @brief Authentication handling thread
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
#include <unistd.h>
#include <syslog.h>

#include "httpd.h"
#include "http.h"
#include "safe.h"
#include "conf.h"
#include "debug.h"
#include "auth.h"
#include "centralserver.h"
#include "fw_iptables.h"
#include "firewall.h"
#include "client_list.h"
#include "util.h"

/* Defined in clientlist.c */
extern	pthread_mutex_t	client_list_mutex;

/* Defined in util.c */
extern long served_this_session;

/** Launches a thread that periodically checks if any of the connections has timed out
@param arg Must contain a pointer to a string containing the IP adress of the client to check to check
@todo Also pass MAC adress? 
@todo This thread loops infinitely, need a watchdog to verify that it is still running?
*/  
void
thread_client_timeout_check(const void *arg)
{
	pthread_cond_t		cond = PTHREAD_COND_INITIALIZER;
	pthread_mutex_t		cond_mutex = PTHREAD_MUTEX_INITIALIZER;
	struct	timespec	timeout;
	
	while (1) {
		/* Sleep for config.checkinterval seconds... */
		timeout.tv_sec = time(NULL) + config_get_config()->checkinterval;
		timeout.tv_nsec = 0;

		/* Mutex must be locked for pthread_cond_timedwait... */
		pthread_mutex_lock(&cond_mutex);
		
		/* Thread safe "sleep" */
		pthread_cond_timedwait(&cond, &cond_mutex, &timeout);

		/* No longer needs to be locked */
		pthread_mutex_unlock(&cond_mutex);
	
		debug(LOG_DEBUG, "Running fw_counter()");
	
		fw_sync_with_authserver();
	}
}

/** Authenticates a single client against the central server and returns when done
 * Alters the firewall rules depending on what the auth server says
@param r httpd request struct
*/
void
authenticate_client(request *r)
{
	t_client	*client;
	t_authresponse	auth_response;
	char	*mac,
		*token;
	char *urlFragment = NULL;
	s_config	*config = NULL;
	t_auth_serv	*auth_server = NULL;

	//wiwiz add start
	if (!(mac = arp_get(r->clientAddr))) {
		/* We could not get their MAC address */
		debug(LOG_ERR, "Failed to retrieve MAC address for ip %s", r->clientAddr);
		return;
	}
	//wiwiz add end

	LOCK_CLIENT_LIST();

	//client = client_list_find_by_ip(r->clientAddr);	wiwiz deleted
	client = client_list_find(r->clientAddr, mac);	//wiwiz

	if (client == NULL) {
		debug(LOG_ERR, "authenticate_client(): Could not find client for %s", r->clientAddr);
		UNLOCK_CLIENT_LIST();
		return;
	}
	
	mac = safe_strdup(client->mac);
	token = safe_strdup(client->token);
	
	UNLOCK_CLIENT_LIST();
	
	/* 
	 * At this point we've released the lock while we do an HTTP request since it could
	 * take multiple seconds to do and the gateway would effectively be frozen if we
	 * kept the lock.
	 */
	auth_server_request(&auth_response, REQUEST_TYPE_LOGIN, r->clientAddr, mac, token, 0, 0);
	
	LOCK_CLIENT_LIST();
	
	/* can't trust the client to still exist after n seconds have passed */
	client = client_list_find(r->clientAddr, mac);
	
	if (client == NULL) {
		debug(LOG_ERR, "authenticate_client(): Could not find client node for %s (%s)", r->clientAddr, mac);
		UNLOCK_CLIENT_LIST();
		free(token);
		free(mac);
		return;
	}
	
	free(token);
	free(mac);

	/* Prepare some variables we'll need below */
	config = config_get_config();
	auth_server = get_auth_server();

	switch(auth_response.authcode) {

	case AUTH_ERROR:
		/* Error talking to central server */
		debug(LOG_ERR, "Got %d from central server authenticating token %s from %s at %s", auth_response, client->token, client->ip, client->mac);
		send_http_page(r, "Error!", "Error: We did not get a valid answer from the central server");
		break;

	case AUTH_DENIED:
		/* Central server said invalid token */
		debug(LOG_INFO, "Got DENIED from central server authenticating token %s from %s at %s - deleting from firewall and redirecting them to denied message", client->token, client->ip, client->mac);
		fw_deny(client->ip, client->mac, FW_MARK_KNOWN);
		safe_asprintf(&urlFragment, "%smessage=%s",
			auth_server->authserv_msg_script_path_fragment,
			GATEWAY_MESSAGE_DENIED
		);
		http_send_redirect_to_auth(r, urlFragment, "Redirect to denied message");
		free(urlFragment);
		break;

    case AUTH_VALIDATION:
		/* They just got validated for X minutes to check their email */
		debug(LOG_INFO, "Got VALIDATION from central server authenticating token %s from %s at %s"
				"- adding to firewall and redirecting them to activate message", client->token,
				client->ip, client->mac);
		client->fw_connection_state = FW_MARK_PROBATION;
		fw_allow(client->ip, client->mac, FW_MARK_PROBATION);
		safe_asprintf(&urlFragment, "%smessage=%s",
			auth_server->authserv_msg_script_path_fragment,
			GATEWAY_MESSAGE_ACTIVATE_ACCOUNT
		);
		http_send_redirect_to_auth(r, urlFragment, "Redirect to activate message");
		free(urlFragment);
	    break;

    case AUTH_ALLOWED:
		/* Logged in successfully as a regular account */
		debug(LOG_INFO, "Got ALLOWED from central server authenticating token %s from %s at %s - "
				"adding to firewall and redirecting them to portal", client->token, client->ip, client->mac);
		client->fw_connection_state = FW_MARK_KNOWN;
		fw_allow(client->ip, client->mac, FW_MARK_KNOWN);
        served_this_session++;
        /* wiwiz modified
		safe_asprintf(&urlFragment, "%sgw_id=%s",
			auth_server->authserv_portal_script_path_fragment,
			config->gw_id
		);
		*/
		safe_asprintf(&urlFragment, "%sgw_id=%s&gw_address=%s&token=%s",
			auth_server->authserv_portal_script_path_fragment,
			config->gw_id,
			config->gw_address,
			client->token
		);

		http_send_redirect_to_auth(r, urlFragment, "Redirect to portal");
		free(urlFragment);
	    break;

    case AUTH_VALIDATION_FAILED:
		 /* Client had X minutes to validate account by email and didn't = too late */
		debug(LOG_INFO, "Got VALIDATION_FAILED from central server authenticating token %s from %s at %s "
				"- redirecting them to failed_validation message", client->token, client->ip, client->mac);
		safe_asprintf(&urlFragment, "%smessage=%s",
			auth_server->authserv_msg_script_path_fragment,
			GATEWAY_MESSAGE_ACCOUNT_VALIDATION_FAILED
		);
		http_send_redirect_to_auth(r, urlFragment, "Redirect to failed validation message");
		free(urlFragment);
	    break;

    default:
		debug(LOG_WARNING, "I don't know what the validation code %d means for token %s from %s at %s - sending error message", auth_response.authcode, client->token, client->ip, client->mac);
		send_http_page(r, "Internal Error", "We can not validate your request at this time");
	    break;

	}

	UNLOCK_CLIENT_LIST();
	return;
}


