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
/** @file commandline.c
    @brief Command line argument handling
    @author Copyright (C) 2004 Philippe April <papril777@yahoo.com>
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <syslog.h>

#include "debug.h"
#include "safe.h"
#include "conf.h"

#include "../config.h"

/*
 * Holds an argv that could be passed to exec*() if we restart ourselves
 */
char ** restartargv = NULL;

static void usage(void);

/*
 * A flag to denote whether we were restarted via a parent wifidog, or started normally
 * 0 means normally, otherwise it will be populated by the PID of the parent
 */
pid_t restart_orig_pid = 0;

/** @internal
 * @brief Print usage
 *
 * Prints usage, called when wifidog is run with -h or with an unknown option
 */
static void
usage(void)
{
    printf("Usage: wifidog [options]\n");
    printf("\n");
    printf("  -c [filename] Use this config file\n");
    printf("  -f            Run in foreground\n");
    printf("  -d <level>    Debug level\n");
    printf("  -s            Log to syslog\n");
    printf("  -w <path>     Wdctl socket path\n");
    printf("  -h            Print usage\n");
    printf("  -v            Print version information\n");
    printf("  -x pid        Used internally by WiFiDog when re-starting itself *DO NOT ISSUE THIS SWITCH MANUAlLY*\n");
    printf("  -i <path>     Internal socket path used when re-starting self\n");
    printf("  Wiwiz Patched Version 1\n");	/* wiwiz */
    printf("\n");
}

/** Uses getopt() to parse the command line and set configuration values
 * also populates restartargv
 */
void parse_commandline(int argc, char **argv) {
    int c;
	 int skiponrestart;
	 int i;

    s_config *config = config_get_config();

	//MAGIC 3: Our own -x, the pid, and NULL :
	restartargv = safe_malloc((argc + 3) * sizeof(char*));
	i=0;
	restartargv[i++] = safe_strdup(argv[0]);

    while (-1 != (c = getopt(argc, argv, "c:hfd:sw:vx:i:"))) {

		skiponrestart = 0;

		switch(c) {

			case 'h':
				usage();
				exit(1);
				break;

			case 'c':
				if (optarg) {
					strncpy(config->configfile, optarg, sizeof(config->configfile));
				}
				break;

			case 'w':
				if (optarg) {
					free(config->wdctl_sock);
					config->wdctl_sock = safe_strdup(optarg);
				}
				break;

			case 'f':
				skiponrestart = 1;
				config->daemon = 0;
				break;

			case 'd':
				if (optarg) {
					config->debuglevel = atoi(optarg);
				}
				break;

			case 's':
				config->log_syslog = 1;
				break;

			case 'v':
				printf("This is WiFiDog version " VERSION "-wiwiz\n");
				exit(1);
				break;

			case 'x':
				skiponrestart = 1;
				if (optarg) {
					restart_orig_pid = atoi(optarg);
				}
				else {
					printf("The expected PID to the -x switch was not supplied!");
					exit(1);
				}
				break;

			case 'i':
				if (optarg) {
					free(config->internal_sock);
					config->internal_sock = safe_strdup(optarg);
				}
				break;

			default:
				usage();
				exit(1);
				break;

		}

		if (!skiponrestart) {
			/* Add it to restartargv */
			safe_asprintf(&(restartargv[i++]), "-%c", c);
			if (optarg) {
				restartargv[i++] = safe_strdup(optarg);
			}
		}

	}

	/* Finally, we should add  the -x, pid and NULL to restartargv
	 * HOWEVER we cannot do it here, since this is called before we fork to background
	 * so we'll leave this job to gateway.c after forking is completed
	 * so that the correct PID is assigned
	 *
	 * We add 3 nulls, and the first 2 will be overridden later
	 */
	restartargv[i++] = NULL;
	restartargv[i++] = NULL;
	restartargv[i++] = NULL;

}

