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

#ifndef _BUFFER_H
#define _BUFFER_H

#include <stdint.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <endian.h>
#include <stdbool.h>
#include <sys/types.h>

/* Test for GCC < 2.96 */
#if __GNUC__ < 2 || (__GNUC__ == 2 && (__GNUC_MINOR__ < 96))
#define __builtin_expect(x) (x)
#endif

#ifndef likely
#define likely(x)	__builtin_expect(!!(x), 1)
#endif

#ifndef unlikely
#define unlikely(x)	__builtin_expect(!!(x), 0)
#endif

enum {
    P_FD_EOF = 0,
    P_FD_ERR = -1,
    P_FD_PENDING = -2
};

struct buffer {
    uint8_t *head;  /* Head of buffer */
    uint8_t *data;  /* Data head pointer */
    uint8_t *tail;  /* Data tail pointer */
    uint8_t *end;   /* End of buffer */
    size_t limit;   /* The limit of total size */
};

int buffer_init(struct buffer *b, size_t size);

/**
 * buffer_resize - realloc memory to specially size
 * @return: 0(success), -1(system error), 1(larger than limit)
 */
int buffer_resize(struct buffer *b, size_t size);
void buffer_free(struct buffer *b);
void buffer_set_limit(struct buffer *b, size_t size);



/* Actual data Length */
static inline size_t buffer_length(const struct buffer *b)
{
    return b->tail - b->data;
}

/* The total buffer size  */
static inline size_t buffer_size(const struct buffer *b)
{
    return b->end - b->head;
}

/**
 * buffer_grow - grow memory of the buffer
 * @return: 0(success), -1(system error), 1(larger than limit)
 */
static inline int buffer_grow(struct buffer *b, size_t len)
{
    return buffer_resize(b, buffer_size(b) + len);
}

static inline size_t buffer_headroom(const struct buffer *b)
{
    return b->data - b->head;
}

static inline size_t buffer_tailroom(const struct buffer *b)
{
    return b->end - b->tail;
}

static inline void *buffer_data(const struct buffer *b)
{
    return b->data;
}

static inline void buffer_reclaim(struct buffer *b)
{
    buffer_resize(b, buffer_length(b));
}

static inline size_t buffer_free_size(struct buffer *b)
{
    if (b->limit == 0)
        return UINT_MAX;
    return b->limit - buffer_length(b);
}

/**
 *	buffer_put - append data to a buffer
 *
 *	This function extends the used data area of the buffer. A pointer to the
 *	first byte of the extra data is returned.
 *  If this would exceed the total buffer size the buffer will grow automatically.
 */
void *buffer_put(struct buffer *b, size_t len);

static inline void *buffer_put_zero(struct buffer *b, size_t len)
{
    void *tmp = buffer_put(b, len);

    if (likely(tmp))
        memset(tmp, 0, len);
    return tmp;
}

static inline void *buffer_put_data(struct buffer *b, const void *data,   size_t len)
{
    void *tmp = buffer_put(b, len);

    if (likely(tmp))
        memcpy(tmp, data, len);
    return tmp;
}

static inline int buffer_put_u8(struct buffer *b, uint8_t val)
{
    if (buffer_put_data(b, &val, sizeof(val)))
        return 0;

    return -1;
}

static inline int buffer_put_u16(struct buffer *b, uint16_t val)
{
    if (buffer_put_data(b, &val, sizeof(val)))
        return 0;

    return -1;
}

static inline int buffer_put_u16be(struct buffer *b, uint16_t val)
{
    return buffer_put_u16(b, htobe16(val));
}

static inline int buffer_put_u16le(struct buffer *b, uint16_t val)
{
    return buffer_put_u16(b, htole16(val));
}

static inline int buffer_put_u32(struct buffer *b, uint32_t val)
{
    if (buffer_put_data(b, &val, sizeof(val)))
        return 0;

    return -1;
}

static inline int buffer_put_u32be(struct buffer *b, uint32_t val)
{
    return buffer_put_u32(b, htobe32(val));
}

static inline int buffer_put_u32le(struct buffer *b, uint32_t val)
{
    return buffer_put_u32(b, htole32(val));
}

static inline int buffer_put_u64(struct buffer *b, uint64_t val)
{
    if (buffer_put_data(b, &val, sizeof(val)))
        return 0;

    return -1;
}

static inline int buffer_put_u64be(struct buffer *b, uint64_t val)
{
    return buffer_put_u64(b, htobe64(val));
}

static inline int buffer_put_u64le(struct buffer *b, uint64_t val)
{
    return buffer_put_u64(b, htole64(val));
}

static inline int buffer_put_string(struct buffer *b, const char *s)
{
    size_t len = strlen(s);
    char *p = (char *)buffer_put(b, len);

    if (likely(p)) {
        memcpy(p, s, len);
        return 0;
    }

    return -1;
}

int buffer_put_vprintf(struct buffer *b, const char *fmt, va_list ap) __attribute__((format(printf, 2, 0)));
int buffer_put_printf(struct buffer *b, const char *fmt, ...) __attribute__((format(printf, 2, 3)));

/**
 *  buffer_put_fd_ex - Append data from a file to the end of a buffer.
 *  @param fd: file descriptor
 *  @param len: how much data to read, or -1 to read as much as possible.
 *  @param eof: indicates end of file
 *  @param rd: A customized read function. Generally used for SSL.
 *       The customized read function should be return:
 *       P_FD_EOF/P_FD_ERR/P_FD_PENDING or number of bytes read.
 *  @return: Return the number of bytes append
 */
int buffer_put_fd_ex(struct buffer *b, int fd, ssize_t len, bool *eof,
                     int (*rd)(int fd, void *buf, size_t count, void *arg), void *arg);

static inline int buffer_put_fd(struct buffer *b, int fd, ssize_t len, bool *eof)
{
    return buffer_put_fd_ex(b, fd, len, eof, NULL, NULL);
}

/**
 *	buffer_truncate - remove end from a buffer
 *
 *	Cut the length of a buffer down by removing data from the tail. If
 *	the buffer is already under the length specified it is not modified.
 */
void buffer_truncate(struct buffer *b, size_t len);

/* Discards data from tail */
static inline void buffer_discard(struct buffer *b, size_t len)
{
    size_t data_len = buffer_length(b);

    if (len > data_len)
        len = data_len;

    buffer_truncate(b, data_len - len);
}

/**
 *	buffer_pull - remove data from the start of a buffer
 *
 *	This function removes data from the start of a buffer,
 *  returning the actual length removed.
 *  Just remove the data if the dest is NULL.
 */
size_t buffer_pull(struct buffer *b, void *dest, size_t len);

static inline uint8_t buffer_pull_u8(struct buffer *b)
{
    uint8_t val = 0;

    buffer_pull(b, &val, sizeof(val));

    return val;
}

static inline uint16_t buffer_pull_u16(struct buffer *b)
{
    uint16_t val = 0;

    buffer_pull(b, &val, sizeof(val));

    return val;
}

static inline uint16_t buffer_pull_u16be(struct buffer *b)
{
    return be16toh(buffer_pull_u16(b));
}

static inline uint16_t buffer_pull_u16le(struct buffer *b)
{
    return le16toh(buffer_pull_u16(b));
}

static inline uint32_t buffer_pull_u32(struct buffer *b)
{
    uint32_t val = 0;

    buffer_pull(b, &val, sizeof(val));

    return val;
}

static inline uint32_t buffer_pull_u32be(struct buffer *b)
{
    return be32toh(buffer_pull_u32(b));
}

static inline uint32_t buffer_pull_u32le(struct buffer *b)
{
    return le32toh(buffer_pull_u32(b));
}

static inline uint64_t buffer_pull_u64(struct buffer *b)
{
    uint64_t val = 0;

    buffer_pull(b, &val, sizeof(val));

    return val;
}

static inline uint64_t buffer_pull_u64be(struct buffer *b)
{
    return be64toh(buffer_pull_u64(b));
}

static inline uint64_t buffer_pull_u64le(struct buffer *b)
{
    return le64toh(buffer_pull_u64(b));
}

/* Similar to buffer_pull, but does not remove the data */
size_t buffer_get(struct buffer *b, ssize_t offset, void *dest, size_t len);

static inline uint8_t buffer_get_u8(struct buffer *b, ssize_t offset)
{
    uint8_t val = 0;

    buffer_get(b, offset, &val, sizeof(val));

    return val;
}

static inline uint16_t buffer_get_u16(struct buffer *b, ssize_t offset)
{
    uint16_t val = 0;

    buffer_get(b, offset, &val, sizeof(val));

    return val;
}

static inline uint16_t buffer_get_u16be(struct buffer *b, ssize_t offset)
{
    return be16toh(buffer_get_u16(b, offset));
}

static inline uint16_t buffer_get_u16le(struct buffer *b, ssize_t offset)
{
    return le16toh(buffer_get_u16(b, offset));
}

static inline uint32_t buffer_get_u32(struct buffer *b, ssize_t offset)
{
    uint32_t val = 0;

    buffer_get(b, offset, &val, sizeof(val));

    return val;
}

static inline uint32_t buffer_get_u32be(struct buffer *b, ssize_t offset)
{
    return be32toh(buffer_get_u32(b, offset));
}

static inline uint32_t buffer_get_u32le(struct buffer *b, ssize_t offset)
{
    return le32toh(buffer_get_u32(b, offset));
}

static inline uint64_t buffer_get_u64(struct buffer *b, ssize_t offset)
{
    uint64_t val = 0;

    buffer_get(b, offset, &val, sizeof(val));

    return val;
}

static inline uint64_t buffer_get_u64be(struct buffer *b, ssize_t offset)
{
    return be64toh(buffer_get_u64(b, offset));
}

static inline uint64_t buffer_get_u64le(struct buffer *b, ssize_t offset)
{
    return le64toh(buffer_get_u64(b, offset));
}

/**
 *  buffer_pull_to_fd_ex - remove data from the start of a buffer and write to a file
 *  @param fd: file descriptor
 *  @param len: how much data to remove, or -1 to remove as much as possible.
 *  @param wr: A customized write function. Generally used for SSL.
 *       The customized write function should be return:
 *       P_FD_EOF/P_FD_ERR/P_FD_PENDING or number of bytes write.
 *  @return: the number of bytes removed
 */
int buffer_pull_to_fd_ex(struct buffer *b, int fd, ssize_t len,
                         int (*wr)(int fd, void *buf, size_t count, void *arg), void *arg);

static inline int buffer_pull_to_fd(struct buffer *b, int fd, ssize_t len)
{
    return buffer_pull_to_fd_ex(b, fd, len, NULL, NULL);
}

void buffer_hexdump(struct buffer *b, size_t offset, size_t len);

/**
 *	buffer_find - finds the start of the first occurrence of the sep of length seplen in the buffer
 *  @limit: 0 indicates unlimited
 *	Return -1 if sep is not present in the buffer
 */
int buffer_find(struct buffer *b, size_t offset, size_t limit, void *sep, size_t seplen);

#endif
