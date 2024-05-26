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
/** @file conf.h
    @brief Config file parsing
    @author Copyright (C) 2004 Philippe April <papril777@yahoo.com>
*/

#ifndef _CONFIG_H_
#define _CONFIG_H_

/*@{*/ 
/** Defines */
/** How many times should we try detecting the interface with the default route
 * (in seconds).  If set to 0, it will keep retrying forever */
#define NUM_EXT_INTERFACE_DETECT_RETRY 0
/** How often should we try to detect the interface with the default route
 *  if it isn't up yet (interval in seconds) */
#define EXT_INTERFACE_DETECT_RETRY_INTERVAL 1

/** Defaults configuration values */
#ifndef SYSCONFDIR
	#define DEFAULT_CONFIGFILE "/etc/wifidog.conf"
	#define DEFAULT_HTMLMSGFILE "/etc/wifidog-msg.html"
#else
	#define DEFAULT_CONFIGFILE SYSCONFDIR"/wifidog.conf"
	#define DEFAULT_HTMLMSGFILE SYSCONFDIR"/wifidog-msg.html"
#endif	
#define DEFAULT_DAEMON 1
#define DEFAULT_DEBUGLEVEL LOG_INFO
#define DEFAULT_HTTPDMAXCONN 10
#define DEFAULT_GATEWAYID NULL
#define DEFAULT_GATEWAYPORT 2060
#define DEFAULT_HTTPDNAME "WiFiDog"
#define DEFAULT_CLIENTTIMEOUT 5
#define DEFAULT_CHECKINTERVAL 60
#define DEFAULT_LOG_SYSLOG 0
#define DEFAULT_SYSLOG_FACILITY LOG_DAEMON
#define DEFAULT_WDCTL_SOCK "/tmp/wdctl.sock"
#define DEFAULT_INTERNAL_SOCK "/tmp/wifidog.sock"
#define DEFAULT_AUTHSERVPORT 80
#define DEFAULT_AUTHSERVSSLPORT 443
/** Note that DEFAULT_AUTHSERVSSLAVAILABLE must be 0 or 1, even if the config file syntax is yes or no */
#define DEFAULT_AUTHSERVSSLAVAILABLE 0
/** Note:  The path must be prefixed by /, and must be suffixed /.  Put / for the server root.*/
#define DEFAULT_AUTHSERVPATH "/wifidog/"
#define DEFAULT_AUTHSERVLOGINPATHFRAGMENT "login/?"
#define DEFAULT_AUTHSERVPORTALPATHFRAGMENT "portal/?"
#define DEFAULT_AUTHSERVMSGPATHFRAGMENT "gw_message.php?"
#define DEFAULT_AUTHSERVPINGPATHFRAGMENT "ping/?"
#define DEFAULT_AUTHSERVAUTHPATHFRAGMENT "auth/?"
/*@}*/ 

/**
 * Information about the authentication server
 */
typedef struct _auth_serv_t {
    char *authserv_hostname;	/**< @brief Hostname of the central server */
    char *authserv_path;	/**< @brief Path where wifidog resides */
    char *authserv_login_script_path_fragment;	/**< @brief This is the script the user will be sent to for login. */
    char *authserv_portal_script_path_fragment;	/**< @brief This is the script the user will be sent to after a successfull login. */
    char *authserv_msg_script_path_fragment;	/**< @brief This is the script the user will be sent to upon error to read a readable message. */
    char *authserv_ping_script_path_fragment;	/**< @brief This is the ping heartbeating script. */
    char *authserv_auth_script_path_fragment;	/**< @brief This is the script that talks the wifidog gateway protocol. */
    int authserv_http_port;	/**< @brief Http port the central server
				     listens on */
    int authserv_ssl_port;	/**< @brief Https port the central server
				     listens on */
    int authserv_use_ssl;	/**< @brief Use SSL or not */
    char *last_ip;	/**< @brief Last ip used by authserver */
    struct _auth_serv_t *next;
} t_auth_serv;

/**
 * Firewall targets
 */
typedef enum {
    TARGET_DROP,
    TARGET_REJECT,
    TARGET_ACCEPT,
    TARGET_LOG,
    TARGET_ULOG
} t_firewall_target;

/**
 * Firewall rules
 */
typedef struct _firewall_rule_t {
    t_firewall_target target;	/**< @brief t_firewall_target */
    char *protocol;		/**< @brief tcp, udp, etc ... */
    char *port;			/**< @brief Port to block/allow */
    char *mask;			/**< @brief Mask for the rule *destination* */
    struct _firewall_rule_t *next;
} t_firewall_rule;

/**
 * Firewall rulesets
 */
typedef struct _firewall_ruleset_t {
    char			*name;
    t_firewall_rule		*rules;
    struct _firewall_ruleset_t	*next;
} t_firewall_ruleset;

/**
 * Trusted MAC Addresses
 */
typedef struct _trusted_mac_t {
    char   *mac;
    struct _trusted_mac_t *next;
} t_trusted_mac;

/**
 * Configuration structure
 */
typedef struct {
    char configfile[255];	/**< @brief name of the config file */
    char *htmlmsgfile;		/**< @brief name of the HTML file used for messages */
    char *wdctl_sock;		/**< @brief wdctl path to socket */
    char *internal_sock;		/**< @brief internal path to socket */
    int daemon;			/**< @brief if daemon > 0, use daemon mode */
    int debuglevel;		/**< @brief Debug information verbosity */
    char *external_interface;	/**< @brief External network interface name for
				     firewall rules */
    char *gw_id;		/**< @brief ID of the Gateway, sent to central
				     server */
    char *gw_interface;		/**< @brief Interface we will accept connections on */
    char *gw_address;		/**< @brief Internal IP address for our web
				     server */
    int gw_port;		/**< @brief Port the webserver will run on */
    
    t_auth_serv	*auth_servers;	/**< @brief Auth servers list */
    char *httpdname;		/**< @brief Name the web server will return when
				     replying to a request */
    int httpdmaxconn;		/**< @brief Used by libhttpd, not sure what it
				     does */
    char *httpdrealm;		/**< @brief HTTP Authentication realm */
    char *httpdusername;	/**< @brief Username for HTTP authentication */
    char *httpdpassword;	/**< @brief Password for HTTP authentication */
    int clienttimeout;		/**< @brief How many CheckIntervals before a client
				     must be re-authenticated */
    int checkinterval;		/**< @brief Frequency the the client timeout check
				     thread will run. */
    int log_syslog;		/**< @brief boolean, wether to log to syslog */
    int syslog_facility;	/**< @brief facility to use when using syslog for
				     logging */
    int proxy_port;		/**< @brief Transparent proxy port (0 to disable) */
    t_firewall_ruleset	*rulesets;	/**< @brief firewall rules */
    t_trusted_mac *trustedmaclist; /**< @brief list of trusted macs */
} s_config;

/** @brief Get the current gateway configuration */
s_config *config_get_config(void);

/** @brief Initialise the conf system */
void config_init(void);

/** @brief Initialize the variables we override with the command line*/
void config_init_override(void);

/** @brief Reads the configuration file */
void config_read(const char *filename);

/** @brief Check that the configuration is valid */
void config_validate(void);

/** @brief Get the active auth server */
t_auth_serv *get_auth_server(void);

/** @brief Bump server to bottom of the list */
void mark_auth_server_bad(t_auth_serv *);

/** @brief Fetch a firewall rule set. */
t_firewall_rule *get_ruleset(const char *);

void parse_trusted_mac_list(const char *);

#define LOCK_CONFIG() do { \
	debug(LOG_DEBUG, "Locking config"); \
	pthread_mutex_lock(&config_mutex); \
	debug(LOG_DEBUG, "Config locked"); \
} while (0)

#define UNLOCK_CONFIG() do { \
	debug(LOG_DEBUG, "Unlocking config"); \
	pthread_mutex_unlock(&config_mutex); \
	debug(LOG_DEBUG, "Config unlocked"); \
} while (0)

#endif /* _CONFIG_H_ */
