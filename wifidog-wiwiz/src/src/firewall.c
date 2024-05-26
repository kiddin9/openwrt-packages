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

/*
 * $Id$
 */
/** @internal
  @file firewall.c
  @brief Firewall update functions
  @author Copyright (C) 2004 Philippe April <papril777@yahoo.com>
  2006 Benoit Grégoire, Technologies Coeus inc. <bock@step.polymtl.ca>
 */

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <pthread.h>
#include <sys/wait.h>
#include <sys/types.h>
/* #include <sys/unistd.h>	by Wiwiz */

#include <string.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/uio.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/time.h>

#ifdef __linux__
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netpacket/packet.h>
#endif

#if defined(__NetBSD__)
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#endif

#include "httpd.h"
#include "safe.h"
#include "debug.h"
#include "conf.h"
#include "firewall.h"
#include "fw_iptables.h"
#include "auth.h"
#include "centralserver.h"
#include "client_list.h"

extern pthread_mutex_t client_list_mutex;

/* from commandline.c */
extern pid_t restart_orig_pid;

int icmp_fd;	/* added by wiwiz */

/**
 * Allow a client access through the firewall by adding a rule in the firewall to MARK the user's packets with the proper
 * rule by providing his IP and MAC address
 * @param ip IP address to allow
 * @param mac MAC address to allow
 * @param fw_connection_state fw_connection_state Tag
 * @return Return code of the command
 */
int
fw_allow(const char *ip, const char *mac, int fw_connection_state)
{
    debug(LOG_DEBUG, "Allowing %s %s with fw_connection_state %d", ip, mac, fw_connection_state);

    /* wiwiz starts */
    char *cmd;
    safe_asprintf(&cmd, "/usr/local/hsbuilder/setspeed.sh set %s &", mac);
    /*system(cmd);*/
    execute(cmd, 0);
    /* wiwiz ends */

    return iptables_fw_access(FW_ACCESS_ALLOW, ip, mac, fw_connection_state);
}

/**
 * @brief Deny a client access through the firewall by removing the rule in the firewall that was fw_connection_stateging the user's traffic
 * @param ip IP address to deny
 * @param mac MAC address to deny
 * @param fw_connection_state fw_connection_state Tag
 * @return Return code of the command
 */
int
fw_deny(const char *ip, const char *mac, int fw_connection_state)
{
    debug(LOG_DEBUG, "Denying %s %s with fw_connection_state %d", ip, mac, fw_connection_state);

    /* wiwiz starts */
    char *cmd ;
    safe_asprintf(&cmd, "/usr/local/hsbuilder/setspeed.sh unset %s &", mac);
    /*system(cmd);*/
    execute(cmd, 0);
    /* wiwiz ends */

    return iptables_fw_access(FW_ACCESS_DENY, ip, mac, fw_connection_state);
}

/* XXX DCY */
/**
 * Get an IP's MAC address from the ARP cache.
 * Go through all the entries in /proc/net/arp until we find the requested
 * IP address and return the MAC address bound to it.
 * @todo Make this function portable (using shell scripts?)
 */
char           *
arp_get(const char *req_ip)
{
    FILE           *proc;
	 char ip[16];
	 char mac[18];
	 char * reply = NULL;

    if (!(proc = fopen("/proc/net/arp", "r"))) {
        return NULL;
    }

    /* Skip first line */
	 while (!feof(proc) && fgetc(proc) != '\n');

	 /* Find ip, copy mac in reply */
	 reply = NULL;
    while (!feof(proc) && (fscanf(proc, " %15[0-9.] %*s %*s %17[A-Fa-f0-9:] %*s %*s", ip, mac) == 2)) {
		  if (strcmp(ip, req_ip) == 0) {
				reply = safe_strdup(mac);
				break;
		  }
    }

    fclose(proc);

    return reply;
}

/** Initialize the firewall rules
 */
int
fw_init(void)
{
    int flags, oneopt = 1, zeroopt = 0;
	 int result = 0;
	 t_client * client = NULL;

    debug(LOG_INFO, "Creating ICMP socket");
    if ((icmp_fd = socket (AF_INET, SOCK_RAW, IPPROTO_ICMP)) == -1 ||
            (flags = fcntl(icmp_fd, F_GETFL, 0)) == -1 ||
             fcntl(icmp_fd, F_SETFL, flags | O_NONBLOCK) == -1 ||
             setsockopt(icmp_fd, SOL_SOCKET, SO_RCVBUF, &oneopt, sizeof(oneopt)) ||
             setsockopt(icmp_fd, SOL_SOCKET, SO_DONTROUTE, &zeroopt, sizeof(zeroopt)) == -1) {
        debug(LOG_ERR, "Cannot create ICMP raw socket.");
        return 0;
    }

    debug(LOG_INFO, "Initializing Firewall");
    result = iptables_fw_init();

	 if (restart_orig_pid) {
		 debug(LOG_INFO, "Restoring firewall rules for clients inherited from parent");
		 LOCK_CLIENT_LIST();
		 client = client_get_first_client();
		 while (client) {
			 fw_allow(client->ip, client->mac, client->fw_connection_state);
			 client = client->next;
		 }
		 UNLOCK_CLIENT_LIST();
	 }

	 return result;
}

/** Remove all auth server firewall whitelist rules
 */
void
fw_clear_authservers(void)
{
	debug(LOG_INFO, "Clearing the authservers list");
	iptables_fw_clear_authservers();
}

/** Add the necessary firewall rules to whitelist the authservers
 */
void
fw_set_authservers(void)
{
	debug(LOG_INFO, "Setting the authservers list");
	iptables_fw_set_authservers();
}

/** Remove the firewall rules
 * This is used when we do a clean shutdown of WiFiDog.
 * @return Return code of the fw.destroy script
 */
int
fw_destroy(void)
{
    if (icmp_fd != 0) {
        debug(LOG_INFO, "Closing ICMP socket");
        close(icmp_fd);
    }

    debug(LOG_INFO, "Removing Firewall rules");
    return iptables_fw_destroy();
}

/**Probably a misnomer, this function actually refreshes the entire client list's traffic counter, re-authenticates every client with the central server and update's the central servers traffic counters and notifies it if a client has logged-out.
 * @todo Make this function smaller and use sub-fonctions
 */
void
fw_sync_with_authserver(void)
{
    t_authresponse  authresponse;
    char            *token, *ip, *mac;
    t_client        *p1, *p2;
    unsigned long long	    incoming, outgoing;
    s_config *config = config_get_config();

    if (-1 == iptables_fw_counters_update()) {
        debug(LOG_ERR, "Could not get counters from firewall!");
        return;
    }

    LOCK_CLIENT_LIST();

    for (p1 = p2 = client_get_first_client(); NULL != p1; p1 = p2) {
        p2 = p1->next;

        ip = safe_strdup(p1->ip);
        token = safe_strdup(p1->token);
        mac = safe_strdup(p1->mac);
	    outgoing = p1->counters.outgoing;
	    incoming = p1->counters.incoming;

	    UNLOCK_CLIENT_LIST();
        /* Ping the client, if he responds it'll keep activity on the link.
         * However, if the firewall blocks it, it will not help.  The suggested
         * way to deal witht his is to keep the DHCP lease time extremely
         * short:  Shorter than config->checkinterval * config->clienttimeout */
        icmp_ping(ip);
        /* Update the counters on the remote server only if we have an auth server */
        if (config->auth_servers != NULL) {
            auth_server_request(&authresponse, REQUEST_TYPE_COUNTERS, ip, mac, token, incoming, outgoing);
        }
	    LOCK_CLIENT_LIST();

        if (!(p1 = client_list_find(ip, mac))) {
            debug(LOG_ERR, "Node %s was freed while being re-validated!", ip);
        } else {
        	time_t	current_time=time(NULL);
        	debug(LOG_INFO, "Checking client %s for timeout:  Last updated %ld (%ld seconds ago), timeout delay %ld seconds, current time %ld, ",
                        p1->ip, p1->counters.last_updated, current_time-p1->counters.last_updated, config->checkinterval * config->clienttimeout, current_time);
            if (p1->counters.last_updated +
				(config->checkinterval * config->clienttimeout)
				<= current_time) {
                /* Timing out user */
                debug(LOG_INFO, "%s - Inactive for more than %ld seconds, removing client and denying in firewall",
                        p1->ip, config->checkinterval * config->clienttimeout);
                fw_deny(p1->ip, p1->mac, p1->fw_connection_state);
                client_list_delete(p1);

                /* Advertise the logout if we have an auth server */
                if (config->auth_servers != NULL) {
					UNLOCK_CLIENT_LIST();
					//auth_server_request(&authresponse, REQUEST_TYPE_LOGOUT, ip, mac, token, 0, 0);
					auth_server_request(&authresponse, REQUEST_TYPE_LOGOUT2, ip, mac, token, 0, 0);	// changed by Wiwiz
					LOCK_CLIENT_LIST();
                }
            } else {
                /*
                 * This handles any change in
                 * the status this allows us
                 * to change the status of a
                 * user while he's connected
                 *
                 * Only run if we have an auth server
                 * configured!
                 */
                if (config->auth_servers != NULL) {
                    switch (authresponse.authcode) {
                        case AUTH_DENIED:
                            debug(LOG_NOTICE, "%s - Denied. Removing client and firewall rules", p1->ip);
                            fw_deny(p1->ip, p1->mac, p1->fw_connection_state);
                            client_list_delete(p1);
                            break;

                        case AUTH_VALIDATION_FAILED:
                            debug(LOG_NOTICE, "%s - Validation timeout, now denied. Removing client and firewall rules", p1->ip);
                            fw_deny(p1->ip, p1->mac, p1->fw_connection_state);
                            client_list_delete(p1);
                            break;

                        case AUTH_ALLOWED:
                            if (p1->fw_connection_state != FW_MARK_KNOWN) {
                                debug(LOG_INFO, "%s - Access has changed to allowed, refreshing firewall and clearing counters", p1->ip);
                                //WHY did we deny, then allow!?!? benoitg 2007-06-21
                                //fw_deny(p1->ip, p1->mac, p1->fw_connection_state);

                                if (p1->fw_connection_state != FW_MARK_PROBATION) {
     p1->counters.incoming = p1->counters.outgoing = 0;
                                }
                                else {
                                	//We don't want to clear counters if the user was in validation, it probably already transmitted data..
                                    debug(LOG_INFO, "%s - Skipped clearing counters after all, the user was previously in validation", p1->ip);
                                }
                                p1->fw_connection_state = FW_MARK_KNOWN;
                                fw_allow(p1->ip, p1->mac, p1->fw_connection_state);
                            }
                            break;

                        case AUTH_VALIDATION:
                            /*
                             * Do nothing, user
                             * is in validation
                             * period
                             */
                            debug(LOG_INFO, "%s - User in validation period", p1->ip);
                            break;

                              case AUTH_ERROR:
                                    debug(LOG_WARNING, "Error communicating with auth server - leaving %s as-is for now", p1->ip);
                                    break;

                        default:
                            debug(LOG_ERR, "I do not know about authentication code %d", authresponse.authcode);
                            break;
                    }
                }
            }
        }

        free(token);
        free(ip);
        free(mac);
    }
    UNLOCK_CLIENT_LIST();
}

void
icmp_ping(const char *host)
{
	struct sockaddr_in saddr;
#if defined(__linux__) || defined(__NetBSD__)
	struct {
		struct ip ip;
		struct icmp icmp;
	} packet;
#endif
	unsigned int i, j;
	int opt = 2000;
	unsigned short id = rand16();

	memset(&saddr, 0, sizeof(saddr));
	saddr.sin_family = AF_INET;
	inet_aton(host, &saddr.sin_addr);
#if defined(HAVE_SOCKADDR_SA_LEN) || defined(__NetBSD__)
	saddr.sin_len = sizeof(struct sockaddr_in);
#endif

#if defined(__linux__) || defined(__NetBSD__)
	memset(&packet.icmp, 0, sizeof(packet.icmp));
	packet.icmp.icmp_type = ICMP_ECHO;
	packet.icmp.icmp_id = id;

	for (j = 0, i = 0; i < sizeof(struct icmp) / 2; i++)
		j += ((unsigned short *)&packet.icmp)[i];

	while (j >> 16)
		j = (j & 0xffff) + (j >> 16);

	packet.icmp.icmp_cksum = (j == 0xffff) ? j : ~j;

	if (setsockopt(icmp_fd, SOL_SOCKET, SO_RCVBUF, &opt, sizeof(opt)) == -1)
		debug(LOG_ERR, "setsockopt(): %s", strerror(errno));

	if (sendto(icmp_fd, (char *)&packet.icmp, sizeof(struct icmp), 0,
	           (const struct sockaddr *)&saddr, sizeof(saddr)) == -1)
		debug(LOG_ERR, "sendto(): %s", strerror(errno));

	opt = 1;
	if (setsockopt(icmp_fd, SOL_SOCKET, SO_RCVBUF, &opt, sizeof(opt)) == -1)
		debug(LOG_ERR, "setsockopt(): %s", strerror(errno));
#endif

	return;
}

unsigned short rand16(void) {
  static int been_seeded = 0;

  if (!been_seeded) {
    unsigned int seed = 0;
    struct timeval now;

    /* not a very good seed but what the heck, it needs to be quickly acquired */
    gettimeofday(&now, NULL);
    seed = now.tv_sec ^ now.tv_usec ^ (getpid() << 16);

    srand(seed);
    been_seeded = 1;
    }

    /* Some rand() implementations have less randomness in low bits
     * than in high bits, so we only pay attention to the high ones.
     * But most implementations don't touch the high bit, so we
     * ignore that one.
     **/
      return( (unsigned short) (rand() >> 15) );
}
