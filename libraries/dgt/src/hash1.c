#include <nitro/dgt/dgt.h>
#include <nitro/types.h>

#include "hmac.h"

static void ProcessBlock(DGTHash1Context *ctx);

void DGT_Hash1Reset(DGTHash1Context *ctx)
{
    // MD5 magic values
    ctx->a = 0x67452301;
    ctx->b = 0xEFCDAB89;
    ctx->c = 0x98BADCFE;
    ctx->d = 0x10325476;

    ctx->length = 0;
}

void DGT_Hash1SetSource(DGTHash1Context *ctx, const void *input, u32 length)
{
    int buffer_len = ctx->length % 64;
    ctx->length += length;

    // If the new data fits in the buffer, copy it in
    int free_bytes = 64 - buffer_len;
    if (free_bytes > length) {
        if (length > 0) {
            MI_CpuCopy8(input, ctx->buffer8 + buffer_len, length);
        }
    } else {
        // Else, copy what fits in the buffer and process the block
        MI_CpuCopy8(input, ctx->buffer8 + buffer_len, free_bytes);
        ProcessBlock(ctx);

        u8 *inputp = (u8 *)input + free_bytes;
        length -= free_bytes;

        // Copy remaining whole blocks of data into the buffer and process it
        for (int blocks = length / 64; blocks > 0; blocks--) {
            MI_CpuCopy8(inputp, ctx->buffer8, 64);
            inputp += 64;
            ProcessBlock(ctx);
        }
        length %= 64;

        // Copy any remaining stray bytes into the buffer
        if (length > 0) {
            MI_CpuCopy8(inputp, ctx->buffer8, length);
        }
    }
}

void DGT_Hash1GetDigest_R(void *digest, DGTHash1Context *ctx)
{
    u64 len_bits = ctx->length * 8;

    // Add end one bit (0x80)
    static u8 padding = 0x80;
    DGT_Hash1SetSource(ctx, &padding, 1);

    u32 buffer_len = ctx->length & 63;
    u32 free_bytes = 64 - buffer_len;

    // If there is not enough buffer space to add the length, zero fill it and process the block
    if (free_bytes < 8) {
        MI_CpuFill8(ctx->buffer8 + buffer_len, 0, free_bytes);
        ProcessBlock(ctx);
        buffer_len = 0;
        free_bytes = 64;
    }

    // If there is extra space between the end of the data and the length, zero fill it
    if (free_bytes > 8) {
        MI_CpuFill8(ctx->buffer8 + buffer_len, 0, free_bytes - 8);
    }

    // Add the length (Little-Endian u64 write) and process the block
    *(u64 *)(ctx->buffer8 + 56) = len_bits;
    ProcessBlock(ctx);

    // Copy state to digest (Little-Endian)
    MI_CpuCopy8(ctx->state, digest, 16);

    // Zero out context struct
    MI_CpuFill8(ctx, 0, sizeof(DGTHash1Context));
}

#define ROTL(x, amt)      (((x) << (amt)) | ((x) >> (32 - (amt))))
#define FUNC_CH(b, c, d)  ((b & c) | (~b & d))
#define FUNC_CH2(b, c, d) ((b & d) | (c & ~d))
#define FUNC_SUM(b, c, d) (b ^ c ^ d)
#define FUNC_R4(b, c, d)  (c ^ (b | ~d))

static inline u32 CalcRound1(u32 a, u32 b, u32 c, u32 d, u32 x, u32 t, u32 s)
{
    return b + ROTL(a + FUNC_CH(b, c, d) + x + t, s);
}

static inline u32 CalcRound2(u32 a, u32 b, u32 c, u32 d, u32 x, u32 t, u32 s)
{
    return b + ROTL(a + FUNC_CH2(b, c, d) + x + t, s);
}

static inline u32 CalcRound3(u32 a, u32 b, u32 c, u32 d, u32 x, u32 t, u32 s)
{
    return b + ROTL(a + FUNC_SUM(b, c, d) + x + t, s);
}

static inline u32 CalcRound4(u32 a, u32 b, u32 c, u32 d, u32 x, u32 t, u32 s)
{
    return b + ROTL(a + FUNC_R4(b, c, d) + x + t, s);
}

static void ProcessBlock(DGTHash1Context *ctx)
{
    // MD5 magic round constants
    static u32 t[64] = {
        0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE,
        0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501,
        0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE,
        0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821,
        0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA,
        0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8,
        0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED,
        0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A,
        0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C,
        0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70,
        0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05,
        0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665,
        0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039,
        0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1,
        0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1,
        0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391
    };

    // MD5 round word indices
    static u32 k[48] = {
        1, 6, 11, 0,
        5, 10, 15, 4,
        9, 14, 3, 8,
        13, 2, 7, 12,
        5, 8, 11, 14,
        1, 4, 7, 10,
        13, 0, 3, 6,
        9, 12, 15, 2,
        0, 7, 14, 5,
        12, 3, 10, 1,
        8, 15, 6, 13,
        4, 11, 2, 9
    };

    const u32 *kp;

    u32 a = ctx->state[0];
    u32 b = ctx->state[1];
    u32 c = ctx->state[2];
    u32 d = ctx->state[3];

    const u32 *x = ctx->buffer32;
    const u32 *xp = x;
    const u32 *tp = t;

    int i;

    // First round
    for (i = 0; i < 4; i++) {
        a = CalcRound1(a, b, c, d, *xp++, *tp++, 7);
        d = CalcRound1(d, a, b, c, *xp++, *tp++, 12);
        c = CalcRound1(c, d, a, b, *xp++, *tp++, 17);
        b = CalcRound1(b, c, d, a, *xp++, *tp++, 22);
    }

    // Rounds 2-4 use the words out of order
    kp = &k[0];

    // Second round
    for (i = 0; i < 4; i++) {
        a = CalcRound2(a, b, c, d, x[*kp++], *tp++, 5);
        d = CalcRound2(d, a, b, c, x[*kp++], *tp++, 9);
        c = CalcRound2(c, d, a, b, x[*kp++], *tp++, 14);
        b = CalcRound2(b, c, d, a, x[*kp++], *tp++, 20);
    }

    // Third round
    for (i = 0; i < 4; i++) {
        a = CalcRound3(a, b, c, d, x[*kp++], *tp++, 4);
        d = CalcRound3(d, a, b, c, x[*kp++], *tp++, 11);
        c = CalcRound3(c, d, a, b, x[*kp++], *tp++, 16);
        b = CalcRound3(b, c, d, a, x[*kp++], *tp++, 23);
    }

    // Fourth round
    for (i = 0; i < 4; i++) {
        a = CalcRound4(a, b, c, d, x[*kp++], *tp++, 6);
        d = CalcRound4(d, a, b, c, x[*kp++], *tp++, 10);
        c = CalcRound4(c, d, a, b, x[*kp++], *tp++, 15);
        b = CalcRound4(b, c, d, a, x[*kp++], *tp++, 21);
    }

    // Add back to current state
    ctx->state[0] += a;
    ctx->state[1] += b;
    ctx->state[2] += c;
    ctx->state[3] += d;
}

void DGT_Hash1GetDigest(DGTHash1Context *ctx, void *digest)
{
    DGT_Hash1GetDigest_R(digest, ctx);
}

void DGT_Hash1CalcHmac(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len)
{
    DGTHash1Context md5_ctx;
    u8 md5_buf[DGT_HASH1_DIGEST_SIZE];

    DGTiHMACFuncs hash1func = { DGT_HASH1_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash1func.context = &md5_ctx;
    hash1func.hash_buf = md5_buf;
    hash1func.HashReset = (HashResetFunc)DGT_Hash1Reset;
    hash1func.HashSetSource = (HashSetSourceFunc)DGT_Hash1SetSource;
    hash1func.HashGetDigest = (HashGetDigestFunc)DGT_Hash1GetDigest;

    HmacCalc(digest, bin_ptr, bin_len, key_ptr, key_len, &hash1func);
}

int DGT_Hash1CalcHmacForRms(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len)
{
    DGTHash1Context md5_ctx;
    u8 md5_buf[DGT_HASH1_DIGEST_SIZE];

    DGTiHMACFuncs hash1func = { DGT_HASH1_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash1func.context = &md5_ctx;
    hash1func.hash_buf = md5_buf;
    hash1func.HashReset = (HashResetFunc)DGT_Hash1Reset;
    hash1func.HashSetSource = (HashSetSourceFunc)DGT_Hash1SetSource;
    hash1func.HashGetDigest = (HashGetDigestFunc)DGT_Hash1GetDigest;

    return Hmac_MakeForRMS(digest, romh_ptr, romh_len, mbin_ptr, mbin_len, sbin_ptr, sbin_len, key_ptr, key_len, &hash1func);
}

int DGT_Hash1TestHmacForRms(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len)
{
    DGTHash1Context md5_ctx;
    u8 md5_buf[DGT_HASH1_DIGEST_SIZE];

    DGTiHMACFuncs hash1func = { DGT_HASH1_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash1func.context = &md5_ctx;
    hash1func.hash_buf = md5_buf;
    hash1func.HashReset = (HashResetFunc)DGT_Hash1Reset;
    hash1func.HashSetSource = (HashSetSourceFunc)DGT_Hash1SetSource;
    hash1func.HashGetDigest = (HashGetDigestFunc)DGT_Hash1GetDigest;

    return Hmac_TestForRMS(digest, romh_ptr, romh_len, mbin_ptr, mbin_len, sbin_ptr, sbin_len, key_ptr, key_len, &hash1func);
}
