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

/** @file httpd_thread.c
    @brief Handles on web request.
    @author Copyright (C) 2004 Alexandre Carmel-Veilleux <acv@acv.ca>
*/

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <syslog.h>
#include <signal.h>
#include <errno.h>

#include "httpd.h"

#include "../config.h"
#include "common.h"
#include "debug.h"
#include "httpd_thread.h"

/** Main request handling thread.
@param args Two item array of void-cast pointers to the httpd and request struct
*/
void
thread_httpd(void *args)
{
	void	**params;
	httpd	*webserver;
	request	*r;
	
	params = (void **)args;
	webserver = *params;
	r = *(params + 1);
	free(params); /* XXX We must release this ourselves. */
	
	if (httpdReadRequest(webserver, r) == 0) {
		/*
		 * We read the request fine
		 */
		debug(LOG_DEBUG, "Processing request from %s", r->clientAddr);
		debug(LOG_DEBUG, "Calling httpdProcessRequest() for %s", r->clientAddr);
		httpdProcessRequest(webserver, r);
		debug(LOG_DEBUG, "Returned from httpdProcessRequest() for %s", r->clientAddr);
	}
	else {
		debug(LOG_DEBUG, "No valid request received from %s", r->clientAddr);
	}
	debug(LOG_DEBUG, "Closing connection with %s", r->clientAddr);
	httpdEndRequest(r);
}
