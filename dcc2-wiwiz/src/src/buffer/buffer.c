/*
 * MIT License
 *
 * Copyright (c) 2019 Jianhui Zhao <zhaojh329@gmail.com>
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

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>

#include "buffer.h"

int buffer_resize(struct buffer *b, size_t size)
{
    uint8_t *head;
    size_t new_size = getpagesize();
    int data_len = buffer_length(b);

    while (new_size < size)
        new_size <<= 1u;

    if (b->limit > 0 && new_size > b->limit)
        return 1;

    if (likely(b->head)) {
        if (buffer_headroom(b) > 0) {
            memmove(b->head, b->data, data_len);
            b->data = b->head;
            b->tail = b->data + data_len;
        }

        head = realloc(b->head, new_size);
    } else {
        head = malloc(new_size);
    }

    if (unlikely(!head))
        return -1;

    b->head = b->data = head;
    b->tail = b->data + data_len;
    b->end = b->head + new_size;

    if (unlikely(b->tail > b->end))
        b->tail = b->end;

    return 0;
}

int buffer_init(struct buffer *b, size_t size)
{
    memset(b, 0, sizeof(struct buffer));

    if (size > 0)
        return buffer_resize(b, size);

    return 0;
}

void buffer_free(struct buffer *b)
{
    if (b->head) {
        free(b->head);
        memset(b, 0, sizeof(struct buffer));
    }
}

void buffer_set_limit(struct buffer *b, size_t size)
{
    size_t new_size = getpagesize();

    while (new_size < size)
        new_size <<= 1u;

    b->limit = new_size;
}

void *buffer_put(struct buffer *b, size_t len)
{
    void *tmp;

    if (buffer_length(b) == 0)
        b->tail = b->data = b->head;

    if (buffer_tailroom(b) < len && buffer_grow(b, len))
        return NULL;

    tmp = b->tail;
    b->tail += len;

    return tmp;
}

int buffer_put_vprintf(struct buffer *b, const char *fmt, va_list ap)
{
    for (;;) {
        int ret;
        va_list local_ap;
        size_t tail_room = buffer_tailroom(b);

        va_copy(local_ap, ap);
        ret = vsnprintf((char *)b->tail, tail_room, fmt, local_ap);
        va_end(local_ap);

        if (ret < 0)
            return -1;

        if (likely(ret < tail_room)) {
            b->tail += ret;
            return 0;
        }

        if (unlikely(buffer_grow(b, 1)))
            return -1;
    }
}

int buffer_put_printf(struct buffer *b, const char *fmt, ...)
{
    va_list ap;
    int ret;

    va_start(ap, fmt);
    ret = buffer_put_vprintf(b, fmt, ap);
    va_end(ap);

    return ret;
}

static inline bool fd_is_nonblock(int fd)
{
    return (fcntl(fd, F_GETFL) & O_NONBLOCK) == O_NONBLOCK;
}

int buffer_put_fd_ex(struct buffer *b, int fd, ssize_t len, bool *eof,
                     int (*rd)(int fd, void *buf, size_t count, void *arg), void *arg)
{
    bool nonblock = fd_is_nonblock(fd);
    ssize_t remain;

    if (len < 0)
        len = INT_MAX;

    remain = len;

    if (eof)
        *eof = false;

    do {
        size_t tail_room = buffer_tailroom(b);
        size_t want;
        ssize_t ret;

        if (unlikely(!tail_room)) {
            ret = buffer_grow(b, 1);
            if (ret < 0)
                return -1;
            if (ret > 0)
                break;
            tail_room = buffer_tailroom(b);
        }

        want = tail_room;
        if (want > remain)
            want = remain;

        if (rd) {
            ret = rd(fd, b->tail, want, arg);
            if (ret == P_FD_ERR)
                return -1;
            else if (ret == P_FD_PENDING)
                break;
        } else {
            ret = read(fd, b->tail, want);
            if (unlikely(ret < 0)) {
                if (errno == EINTR)
                    continue;

                if (errno == EAGAIN || errno == ENOTCONN)
                    break;

                return -1;
            }
        }

        if (!ret) {
            if (eof)
                *eof = true;
            break;
        }

        b->tail += ret;
        remain -= ret;
    } while (remain && nonblock);

    return len - remain;
}

void buffer_truncate(struct buffer *b, size_t len)
{
    if (buffer_length(b) > len) {
        b->tail = b->data + len;
        buffer_reclaim(b);
    }
}

size_t buffer_pull(struct buffer *b, void *dest, size_t len)
{
    if (len > buffer_length(b))
        len = buffer_length(b);

    if (dest)
        memcpy(dest, b->data, len);

    b->data += len;

    buffer_reclaim(b);

    return len;
}

size_t buffer_get(struct buffer *b, ssize_t offset, void *dest, size_t len)
{
    if (unlikely(buffer_length(b) - 1 < offset))
        return 0;

    if (unlikely(len > buffer_length(b) - offset))
        len = buffer_length(b) - offset;

    if (likely(len > 0))
        memcpy(dest, b->data + offset, len);

    return len;
}

int buffer_pull_to_fd_ex(struct buffer *b, int fd, ssize_t len,
                         int (*wr)(int fd, void *buf, size_t count, void *arg), void *arg)
{
    bool nonblock = fd_is_nonblock(fd);
    ssize_t remain;

    if (len < 0)
        len = buffer_length(b);

    remain = len;

    if (remain > buffer_length(b))
        remain = buffer_length(b);

    do {
        ssize_t ret;

        if (wr) {
            ret = wr(fd, b->data, remain, arg);
            if (ret == P_FD_ERR)
                return -1;
            else if (ret == P_FD_PENDING)
                break;
        } else {
            ret = write(fd, b->data, remain);
            if (ret < 0) {
                if (errno == EINTR)
                    continue;

                if (errno == EAGAIN || errno == EWOULDBLOCK || errno == ENOTCONN)
                    break;

                return -1;
            }
        }

        remain -= ret;
        b->data += ret;
    } while (remain && nonblock);

    buffer_reclaim(b);

    return len - remain;
}

void buffer_hexdump(struct buffer *b, size_t offset, size_t len)
{
    int i;
    size_t data_len = buffer_length(b);
    uint8_t *data = buffer_data(b);

    if (offset > data_len - 1)
        return;

    if (len > data_len)
        len = data_len;

    for (i = offset; i < len; i++) {
        printf("%02X ", data[i]);
        if (i && i % 16 == 0)
            printf("\n");
    }
    printf("\n");
}

int buffer_find(struct buffer *b, size_t offset, size_t limit, void *sep, size_t seplen)
{
    const uint8_t *begin = b->data;
    const uint8_t *end;

    if (offset >= buffer_length(b))
        return -1;

    if (limit == 0 || limit > buffer_length(b))
        limit = buffer_length(b);

    end = begin + limit - seplen;

    for (; begin <= end; ++begin) {
        if (begin[0] == ((uint8_t *)sep)[0] &&
                !memcmp(begin + 1, sep + 1, seplen - 1))
            return begin - b->data;
    }

    return -1;
}

