/*
 * openssl: gcc example-server.c openssl.c -lssl -lcrypto
 * wolfssl: gcc example-server.c openssl.c -lwolfssl -DHAVE_WOLFSSL
 * mbedtls: gcc example-server.c mbedtls.c -lmbedtls -lmbedcrypto -lmbedx509
 */

#define _GNU_SOURCE

#include <sys/select.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <netdb.h>
#include <stdio.h>
#include <errno.h>

#include "ssl.h"

static struct ssl_context *ctx;

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
                fprintf(stderr, "ssl_read error: %s\n", ssl_last_error_string(err_buf, sizeof(err_buf)));
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

static void *ssl_negotiation(int sock)
{
    char err_buf[128];
    void *ssl;
    int ret;
    
    ssl = ssl_session_new(ctx, sock);
    if (!ssl) {
        fprintf(stderr, "ssl_session_new fail\n");
        return NULL;
    }

    printf("Wait SSL negotiation...\n");

    do {
        ret = ssl_connect(ssl, true, on_verify_error, NULL);

        if (ret == SSL_ERROR) {
            fprintf(stderr, "ssl_connect: %s\n", ssl_last_error_string(err_buf, sizeof(err_buf)));
            return NULL;
        }
    } while (ret == SSL_PENDING);

    printf("SSL negotiation OK\n");

    return ssl;
}

int main(int argc, char **argv)
{
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_addr.s_addr = INADDR_ANY,
        .sin_port = htons(4433)
    };
    int on = 1;
    int sock;

    signal(SIGPIPE, SIG_IGN);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket");
        return -1;
    }

    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(int));

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return -1;
    }

    listen(sock, 128);

    ctx = ssl_context_new(true);

    ssl_load_crt_file(ctx, "example.crt");
    ssl_load_key_file(ctx, "example.key");

    printf("Wait connect...\n");

    while (true) {
        void *ssl;
        int cli;

        cli = accept4(sock, NULL, NULL, SOCK_NONBLOCK);
        if (cli < 0) {
            perror("accept4");
            return -1;
        }

        printf("new tcp connection\n");

        ssl = ssl_negotiation(cli);
        if (!ssl)
            return -1;
        
        chat(ssl, cli);
    }

    return 0;
}
