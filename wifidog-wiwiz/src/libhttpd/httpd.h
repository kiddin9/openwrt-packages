/*
** Copyright (c) 2002  Hughes Technologies Pty Ltd.  All rights
** reserved.
**
** Terms under which this software may be used or copied are
** provided in the  specific license associated with this product.
**
** hUghes Technologies disclaims all warranties with regard to this
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

/*
**  libhttpd Header File
*/


/***********************************************************************
** Standard header preamble.  Ensure singular inclusion, setup for
** function prototypes and c++ inclusion
*/

#ifndef LIB_HTTPD_H

#define LIB_HTTPD_H 1

#include <sys/time.h>

#if !defined(__ANSI_PROTO)
#if defined(_WIN32) || defined(__STDC__) || defined(__cplusplus)
#  define __ANSI_PROTO(x)       x
#else
#  define __ANSI_PROTO(x)       ()
#endif
#endif

#ifndef u_int
#include <sys/types.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif



/***********************************************************************
** Macro Definitions
*/


#define	HTTP_PORT 		80
#define HTTP_MAX_LEN		10240
#define HTTP_MAX_URL		1024
#define HTTP_MAX_HEADERS	1024
#define HTTP_MAX_AUTH		128
#define	HTTP_IP_ADDR_LEN	17
#define	HTTP_TIME_STRING_LEN	40
#define	HTTP_READ_BUF_LEN	4096
#define	HTTP_ANY_ADDR		NULL

#define	HTTP_GET		1
#define	HTTP_POST		2

#define	HTTP_TRUE		1
#define HTTP_FALSE		0

#define	HTTP_FILE		1
#define HTTP_C_FUNCT		2
#define HTTP_EMBER_FUNCT	3
#define HTTP_STATIC		4
#define HTTP_WILDCARD		5
#define HTTP_C_WILDCARD		6

#define HTTP_METHOD_ERROR "\n<B>ERROR : Method Not Implemented</B>\n\n"

#define httpdRequestMethod(s) 		s->request.method
#define httpdRequestPath(s)		s->request.path
#define httpdRequestContentType(s)	s->request.contentType
#define httpdRequestContentLength(s)	s->request.contentLength

#define HTTP_ACL_PERMIT		1
#define HTTP_ACL_DENY		2



extern char 	LIBHTTPD_VERSION[],
		LIBHTTPD_VENDOR[];

/***********************************************************************
** Type Definitions
*/

typedef	struct {
	int	method,
		contentLength,
		authLength;
	char	path[HTTP_MAX_URL],
		query[HTTP_MAX_URL],
	        host[HTTP_MAX_URL], /* acv@acv.ca/wifidog: Added decoding
				       of host: header if present. */
	        ifModified[HTTP_MAX_URL];
#if(0)
		userAgent[HTTP_MAX_URL],
		referer[HTTP_MAX_URL],
		contentType[HTTP_MAX_URL],
#endif
	char	authUser[HTTP_MAX_AUTH];
	char	authPassword[HTTP_MAX_AUTH];
} httpReq;


typedef struct _httpd_var{
	char	*name,
		*value;
	struct	_httpd_var 	*nextValue,
				*nextVariable;
} httpVar;

typedef struct _httpd_content{
	char	*name;
	int	type,
		indexFlag;
	void	(*function)();
	char	*data,
		*path;
	int	(*preload)();
	struct	_httpd_content 	*next;
} httpContent;

typedef struct {
	int		responseLength;
	httpContent	*content;
	char		headersSent,
			headers[HTTP_MAX_HEADERS],
			response[HTTP_MAX_URL],
			contentType[HTTP_MAX_URL];
} httpRes;


typedef struct _httpd_dir{
	char	*name;
	struct	_httpd_dir *children,
			*next;
	struct	_httpd_content *entries;
} httpDir;


typedef struct ip_acl_s{
        int     addr;
        char    len,
                action;
        struct  ip_acl_s *next;
} httpAcl;

typedef struct _httpd_404 {
	void	(*function)();
} http404;

typedef struct {
	int	port,
		serverSock,
		startTime,
		lastError;
	char	fileBasePath[HTTP_MAX_URL],
		*host;
	httpDir	*content;
	httpAcl	*defaultAcl;
	http404  *handle404;
	FILE	*accessLog,
		*errorLog;
} httpd;

typedef struct {
	int	clientSock,
		readBufRemain;
	httpReq	request;
	httpRes response;
	httpVar	*variables;
	char	readBuf[HTTP_READ_BUF_LEN + 1],
		*readBufPtr,
		clientAddr[HTTP_IP_ADDR_LEN];
} request;

/***********************************************************************
** Function Prototypes
*/


int httpdAddCContent __ANSI_PROTO((httpd*,char*,char*,int,int(*)(),void(*)()));
int httpdAddFileContent __ANSI_PROTO((httpd*,char*,char*,int,int(*)(),char*));
int httpdAddStaticContent __ANSI_PROTO((httpd*,char*,char*,int,int(*)(),char*));
int httpdAddWildcardContent __ANSI_PROTO((httpd*,char*,int(*)(),char*));
int httpdAddCWildcardContent __ANSI_PROTO((httpd*,char*,int(*)(),void(*)()));
int httpdAddVariable __ANSI_PROTO((request*, const char*, const char*));
request *httpdGetConnection __ANSI_PROTO((httpd*, struct timeval*));
int httpdReadRequest __ANSI_PROTO((httpd*, request*));
int httpdCheckAcl __ANSI_PROTO((httpd*, request *, httpAcl*));
int httpdAddC404Content __ANSI_PROTO((httpd*,void(*)()));

char *httpdRequestMethodName __ANSI_PROTO((request*));
char *httpdUrlEncode __ANSI_PROTO((const char *));

void httpdAddHeader __ANSI_PROTO((request*, const char*));
void httpdSetContentType __ANSI_PROTO((request*, const char*));
void httpdSetResponse __ANSI_PROTO((request*, const char*));
void httpdEndRequest __ANSI_PROTO((request*));

httpd *httpdCreate __ANSI_PROTO(());
void httpdFreeVariables __ANSI_PROTO((request*));
void httpdDumpVariables __ANSI_PROTO((request*));
void httpdOutput __ANSI_PROTO((request*, const char*));
void httpdPrintf __ANSI_PROTO((request*, const char*, ...));
void httpdProcessRequest __ANSI_PROTO((httpd*, request *));
void httpdSendHeaders __ANSI_PROTO((request*));
void httpdSetFileBase __ANSI_PROTO((httpd*, const char*));
void httpdSetCookie __ANSI_PROTO((request*, const char*, const char*));

void httpdSetErrorLog __ANSI_PROTO((httpd*, FILE*));
void httpdSetAccessLog __ANSI_PROTO((httpd*, FILE*));
void httpdSetDefaultAcl __ANSI_PROTO((httpd*, httpAcl*));

httpVar	*httpdGetVariableByName __ANSI_PROTO((request*, const char*));
httpVar	*httpdGetVariableByPrefix __ANSI_PROTO((request*, const char*));
httpVar	*httpdGetVariableByPrefixedName __ANSI_PROTO((request*, const char*, const char*));
httpVar *httpdGetNextVariableByPrefix __ANSI_PROTO((httpVar*, const char*));

httpAcl *httpdAddAcl __ANSI_PROTO((httpd*, httpAcl*, char*, int));

void httpdAuthenticate __ANSI_PROTO((request*, const char*));
void httpdForceAuthenticate __ANSI_PROTO((request*, const char*));

/***********************************************************************
** Standard header file footer.  
*/

#ifdef __cplusplus
	}
#endif /* __cplusplus */
#endif /* file inclusion */


