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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#if defined(_WIN32)
#include <winsock2.h>
#else
#include <unistd.h> 
#include <sys/file.h>
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <netdb.h>
#include <sys/socket.h> 
#include <netdb.h>
#endif

#include "config.h"
#include "httpd.h"
#include "httpd_priv.h"

#ifdef HAVE_STDARG_H
#  include <stdarg.h>
#else
#  include <varargs.h>
#endif


char *httpdUrlEncode(str)
	const char	*str;
{
        char    *new,
                *cp;

        new = (char *)_httpd_escape(str);
	if (new == NULL)
	{
		return(NULL);
	}
        cp = new;
        while(*cp)
        {
                if (*cp == ' ')
                        *cp = '+';
                cp++;
        }
	return(new);
}



char *httpdRequestMethodName(request *r)
{
	static	char	tmpBuf[255];

	switch(r->request.method)
	{
		case HTTP_GET: return("GET");
		case HTTP_POST: return("POST");
		default: 
			snprintf(tmpBuf,255,"Invalid method '%d'", 
				r->request.method);
			return(tmpBuf);
	}
}


httpVar *httpdGetVariableByName(request *r, const char *name)
{
	httpVar	*curVar;

	curVar = r->variables;
	while(curVar)
	{
		if (strcmp(curVar->name, name) == 0)
			return(curVar);
		curVar = curVar->nextVariable;
	}
	return(NULL);
}



httpVar *httpdGetVariableByPrefix(request *r, const char *prefix)
{
	httpVar	*curVar;

	if (prefix == NULL)
		return(r->variables);
	curVar = r->variables;
	while(curVar)
	{
		if (strncmp(curVar->name, prefix, strlen(prefix)) == 0)
			return(curVar);
		curVar = curVar->nextVariable;
	}
	return(NULL);
}


httpVar *httpdGetVariableByPrefixedName(request *r, const char *prefix, const char *name)
{
	httpVar	*curVar;
	int	prefixLen;

	if (prefix == NULL)
		return(r->variables);
	curVar = r->variables;
	prefixLen = strlen(prefix);
	while(curVar)
	{
		if (strncmp(curVar->name, prefix, prefixLen) == 0 &&
			strcmp(curVar->name + prefixLen, name) == 0)
		{
			return(curVar);
		}
		curVar = curVar->nextVariable;
	}
	return(NULL);
}


httpVar *httpdGetNextVariableByPrefix(curVar, prefix)
	httpVar	*curVar;
	const char	*prefix;
{
	if(curVar)
		curVar = curVar->nextVariable;
	while(curVar)
	{
		if (strncmp(curVar->name, prefix, strlen(prefix)) == 0)
			return(curVar);
		curVar = curVar->nextVariable;
	}
	return(NULL);
}


int httpdAddVariable(request *r, const char *name, const char *value)
{
	httpVar *curVar, *lastVar, *newVar;

	while(*name == ' ' || *name == '\t')
		name++;
	newVar = malloc(sizeof(httpVar));
	bzero(newVar, sizeof(httpVar));
	newVar->name = strdup(name);
	newVar->value = strdup(value);
	lastVar = NULL;
	curVar = r->variables;
	while(curVar)
	{
		if (strcmp(curVar->name, name) != 0)
		{
			lastVar = curVar;
			curVar = curVar->nextVariable;
			continue;
		}
		while(curVar)
		{
			lastVar = curVar;
			curVar = curVar->nextValue;
		}
		lastVar->nextValue = newVar;
		return(0);
	}
	if (lastVar)
		lastVar->nextVariable = newVar;
	else
		r->variables = newVar;
	return(0);
}

httpd *httpdCreate(host, port)
	char	*host;
	int	port;
{
	httpd	*new;
	int	sock,
		opt;
        struct  sockaddr_in     addr;

	/*
	** Create the handle and setup it's basic config
	*/
	new = malloc(sizeof(httpd));
	if (new == NULL)
		return(NULL);
	bzero(new, sizeof(httpd));
	new->port = port;
	if (host == HTTP_ANY_ADDR)
		new->host = HTTP_ANY_ADDR;
	else
		new->host = strdup(host);
	new->content = (httpDir*)malloc(sizeof(httpDir));
	bzero(new->content,sizeof(httpDir));
	new->content->name = strdup("");

	/*
	** Setup the socket
	*/
#ifdef _WIN32
	{ 
	WORD 	wVersionRequested;
	WSADATA wsaData;
	int 	err;

	wVersionRequested = MAKEWORD( 2, 2 );

	err = WSAStartup( wVersionRequested, &wsaData );
	
	/* Found a usable winsock dll? */
	if( err != 0 ) 
	   return NULL;

	/* 
	** Confirm that the WinSock DLL supports 2.2.
	** Note that if the DLL supports versions greater 
	** than 2.2 in addition to 2.2, it will still return
	** 2.2 in wVersion since that is the version we
	** requested.
	*/

	if( LOBYTE( wsaData.wVersion ) != 2 || 
	    HIBYTE( wsaData.wVersion ) != 2 ) {

		/* 
		** Tell the user that we could not find a usable
		** WinSock DLL.
		*/
		WSACleanup( );
		return NULL;
	}

	/* The WinSock DLL is acceptable. Proceed. */
 	}
#endif

	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock  < 0)
	{
		free(new);
		return(NULL);
	}
#	ifdef SO_REUSEADDR
	opt = 1;
	setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt,sizeof(int));
#	endif
	new->serverSock = sock;
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	if (new->host == HTTP_ANY_ADDR)
	{
		addr.sin_addr.s_addr = htonl(INADDR_ANY);
	}
	else
	{
		addr.sin_addr.s_addr = inet_addr(new->host);
	}
	addr.sin_port = htons((u_short)new->port);
	if (bind(sock,(struct sockaddr *)&addr,sizeof(addr)) <0)
	{
		close(sock);
		free(new);
		return(NULL);
	}
	listen(sock, 128);
	new->startTime = time(NULL);
	return(new);
}

void httpdDestroy(server)
	httpd	*server;
{
	if (server == NULL)
		return;
	if (server->host)
		free(server->host);
	free(server);
}



request *httpdGetConnection(server, timeout)
	httpd	*server;
	struct	timeval *timeout;
{
	int		result;
	fd_set		fds;
	struct  	sockaddr_in     addr;
	socklen_t	addrLen;
	char		*ipaddr;
	request		*r;

	FD_ZERO(&fds);
	FD_SET(server->serverSock, &fds);
	result = 0;
	while(result == 0)
	{
		result = select(server->serverSock + 1, &fds, 0, 0, timeout);
		if (result < 0)
		{
			server->lastError = -1;
			return(NULL);
		}
		if (timeout != 0 && result == 0)
		{
			return(NULL);
			server->lastError = 0;
		}
		if (result > 0)
		{
			break;
		}
	}
	/* Allocate request struct */
	r = (request *)malloc(sizeof(request));
	if (r == NULL) {
		server->lastError = -3;
		return(NULL);
	}
	memset((void *)r, 0, sizeof(request));
	/* Get on with it */
	bzero(&addr, sizeof(addr));
	addrLen = sizeof(addr);
	r->clientSock = accept(server->serverSock,(struct sockaddr *)&addr,
		&addrLen);
	ipaddr = inet_ntoa(addr.sin_addr);
	if (ipaddr) {
		strncpy(r->clientAddr, ipaddr, HTTP_IP_ADDR_LEN);
                r->clientAddr[HTTP_IP_ADDR_LEN-1]=0;
        } else
		*r->clientAddr = 0;
	r->readBufRemain = 0;
	r->readBufPtr = NULL;

	/*
	** Check the default ACL
	*/
	if (server->defaultAcl)
	{
		if (httpdCheckAcl(server, r, server->defaultAcl)
				== HTTP_ACL_DENY)
		{
			httpdEndRequest(r);
			server->lastError = 2;
			return(NULL);
		}
	}
	return(r);
}



int httpdReadRequest(httpd *server, request *r)
{
	static	char	buf[HTTP_MAX_LEN];
	int	count,
		inHeaders;
	char	*cp, *cp2;
	int	_httpd_decode();


	/*
	** Setup for a standard response
	*/
	strcpy(r->response.headers,
		"Server: Hughes Technologies Embedded Server\n"); 
	strcpy(r->response.contentType, "text/html");
	strcpy(r->response.response,"200 Output Follows\n");
	r->response.headersSent = 0;


	/*
	** Read the request
	*/
	count = 0;
	inHeaders = 1;
	while(_httpd_readLine(r, buf, HTTP_MAX_LEN) > 0)
	{
		count++;

		/*
		** Special case for the first line.  Scan the request
		** method and path etc
		*/
		if (count == 1)
		{
			/*
			** First line.  Scan the request info
			*/
			cp = cp2 = buf;
			while(isalpha((unsigned char)*cp2))
				cp2++;
			*cp2 = 0;
			if (strcasecmp(cp,"GET") == 0)
				r->request.method = HTTP_GET;
			if (strcasecmp(cp,"POST") == 0)
				r->request.method = HTTP_POST;
			if (r->request.method == 0)
			{
				_httpd_net_write( r->clientSock,
				      HTTP_METHOD_ERROR,
				      strlen(HTTP_METHOD_ERROR));
				_httpd_net_write( r->clientSock, cp, 
				      strlen(cp));
				_httpd_writeErrorLog(server, r, LEVEL_ERROR, 
					"Invalid method received");
				return(-1);
			}
			cp = cp2+1;
			while(*cp == ' ')
				cp++;
			cp2 = cp;
			while(*cp2 != ' ' && *cp2 != 0)
				cp2++;
			*cp2 = 0;
			strncpy(r->request.path,cp,HTTP_MAX_URL);
                        r->request.path[HTTP_MAX_URL-1]=0;
			_httpd_sanitiseUrl(r->request.path);
			continue;
		}

		/*
		** Process the headers
		*/
		if (inHeaders)
		{
			if (*buf == 0)
			{
				/*
				** End of headers.  Continue if there's
				** data to read
				*/
				if (r->request.contentLength == 0)
					break;
				inHeaders = 0;
				break;
			}
#if 0
            /**
             * Philippe commenting this out, it crashed with a
             * particular pattern sent from the browser
             * and we don't need it
			if (strncasecmp(buf,"Cookie: ",7) == 0)
			{
				char	*var,
					*val,
					*end;

				var = strchr(buf,':');
				while(var)
				{
					var++;
					val = strchr(var, '=');
					*val = 0;
					val++;
					end = strchr(val,';');
					if(end)
						*end = 0;
					httpdAddVariable(r, var, val);
					var = end;
				}
			}
			*/
#endif
			if (strncasecmp(buf,"Authorization: ",15) == 0)
			{
				cp = strchr(buf,':') + 2;
				if (strncmp(cp,"Basic ", 6) != 0)
				{
					/* Unknown auth method */
				}
				else
				{
					char 	authBuf[100];

					cp = strchr(cp,' ') + 1;
					_httpd_decode(cp, authBuf, 100);
					r->request.authLength = 
						strlen(authBuf);
					cp = strchr(authBuf,':');
					if (cp)
					{
						*cp = 0;
						strncpy(
						   r->request.authPassword,
						   cp+1, HTTP_MAX_AUTH);
                                                r->request.authPassword[HTTP_MAX_AUTH-1]=0;
					}
					strncpy(r->request.authUser, 
						authBuf, HTTP_MAX_AUTH);
					r->request.authUser[HTTP_MAX_AUTH-1]=0;
				}
			}
#if 0
			if (strncasecmp(buf,"Referer: ",9) == 0)
			{
				cp = strchr(buf,':') + 2;
				if(cp)
				{
					strncpy(r->request.referer,cp,
						HTTP_MAX_URL);
					r->request.referer[HTTP_MAX_URL-1]=0;
				}
			}
#endif
			/* acv@acv.ca/wifidog: Added decoding of host: if
			 * present. */
			if (strncasecmp(buf,"Host: ",6) == 0)
			{
				cp = strchr(buf,':');
				if(cp)
				{
					cp += 2;
					strncpy(r->request.host,cp,
						HTTP_MAX_URL);
					r->request.host[HTTP_MAX_URL-1]=0;
				}
			}
			/* End modification */
#if 0
			if (strncasecmp(buf,"If-Modified-Since: ",19) == 0)
			{
				cp = strchr(buf,':') + 2;
				if(cp)
				{
					strncpy(r->request.ifModified,cp,
						HTTP_MAX_URL);
					r->request.ifModified[HTTP_MAX_URL-1]=0;
					cp = strchr(r->request.ifModified,
						';');
					if (cp)
						*cp = 0;
				}
			}
			if (strncasecmp(buf,"Content-Type: ",14) == 0)
			{
				cp = strchr(buf,':') + 2;
				if(cp)
				{
					strncpy(r->request.contentType,cp,
						HTTP_MAX_URL);
					r->request.contentType[HTTP_MAX_URL-1]=0;
				}
			}
			if (strncasecmp(buf,"Content-Length: ",16) == 0)
			{
				cp = strchr(buf,':') + 2;
				if(cp)
					r->request.contentLength=atoi(cp);
			}
#endif
			continue;
		}
	}


#if 0
	/* XXX: For WifiDog, we only process the query string parameters
	   but keep the GET variables in the request.query!
	*/
	/*
	** Process and POST data
	*/
	if (r->request.contentLength > 0)
	{
		bzero(buf, HTTP_MAX_LEN);
		_httpd_readBuf(r, buf, r->request.contentLength);
		_httpd_storeData(r, buf);
		
	}
#endif

	/*
	** Process any URL data
	*/
	cp = strchr(r->request.path,'?');
	if (cp != NULL)
	{
		*cp++ = 0;
		strncpy(r->request.query, cp, sizeof(r->request.query));
		r->request.query[sizeof(r->request.query)-1]=0;
		_httpd_storeData(r, cp);
	}

	return(0);
}


void httpdEndRequest(request *r)
{
	_httpd_freeVariables(r->variables);
	shutdown(r->clientSock,2);
	close(r->clientSock);
	free(r);
}


void httpdFreeVariables(request *r)
{
        _httpd_freeVariables(r->variables);
}



void httpdDumpVariables(request *r)
{
	httpVar	*curVar,
		*curVal;

	curVar = r->variables;
	while(curVar)
	{
		printf("Variable '%s'\n", curVar->name);
		curVal = curVar;
		while(curVal)
		{
			printf("\t= '%s'\n",curVal->value);
			curVal = curVal->nextValue;
		}
		curVar = curVar->nextVariable;
	}
}

void httpdSetFileBase(server, path)
	httpd	*server;
	const char	*path;
{
	strncpy(server->fileBasePath, path, HTTP_MAX_URL);
	server->fileBasePath[HTTP_MAX_URL-1]=0;
}


int httpdAddFileContent(server, dir, name, indexFlag, preload, path)
	httpd	*server;
	char	*dir,
		*name;
	int	(*preload)();
	int	indexFlag;
	char	*path;
{
	httpDir	*dirPtr;
	httpContent *newEntry;

	dirPtr = _httpd_findContentDir(server, dir, HTTP_TRUE);
	newEntry =  malloc(sizeof(httpContent));
	if (newEntry == NULL)
		return(-1);
	bzero(newEntry,sizeof(httpContent));
	newEntry->name = strdup(name);
	newEntry->type = HTTP_FILE;
	newEntry->indexFlag = indexFlag;
	newEntry->preload = preload;
	newEntry->next = dirPtr->entries;
	dirPtr->entries = newEntry;
	if (*path == '/')
	{
		/* Absolute path */
		newEntry->path = strdup(path);
	}
	else
	{
		/* Path relative to base path */
		newEntry->path = malloc(strlen(server->fileBasePath) +
			strlen(path) + 2);
		snprintf(newEntry->path, HTTP_MAX_URL, "%s/%s",
			server->fileBasePath, path);
	}
	return(0);
}



int httpdAddWildcardContent(server, dir, preload, path)
	httpd	*server;
	char	*dir;
	int	(*preload)();
	char	*path;
{
	httpDir	*dirPtr;
	httpContent *newEntry;

	dirPtr = _httpd_findContentDir(server, dir, HTTP_TRUE);
	newEntry =  malloc(sizeof(httpContent));
	if (newEntry == NULL)
		return(-1);
	bzero(newEntry,sizeof(httpContent));
	newEntry->name = NULL;
	newEntry->type = HTTP_WILDCARD;
	newEntry->indexFlag = HTTP_FALSE;
	newEntry->preload = preload;
	newEntry->next = dirPtr->entries;
	dirPtr->entries = newEntry;
	if (*path == '/')
	{
		/* Absolute path */
		newEntry->path = strdup(path);
	}
	else
	{
		/* Path relative to base path */
		newEntry->path = malloc(strlen(server->fileBasePath) +
			strlen(path) + 2);
		snprintf(newEntry->path, HTTP_MAX_URL, "%s/%s",
			server->fileBasePath, path);
	}
	return(0);
}




int httpdAddC404Content(server, function)
	httpd	*server;
	void	(*function)();
{
	if (!server->handle404) {
		server->handle404 = (http404*)malloc(sizeof(http404));
	}

	if (!server->handle404) {
		return(-1);
	}

	server->handle404->function = function;
	return(0);
}

int httpdAddCContent(server, dir, name, indexFlag, preload, function)
	httpd	*server;
	char	*dir;
	char	*name;
	int	(*preload)();
	void	(*function)();
{
	httpDir	*dirPtr;
	httpContent *newEntry;

		dirPtr = _httpd_findContentDir(server, dir, HTTP_TRUE);
	newEntry =  malloc(sizeof(httpContent));
	if (newEntry == NULL)
		return(-1);
	bzero(newEntry,sizeof(httpContent));
	newEntry->name = strdup(name);
	newEntry->type = HTTP_C_FUNCT;
	newEntry->indexFlag = indexFlag;
	newEntry->function = function;
	newEntry->preload = preload;
	newEntry->next = dirPtr->entries;
	dirPtr->entries = newEntry;
	return(0);
}


int httpdAddCWildcardContent(server, dir, preload, function)
	httpd	*server;
	char	*dir;
	int	(*preload)();
	void	(*function)();
{
	httpDir	*dirPtr;
	httpContent *newEntry;

	dirPtr = _httpd_findContentDir(server, dir, HTTP_TRUE);
	newEntry =  malloc(sizeof(httpContent));
	if (newEntry == NULL)
		return(-1);
	bzero(newEntry,sizeof(httpContent));
	newEntry->name = NULL;
	newEntry->type = HTTP_C_WILDCARD;
	newEntry->indexFlag = HTTP_FALSE;
	newEntry->function = function;
	newEntry->preload = preload;
	newEntry->next = dirPtr->entries;
	dirPtr->entries = newEntry;
	return(0);
}

int httpdAddStaticContent(server, dir, name, indexFlag, preload, data)
	httpd	*server;
	char	*dir;
	char	*name;
	int	(*preload)();
	char	*data;
{
	httpDir	*dirPtr;
	httpContent *newEntry;

	dirPtr = _httpd_findContentDir(server, dir, HTTP_TRUE);
	newEntry =  malloc(sizeof(httpContent));
	if (newEntry == NULL)
		return(-1);
	bzero(newEntry,sizeof(httpContent));
	newEntry->name = strdup(name);
	newEntry->type = HTTP_STATIC;
	newEntry->indexFlag = indexFlag;
	newEntry->data = data;
	newEntry->preload = preload;
	newEntry->next = dirPtr->entries;
	dirPtr->entries = newEntry;
	return(0);
}

void httpdSendHeaders(request *r)
{
	_httpd_sendHeaders(r, 0, 0);
}

void httpdSetResponse(request *r, const char *msg)
{
	strncpy(r->response.response, msg, HTTP_MAX_URL);
	r->response.response[HTTP_MAX_URL-1]=0;
}

void httpdSetContentType(request *r, const char *type)
{
	strcpy(r->response.contentType, type);
}


void httpdAddHeader(request *r, const char *msg)
{
	int size;
	size = HTTP_MAX_HEADERS - 2 - strlen(r->response.headers);
	if(size > 0)
	{	
		strncat(r->response.headers,msg,size);
		if (r->response.headers[strlen(r->response.headers) - 1] != '\n')
			strcat(r->response.headers,"\n");
	}
}

void httpdSetCookie(request *r, const char *name, const char *value)
{
	char	buf[HTTP_MAX_URL];

	snprintf(buf,HTTP_MAX_URL, "Set-Cookie: %s=%s; path=/;", name, value);
	httpdAddHeader(r, buf);
}

void httpdOutput(request *r, const char *msg)
{
	const char *src;
	char	buf[HTTP_MAX_LEN],
		varName[80],
		*dest;
	int	count;

	src = msg;
	dest = buf;
	count = 0;
	while(*src && count < HTTP_MAX_LEN)
	{
		if (*src == '$')
		{
			const char *tmp;
			char	*cp;
			int	count2;
			httpVar	*curVar;

			tmp = src + 1;
			cp = varName;
			count2 = 0;
			while (*tmp && (isalnum((unsigned char)*tmp) || *tmp == '_') &&
			       count2 < 80)
			{
				*cp++ = *tmp++;
				count2++;
			}
			*cp = 0;
			curVar = httpdGetVariableByName(r,varName);
			if (curVar)
			{
				strcpy(dest, curVar->value);
				dest = dest + strlen(dest);
				count += strlen(dest);
			}
			else
			{
				*dest++ = '$';
				strcpy(dest, varName);
				dest += strlen(varName);
				count += 1 + strlen(varName);
			}
			src = src + strlen(varName) + 1;
			continue;
		}
		*dest++ = *src++;
		count++;
	}	
	*dest = 0;
	r->response.responseLength += strlen(buf);
	if (r->response.headersSent == 0)
		httpdSendHeaders(r);
	_httpd_net_write( r->clientSock, buf, strlen(buf));
}



#ifdef HAVE_STDARG_H
void httpdPrintf(request *r, const char *fmt, ...)
{
#else
void httpdPrintf(va_alist)
        va_dcl
{
        request		*r;;
        const char	*fmt;
#endif
        va_list         args;
	char		buf[HTTP_MAX_LEN];

#ifdef HAVE_STDARG_H
        va_start(args, fmt);
#else
        va_start(args);
        r = (request *) va_arg(args, request * );
        fmt = (char *) va_arg(args, char *);
#endif
	if (r->response.headersSent == 0)
		httpdSendHeaders(r);
	vsnprintf(buf, HTTP_MAX_LEN, fmt, args);
	r->response.responseLength += strlen(buf);
	_httpd_net_write( r->clientSock, buf, strlen(buf));
}




void httpdProcessRequest(httpd *server, request *r)
{
	char	dirName[HTTP_MAX_URL],
		entryName[HTTP_MAX_URL],
		*cp;
	httpDir	*dir;
	httpContent *entry;

	r->response.responseLength = 0;
	strncpy(dirName, httpdRequestPath(r), HTTP_MAX_URL);
	dirName[HTTP_MAX_URL-1]=0;
	cp = strrchr(dirName, '/');
	if (cp == NULL)
	{
		printf("Invalid request path '%s'\n",dirName);
		return;
	}
	strncpy(entryName, cp + 1, HTTP_MAX_URL);
	entryName[HTTP_MAX_URL-1]=0;
	if (cp != dirName)
		*cp = 0;
	else
		*(cp+1) = 0;
	dir = _httpd_findContentDir(server, dirName, HTTP_FALSE);
	if (dir == NULL)
	{
		_httpd_send404(server, r);
		_httpd_writeAccessLog(server, r);
		return;
	}
	entry = _httpd_findContentEntry(r, dir, entryName);
	if (entry == NULL)
	{
		_httpd_send404(server, r);
		_httpd_writeAccessLog(server, r);
		return;
	}
	if (entry->preload)
	{
		if ((entry->preload)(server) < 0)
		{
			_httpd_writeAccessLog(server, r);
			return;
		}
	}
	switch(entry->type)
	{
		case HTTP_C_FUNCT:
		case HTTP_C_WILDCARD:
			(entry->function)(server, r);
			break;

		case HTTP_STATIC:
			_httpd_sendStatic(server, r, entry->data);
			break;

		case HTTP_FILE:
			_httpd_sendFile(server, r, entry->path);
			break;

		case HTTP_WILDCARD:
			if (_httpd_sendDirectoryEntry(server, r, entry,
						entryName)<0)
			{
				_httpd_send404(server, r);
			}
			break;
	}
	_httpd_writeAccessLog(server, r);
}

void httpdSetAccessLog(server, fp)
	httpd	*server;
	FILE	*fp;
{
	server->accessLog = fp;
}

void httpdSetErrorLog(server, fp)
	httpd	*server;
	FILE	*fp;
{
	server->errorLog = fp;
}

void httpdAuthenticate(request *r, const char *realm)
{
	char	buffer[255];

	if (r->request.authLength == 0)
	{
		httpdSetResponse(r, "401 Please Authenticate");
		snprintf(buffer,sizeof(buffer), 
			"WWW-Authenticate: Basic realm=\"%s\"\n", realm);
		httpdAddHeader(r, buffer);
		httpdOutput(r,"\n");
	}
}


void httpdForceAuthenticate(request *r, const char *realm)
{
	char	buffer[255];

	httpdSetResponse(r, "401 Please Authenticate");
	snprintf(buffer,sizeof(buffer), 
		"WWW-Authenticate: Basic realm=\"%s\"\n", realm);
	httpdAddHeader(r, buffer);
	httpdOutput(r,"\n");
}
