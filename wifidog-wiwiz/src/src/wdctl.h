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
/** @file wdctl.h
    @brief WiFiDog monitoring client
    @author Copyright (C) 2004 Alexandre Carmel-Veilleux <acv@acv.ca>
*/

#ifndef _WDCTL_H_
#define _WDCTL_H_

#define DEFAULT_SOCK	"/tmp/wdctl.sock"

#define WDCTL_UNDEF		0
#define WDCTL_STATUS		1
#define WDCTL_STOP		2
#define WDCTL_KILL		3
#define WDCTL_RESTART	4
#define WDCTL_AUTH		9	/* by Wiwiz */
#define WDCTL_SLEEP		10	/* by Wiwiz */

typedef struct {
	char	*socket;
	int	command;
	char	*param;
} s_config;
#endif
