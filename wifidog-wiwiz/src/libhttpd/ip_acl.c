/*
** Copyright (c) 2002  Hughes Technologies Pty Ltd.  All rights
** reserved.
**
** Terms under which this software may be used or copied are
** provided in the  specific license associated with this product.
**
** Hughes Technologies disclaims all warranties with regard to this
** software, including all implied warranties of merchantability and
** fitness, in no event shall Hughes Technologies be liable for any
** special, indirect or consequential damages or any damages whatsoever
** resulting from loss of use, data or profits, whether in an action of
** contract, negligence or other tortious action, arising out of or in
** connection with the use or performance of this software.
**
**
** $Id$
**
*/

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#else
#include <unistd.h>
#endif

#include "httpd.h"
#include "httpd_priv.h"


/**************************************************************************
** GLOBAL VARIABLES
**************************************************************************/


/**************************************************************************
** PRIVATE ROUTINES
**************************************************************************/

static int scanCidr(val, result, length)
	char	*val;
	u_int	*result,
		*length;
{
	u_int	res, res1, res2, res3, res4, res5;
	char	*cp;

	cp = val;
	res1 = atoi(cp);
	cp = strchr(cp,'.');
	if (!cp)
		return(-1);
	cp++;
	res2 = atoi(cp);
	cp = strchr(cp,'.');
	if (!cp)
		return(-1);
	cp++;
	res3 = atoi(cp);
	cp = strchr(cp,'.');
	if (!cp)
		return(-1);
	cp++;
	res4 = atoi(cp);
	cp = strchr(cp,'/');
	if (!cp)
	{
		res5 = 32;
	}
	else
	{
		cp++;
		res5 = atoi(cp);
	}

	if (res1>255 || res2>255 || res3>255 || res4>255 || res5>32)
	{
		return(-1);
	}
	res = (res1 << 24) + (res2 << 16) + (res3 << 8) + res4;
	*result = res;
	*length = res5;
	return(0);
}


static int _isInCidrBlock(httpd *server, request *r, int addr1, int len1,
		int addr2, int len2)
{
	int	count,
		mask;

	/* if (addr1 == 0 && len1 == 0)
	{
		return(1);
	}*/

	if(len2 < len1)
	{
		_httpd_writeErrorLog(server, r, LEVEL_ERROR,
		    "IP Address must be more specific than network block");
		return(0);
	}

	mask = count = 0;
	while(count < len1)
	{
		mask = (mask << 1) + 1;
		count++;
	}
	mask = mask << (32 - len1);
	if ( (addr1 & mask) == (addr2 & mask))
	{
		return(1);
	}
	else
	{
		return(0);
	}
}


/**************************************************************************
** PUBLIC ROUTINES
**************************************************************************/

httpAcl *httpdAddAcl(server, acl, cidr, action)
	httpd	*server;
	httpAcl	*acl;
        char	*cidr;
	int	action;
{
	httpAcl	*cur;
	int	addr,
		len;

	/*
	** Check the ACL info is reasonable
	*/
	if(scanCidr(cidr, &addr, &len) < 0)
	{
		_httpd_writeErrorLog(server, NULL, LEVEL_ERROR,
			"Invalid IP address format");
		return(NULL);
	}
	if (action != HTTP_ACL_PERMIT && action != HTTP_ACL_DENY)
	{
		_httpd_writeErrorLog(server, NULL, LEVEL_ERROR,
			"Invalid acl action");
		return(NULL);
	}

	/*
	** Find a spot to put this ACE
	*/	
	if (acl)
	{
		cur = acl;
		while(cur->next)
		{
			cur = cur->next;
		}
		cur->next = (httpAcl*)malloc(sizeof(httpAcl));
		cur = cur->next;
	}
	else
	{
		cur = (httpAcl*)malloc(sizeof(httpAcl));
		acl = cur;
	}

	/*
	** Add the details and return
	*/
	cur->addr = addr;
	cur->len = len;
	cur->action = action;
	cur->next = NULL;
	return(acl);
}


int httpdCheckAcl(httpd *server, request *r, httpAcl *acl)
{
	httpAcl	*cur;
	int	addr, len,
		res,
		action;


	action = HTTP_ACL_DENY;
	scanCidr(r->clientAddr, &addr, &len);
	cur = acl;
	while(cur)
	{
		res = _isInCidrBlock(server, r, cur->addr, cur->len, addr, len);
		if (res == 1)
		{
			action = cur->action;
			break;
		}
		cur = cur->next;
	}
	if (action == HTTP_ACL_DENY)
	{
		_httpd_send403(r);
		_httpd_writeErrorLog(server, r, LEVEL_ERROR,
    			"Access denied by ACL");
	}
	return(action);
}


void httpdSetDefaultAcl(server, acl)
	httpd	*server;
	httpAcl	*acl;
{
	server->defaultAcl = acl;
}
