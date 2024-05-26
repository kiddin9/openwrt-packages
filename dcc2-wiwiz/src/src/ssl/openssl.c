/*
 * MIT License
 *
 * Copyright (c) 2021 Jianhui Zhao <zhaojh329@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * ustream-ssl - library for SSL over ustream
 *
 * Copyright (C) 2012 Felix Fietkau <nbd@openwrt.org>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <string.h>

#include "ssl.h"

#if defined(HAVE_WOLFSSL)
#include <wolfssl/options.h>
#include <wolfssl/openssl/ssl.h>
#else
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509v3.h>
#endif

/* Ciphersuite preference:
 * - for server, no weak ciphers are used if you use an ECDSA key.
 * - forward-secret (pfs), authenticated (AEAD) ciphers are at the top:
 *   	chacha20-poly1305, the fastest in software, 256-bits
 * 	aes128-gcm, 128-bits
 * 	aes256-gcm, 256-bits
 * - key exchange: prefer ECDHE, then DHE (client only)
 * - forward-secret ECDSA CBC ciphers (client-only)
 * - forward-secret RSA CBC ciphers
 * - non-pfs ciphers
 *	aes128, aes256, 3DES(client only)
 */

#ifdef WOLFSSL_SSL_H
# define top_ciphers							\
                "TLS13-CHACHA20-POLY1305-SHA256:"	\
                "TLS13-AES128-GCM-SHA256:"		\
                "TLS13-AES256-GCM-SHA384:"		\
                ecdhe_aead_ciphers
#else
# define top_ciphers							\
                ecdhe_aead_ciphers
#endif

# define tls13_ciphersuites	"TLS_CHACHA20_POLY1305_SHA256:"		\
                "TLS_AES_128_GCM_SHA256:"		\
                "TLS_AES_256_GCM_SHA384"

#define ecdhe_aead_ciphers						\
                "ECDHE-ECDSA-CHACHA20-POLY1305:"	\
                "ECDHE-ECDSA-AES128-GCM-SHA256:"	\
                "ECDHE-ECDSA-AES256-GCM-SHA384:"	\
                "ECDHE-RSA-CHACHA20-POLY1305:"		\
                "ECDHE-RSA-AES128-GCM-SHA256:"		\
                "ECDHE-RSA-AES256-GCM-SHA384"

#define dhe_aead_ciphers						\
                "DHE-RSA-CHACHA20-POLY1305:"		\
                "DHE-RSA-AES128-GCM-SHA256:"		\
                "DHE-RSA-AES256-GCM-SHA384"

#define ecdhe_ecdsa_cbc_ciphers						\
                "ECDHE-ECDSA-AES128-SHA:"		\
                "ECDHE-ECDSA-AES256-SHA"

#define ecdhe_rsa_cbc_ciphers						\
                "ECDHE-RSA-AES128-SHA:"			\
                "ECDHE-RSA-AES256-SHA"

#define dhe_cbc_ciphers							\
                "DHE-RSA-AES128-SHA:"			\
                "DHE-RSA-AES256-SHA:"			\
                "DHE-DES-CBC3-SHA"

#define non_pfs_aes							\
                "AES128-GCM-SHA256:"			\
                "AES256-GCM-SHA384:"			\
                "AES128-SHA:"				\
                "AES256-SHA"

#define server_cipher_list						\
                top_ciphers ":"				\
                ecdhe_rsa_cbc_ciphers ":"		\
                non_pfs_aes

#define client_cipher_list						\
                top_ciphers ":"				\
                dhe_aead_ciphers ":"			\
                ecdhe_ecdsa_cbc_ciphers ":"		\
                ecdhe_rsa_cbc_ciphers ":"		\
                dhe_cbc_ciphers ":"			\
                non_pfs_aes ":"				\
                "DES-CBC3-SHA"

struct ssl_context {
};

static int ssl_err_code;

const char *ssl_last_error_string(char *buf, int len)
{
    const char *file, *data;
    int line, flags;

    if (ssl_err_code == SSL_ERROR_SSL) {
        int used;

        ssl_err_code = ERR_peek_error_line_data(&file, &line, &data, &flags);
        ERR_error_string_n(ssl_err_code, buf, len);

        used = strlen(buf);

        snprintf(buf + used, len - used, ":%s:%d:%s", file, line, (flags & ERR_TXT_STRING) ? data : "");
    } else {
        ERR_error_string_n(ssl_err_code, buf, len);
    }

    return buf;
}

struct ssl_context *ssl_context_new(bool server)
{
    const void *m;
    SSL_CTX *c;

#if OPENSSL_VERSION_NUMBER < 0x10100000L
    static bool _init = false;

    if (!_init) {
        SSL_load_error_strings();
        SSL_library_init();
        _init = true;
    }
# ifndef TLS_server_method
#  define TLS_server_method SSLv23_server_method
# endif
# ifndef TLS_client_method
#  define TLS_client_method SSLv23_client_method
# endif
#endif

    if (server) {
        m = TLS_server_method();
    } else
        m = TLS_client_method();

    c = SSL_CTX_new((void *) m);
    if (!c)
        return NULL;

    SSL_CTX_set_verify(c, SSL_VERIFY_NONE, NULL);

    SSL_CTX_set_options(c, SSL_OP_NO_COMPRESSION | SSL_OP_SINGLE_ECDH_USE | SSL_OP_CIPHER_SERVER_PREFERENCE);
#if defined(SSL_CTX_set_ecdh_auto) && OPENSSL_VERSION_NUMBER < 0x10100000L
    SSL_CTX_set_ecdh_auto(c, 1);
#elif OPENSSL_VERSION_NUMBER >= 0x10101000L
    SSL_CTX_set_ciphersuites(c, tls13_ciphersuites);
#endif
    if (server) {
#if OPENSSL_VERSION_NUMBER >= 0x10100000L
        SSL_CTX_set_min_proto_version(c, TLS1_2_VERSION);
#else
        SSL_CTX_set_options(c, SSL_OP_NO_SSLv3 | SSL_OP_NO_TLSv1 | SSL_OP_NO_TLSv1_1);
#endif
        SSL_CTX_set_cipher_list(c, server_cipher_list);
    } else {
        SSL_CTX_set_cipher_list(c, client_cipher_list);
    }
    SSL_CTX_set_quiet_shutdown(c, 1);

    return (void *)c;
}

void ssl_context_free(struct ssl_context *ctx)
{
    if (!ctx)
        return;

    SSL_CTX_free((void *)ctx);
}

int ssl_load_ca_crt_file(struct ssl_context *ctx, const char *file)
{
    int ret;

    ret = SSL_CTX_load_verify_locations((void *)ctx, file, NULL);
    if (ret < 1)
        return -1;

    return 0;
}

int ssl_load_crt_file(struct ssl_context *ctx, const char *file)
{
    int ret;

    ret = SSL_CTX_use_certificate_chain_file((void *)ctx, file);
    if (ret < 1)
        ret = SSL_CTX_use_certificate_file((void *)ctx, file, SSL_FILETYPE_ASN1);

    if (ret < 1)
        return -1;

    return 0;
}

int ssl_load_key_file(struct ssl_context *ctx, const char *file)
{
    int ret;

    ret = SSL_CTX_use_PrivateKey_file((void *)ctx, file, SSL_FILETYPE_PEM);
    if (ret < 1)
        ret = SSL_CTX_use_PrivateKey_file((void *)ctx, file, SSL_FILETYPE_ASN1);

    if (ret < 1)
        return -1;

    return 0;
}

int ssl_set_ciphers(struct ssl_context *ctx, const char *ciphers)
{
    int ret = SSL_CTX_set_cipher_list((void *) ctx, ciphers);

    if (ret == 0)
        return -1;

    return 0;
}

int ssl_set_require_validation(struct ssl_context *ctx, bool require)
{
    int mode = SSL_VERIFY_PEER;

    if (!require)
        mode = SSL_VERIFY_NONE;

    SSL_CTX_set_verify((void *)ctx, mode, NULL);

    return 0;
}

void *ssl_session_new(struct ssl_context *ctx, int sock)
{
    void *ssl = SSL_new((void *)ctx);

    if (!ssl)
        return NULL;

    SSL_set_fd(ssl, sock);

    SSL_set_mode(ssl, SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER | SSL_MODE_ENABLE_PARTIAL_WRITE);

    return ssl;
}

void ssl_session_free(void *ssl)
{
    if (!ssl)
        return;

    SSL_shutdown(ssl);
    SSL_free(ssl);
}

void ssl_set_server_name(void *ssl, const char *name)
{
    SSL_set_tlsext_host_name(ssl, name);
}

static void ssl_verify_cert(void *ssl, void (*on_verify_error)(int error, const char *str, void *arg), void *arg)
{
    int res;

    res = SSL_get_verify_result(ssl);
    if (res != X509_V_OK && on_verify_error)
        on_verify_error(res, X509_verify_cert_error_string(res), arg);
}

#ifdef WOLFSSL_SSL_H
static bool handle_wolfssl_asn_error(void *ssl, int r,
                void (*on_verify_error)(int error, const char *str, void *arg), void *arg)
{
    switch (r) {
    case ASN_PARSE_E:
    case ASN_VERSION_E:
    case ASN_GETINT_E:
    case ASN_RSA_KEY_E:
    case ASN_OBJECT_ID_E:
    case ASN_TAG_NULL_E:
    case ASN_EXPECT_0_E:
    case ASN_BITSTR_E:
    case ASN_UNKNOWN_OID_E:
    case ASN_DATE_SZ_E:
    case ASN_BEFORE_DATE_E:
    case ASN_AFTER_DATE_E:
    case ASN_SIG_OID_E:
    case ASN_TIME_E:
    case ASN_INPUT_E:
    case ASN_SIG_CONFIRM_E:
    case ASN_SIG_HASH_E:
    case ASN_SIG_KEY_E:
    case ASN_DH_KEY_E:
    case ASN_NTRU_KEY_E:
    case ASN_CRIT_EXT_E:
    case ASN_ALT_NAME_E:
    case ASN_NO_PEM_HEADER:
    case ASN_ECC_KEY_E:
    case ASN_NO_SIGNER_E:
    case ASN_CRL_CONFIRM_E:
    case ASN_CRL_NO_SIGNER_E:
    case ASN_OCSP_CONFIRM_E:
    case ASN_NAME_INVALID_E:
    case ASN_NO_SKID:
    case ASN_NO_AKID:
    case ASN_NO_KEYUSAGE:
    case ASN_COUNTRY_SIZE_E:
    case ASN_PATHLEN_SIZE_E:
    case ASN_PATHLEN_INV_E:
#if LIBWOLFSSL_VERSION_HEX >= 0x04004000
    case ASN_SELF_SIGNED_E:
#endif
        if (on_verify_error)
            on_verify_error(r, wc_GetErrorString(r), arg);
        return true;
    }

    return false;
}
#endif

int ssl_connect(void *ssl, bool server,
        void (*on_verify_error)(int error, const char *str, void *arg), void *arg)
{
    int r;

    ERR_clear_error();

    ssl_err_code = 0;

    if (server)
        r = SSL_accept(ssl);
    else
        r = SSL_connect(ssl);

    if (r == 1) {
        ssl_verify_cert(ssl, on_verify_error, arg);
        return SSL_OK;
    }

    r = SSL_get_error(ssl, r);
    if (r == SSL_ERROR_WANT_READ || r == SSL_ERROR_WANT_WRITE)
        return SSL_PENDING;

#ifdef WOLFSSL_SSL_H
    if (handle_wolfssl_asn_error(ssl, r, on_verify_error, arg))
        return SSL_OK;
#endif

    ssl_err_code = r;

    return SSL_ERROR;
}

int ssl_write(void *ssl, const void *buf, int len)
{
    int ret;

    ERR_clear_error();

    ssl_err_code = 0;

    ret = SSL_write(ssl, buf, len);

    if (ret < 0) {
        ret = SSL_get_error(ssl, ret);
        if (ret == SSL_ERROR_WANT_WRITE)
            return SSL_PENDING;

        ssl_err_code = ret;
        return SSL_ERROR;
    }

    return ret;
}

int ssl_read(void *ssl, void *buf, int len)
{
    int ret;

    ERR_clear_error();

    ssl_err_code = 0;

    ret = SSL_read(ssl, buf, len);
    if (ret < 0) {
        ret = SSL_get_error(ssl, ret);
        if (ret == SSL_ERROR_WANT_READ)
            return SSL_PENDING;

        ssl_err_code = ret;
        return SSL_ERROR;
    }

    return ret;
}
