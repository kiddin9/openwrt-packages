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
/** @file auth.h
    @brief Authentication handling thread
    @author Copyright (C) 2004 Alexandre Carmel-Veilleux <acv@miniguru.ca>
*/

#ifndef _AUTH_H_
#define _AUTH_H_

#include "httpd.h"

/**
 * @brief Authentication codes returned by auth server.
 *
 * Authentication result codes returned by auth_server_request() corresponding
 * to result code from the central server itself.
 */
typedef enum {
    AUTH_ERROR = -1, /**< An error occured during the validation process*/
    AUTH_DENIED = 0, /**< Client was denied by the auth server */
    AUTH_ALLOWED = 1, /**< Client was granted access by the auth server */
    AUTH_VALIDATION = 5, /**< A misnomer.  Client is in 15 min probation to validate his new account */
    AUTH_VALIDATION_FAILED = 6, /**< Client had X minutes to validate account by email and didn't = too late */
    AUTH_LOCKED = 254 /**< Account has been locked */
} t_authcode;

/** 
 * @brief This structure contains all the information returned by the  authentication server
 */
typedef struct _t_authresponse {
    t_authcode authcode; /**< Authentication code returned by the server */
} t_authresponse;


/** @brief Authenticate a single client against the central server */
void authenticate_client(request *);

/** @brief Periodically check if connections expired */
void thread_client_timeout_check(const void *arg);

#endif
