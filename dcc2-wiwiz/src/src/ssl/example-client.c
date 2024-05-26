/*
 * openssl: gcc example-client.c openssl.c -lssl -lcrypto
 * wolfssl: gcc example-client.c openssl.c -lwolfssl -DHAVE_WOLFSSL
 * mbedtls: gcc example-client.c mbedtls.c -lmbedtls -lmbedcrypto -lmbedx509
 */

#include <sys/select.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <netdb.h>
#include <stdio.h>
#include <errno.h>

#include "ssl.h"

static void on_verify_error(int error, const char *str, void *arg)
{
    fprintf(stderr, "WARNING: SSL certificate error(%d): %s\n", error, str);
}

static void chat(void *ssl, int sock)
{
    char err_buf[128];
    char buf[4096];
    fd_set rfds;
    int ret;

    FD_SET(STDIN_FILENO, &rfds);
    FD_SET(sock, &rfds);

    while (true) {
        FD_ZERO(&rfds);
        FD_SET(STDIN_FILENO, &rfds);
        FD_SET(sock, &rfds);

        ret = select(sock + 1, &rfds, NULL, NULL, NULL);
        if (ret < 0) {
            perror("select");
            return;
        }

        if (FD_ISSET(STDIN_FILENO, &rfds)) {
            int n = read(STDIN_FILENO, buf, sizeof(buf));

            do {
                ret = ssl_write(ssl, buf, n);
                if (ret < 0) {
                    fprintf(stderr, "ssl_write: %s\n", ssl_last_error_string(err_buf, sizeof(err_buf)));       
                    return;
                }
            } while (ret == 0);
            printf("Send: %.*s\n", ret, buf);

        } else if (FD_ISSET(sock, &rfds)) {
            ret = ssl_read(ssl, buf, sizeof(buf));
            if (ret < 0) {
                fprintf(stderr, "ssl_read: %s\n", ssl_last_error_string(err_buf, sizeof(err_buf)));
                ssl_session_free(ssl);
                close(sock);
                return;
            }

            if (ret == 0) {
                fprintf(stderr, "Connection closed by peer\n");
                ssl_session_free(ssl);
                close(sock);
                return; 
            }

            printf("Recv: %.*s\n", ret, buf);
        }
    }
}

static void *connect_ssl(int sock, const char *host)
{
    struct ssl_context *ctx;
    char err_buf[128];
    void *ssl;
    int ret;

    printf("Starting SSL negotiation\n");

    ctx = ssl_context_new(false);
    if (!ctx) {
        fprintf(stderr, "ssl_context_new fail\n");
        return NULL;
    }

    ssl = ssl_session_new(ctx, sock);
    if (!ssl) {
        fprintf(stderr, "ssl_session_new fail\n");
        return NULL;
    }

    ssl_set_server_name(ssl, host);

    do {
        ret = ssl_connect(ssl, false, on_verify_error, NULL);

        if (ret == SSL_ERROR) {
            fprintf(stderr, "ssl_connect: %s\n", ssl_last_error_string(err_buf, sizeof(err_buf)));
            return NULL;
        }
    } while (ret == SSL_PENDING);

    printf("SSL negotiation OK\n");

    return ssl;
}

static bool wait_connect(int sock)
{
    struct timeval tv = {
        .tv_sec = 5
    };
    fd_set wfds = {};
    int ret, err;
    socklen_t len = sizeof(err);

    FD_SET(sock, &wfds);

    ret = select(sock + 1, NULL, &wfds, NULL, &tv);
    if (ret < 0) {
        perror("select");
        return false;
    }

    if (!FD_ISSET(sock, &wfds))
        return false;
    
    ret = getsockopt(sock, SOL_SOCKET, SO_ERROR, &err, &len);
    if (ret < 0) {
        perror("getsockopt");
        return false;
    }

    return true;
}

int main(int argc, char **argv)
{
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
    };
    int sock;
    void *ssl;

    if (argc < 3) {
        fprintf(stderr, "Usage: %s host port\n", argv[0]);
        return -1;
    }

    if (!inet_aton(argv[1], &addr.sin_addr)) {
        fprintf(stderr, "invalid addr: %s\n", optarg);
        return -1;
    }

    addr.sin_port = htons(atoi(argv[2]));

    signal(SIGPIPE, SIG_IGN);

    sock = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        if (errno != EINPROGRESS) {
            perror("connect");
            return -1;
        }

        if (!wait_connect(sock))
            return -1;
    }

    printf("Connection established\n");

    ssl = connect_ssl(sock, argv[2]);
    if (!ssl)
        return -1;
    
    chat(ssl, sock);

    return 0;
}
