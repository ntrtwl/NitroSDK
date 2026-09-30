#include <nitro/dgt/dgt.h>
#include <nitro/mi/memory.h>
#include <nitro/types.h>

#include "hmac.h"
#include "sha1_asm.h"

int DGT_Hash2Test(void);
void DGTi_Hash2ProcessMessageBlock(DGTHash2Context *ctx, u8 *source, u32 length);

static int DGTi_OverlayTableMode = 0;
static void (*DGTi_Hash2ProcessMessageBlockFunc)(DGTHash2Context *ctx, u8 *source, u32 length) = DGTi_hash2_arm4_small;

int DGT_SetOverlayTableMode(int flag)
{
    int prev = DGTi_OverlayTableMode;
    DGTi_OverlayTableMode = flag;

    if (flag) {
        DGTi_Hash2ProcessMessageBlockFunc = DGTi_Hash2ProcessMessageBlock;
    } else {
        DGTi_Hash2ProcessMessageBlockFunc = DGTi_hash2_arm4_small;
    }

    return prev;
}

void DGT_Hash2Reset(DGTHash2Context *ctx)
{
    // SHA1 magic values
    ctx->h0 = 0x67452301;
    ctx->h1 = 0xEFCDAB89;
    ctx->h2 = 0x98BADCFE;
    ctx->h3 = 0x10325476;
    ctx->h4 = 0xC3D2E1F0;

    ctx->Nl = 0;
    ctx->Nh = 0;

    ctx->num = 0;
}

void DGT_Hash2SetSource(DGTHash2Context *ctx, const u8 *input, u32 length)
{
    u8 *buffer8 = (u8 *)ctx->data;

    if (length == 0) {
        return;
    }

    // Add to Nl and Nh with overflow
    u32 new_low = ctx->Nl + (length << 3);
    if (new_low < ctx->Nl) {
        ctx->Nh++;
    }
    ctx->Nh += length >> 29;
    ctx->Nl = new_low;

    // If there is data in the buffer, copy to it and process the buffer if neccesary
    if (ctx->num != 0) {
        if (ctx->num + length >= 64) {
            u32 copy_bytes = 64 - ctx->num;
            MI_CpuCopy8(input, buffer8 + ctx->num, copy_bytes);
            length -= copy_bytes;
            input += copy_bytes;
            DGTi_Hash2ProcessMessageBlockFunc(ctx, buffer8, 64);
            ctx->num = 0;
        } else {
            MI_CpuCopy8(input, buffer8 + ctx->num, length);
            ctx->num += length;
            return;
        }
    }

    // Process whole blocks of remaining data
    if (length >= 64) {
        int whole_blocks_len = length & ~63;
        length -= whole_blocks_len;

        // If data is 4-aligned, it can be processed directly
        // Otherwise, copy it to the buffer first
        if (((u32)input & 3) == 0) {
            DGTi_Hash2ProcessMessageBlockFunc(ctx, (u8 *)input, whole_blocks_len);
            input += whole_blocks_len;
        } else {
            do {
                MI_CpuCopy8(input, buffer8, 64);
                input += 64;
                DGTi_Hash2ProcessMessageBlockFunc(ctx, buffer8, 64);
                whole_blocks_len -= 64;
            } while (whole_blocks_len > 0);
        }
    }

    ctx->num = length;

    // Copy any stray bytes into buffer
    if (length > 0) {
        MI_CpuCopy8(input, buffer8, length);
    }
}

static inline void storeBE32(u8 *ptr, u32 val)
{
    ptr[0] = (u8)(val >> 24);
    ptr[1] = (u8)(val >> 16);
    ptr[2] = (u8)(val >> 8);
    ptr[3] = (u8)(val);
}

static inline void storeBE32_R(u8 *ptr, u32 val)
{
    ptr[3] = (u8)(val);
    ptr[2] = (u8)(val >> 8);
    ptr[1] = (u8)(val >> 16);
    ptr[0] = (u8)(val >> 24);
}

void DGT_Hash2GetDigest(DGTHash2Context *ctx, u8 *digest)
{
    /* Unused */ static const char end[4] = { 0x80, 0x00, 0x00, 0x00 };

    u32 *buffer32 = ctx->data;
    s32 idx32, len;

    len = ctx->num;
    idx32 = len >> 2;
    if ((len & 3) == 0) {
        buffer32[idx32] = 0;
    }

    // Add end one bit (0x80)
    u8 *buffer8 = (u8 *)ctx->data;
    buffer8[len] = 0x80;
    len++;

    // Zero fill buffer to 4-alignment
    while ((len & 3) != 0) {
        buffer8[len] = 0;
        len++;
    }
    idx32++;

    // If there is not enough room to add the length, process the buffer
    if (ctx->num >= 56) {
        // Zero fill remainder of buffer
        while (idx32 < 16) {
            buffer32[idx32] = 0;
            idx32++;
        }

        DGTi_Hash2ProcessMessageBlockFunc(ctx, (u8 *)buffer32, 64);
        idx32 = 0;
    }

    // Zero fill buffer space not used by data or length
    while (idx32 < 14) {
        buffer32[idx32] = 0;
        idx32++;
    }

    // Add length (Big Endian)
    storeBE32_R(buffer8 + 60, ctx->Nl);
    storeBE32_R(buffer8 + 56, ctx->Nh);

    // Process final block with length
    DGTi_Hash2ProcessMessageBlockFunc(ctx, (u8 *)buffer32, 64);

    // Copy digest out (Big Endian)
    storeBE32(digest, ctx->h0);
    storeBE32(digest + 4, ctx->h1);
    storeBE32(digest + 8, ctx->h2);
    storeBE32(digest + 12, ctx->h3);
    storeBE32(digest + 16, ctx->h4);

    ctx->num = 0;

    // Clearing the stack memory for paranoia reasons
    MI_CpuFill32(&ctx, 0, sizeof(ctx));
}

void DGTi_Hash2ProcessMessageBlock(DGTHash2Context *ctx, u8 *source, u32 length)
{
    int tmp1, tmp2, i;
    for (i = 0; i < length / 64; i++) {
        // Save and clear file_id in OverlayTable
        tmp1 = *(int *)(source + 0x18);
        tmp2 = *(int *)(source + 0x38);
        *(int *)(source + 0x18) = 0;
        *(int *)(source + 0x38) = 0;

        DGTi_hash2_arm4_small(ctx, source, 64);

        // Restore file_id
        *(int *)(source + 0x18) = tmp1;
        *(int *)(source + 0x38) = tmp2;

        source += 64;
    }
}

// Self test vectors
char *DGTi_Hash2SampleArray[4] = {
    "abc",
    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    "a",
    "0123456701234567012345670123456701234567012345670123456701234567"
};

char *DGTi_Hash2ResultArray[4] = {
    "\xA9\x99\x3E\x36\x47\x06\x81\x6A\xBA\x3E\x25\x71\x78\x50\xC2\x6C\x9C\xD0\xD8\x9D", // sha1("abc")
    "\x84\x98\x3E\x44\x1C\x3B\xD2\x6E\xBA\xAE\x4A\xA1\xF9\x51\x29\xE5\xE5\x46\x70\xF1", // sha1("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
    "\x34\xAA\x97\x3C\xD4\xC4\xDA\xA4\xF6\x1E\xEB\x2B\xDB\xAD\x27\x31\x65\x34\x01\x6F", // sha1("a" * 1000000)
    "\xDE\xA3\x56\xA2\xCD\xDD\x90\xC7\xA7\xEC\xED\xC5\xEB\xB5\x63\x93\x4F\x46\x04\x52" // sha1("01234567" * 8 * 10)
};

int DGTi_Hash2RepeatCount[4] = {
    1,
    1,
    1000000,
    10
};

int DGT_Hash2Test(void)
{
    u8 digest[DGT_HASH2_DIGEST_SIZE];
    DGTHash2Context ctx;
    s32 result;
    s32 j, i;

    for (i = 0; i < 4; i++) {
        DGT_Hash2Reset(&ctx);

        for (j = 0; j < DGTi_Hash2RepeatCount[i]; j++) {
            const char *string = DGTi_Hash2SampleArray[i];
            DGT_Hash2SetSource(&ctx, string, strlen(string));
        }

        DGT_Hash2GetDigest(&ctx, digest);
        result = memcmp(digest, DGTi_Hash2ResultArray[i], DGT_HASH2_DIGEST_SIZE);
        if (result != 0) {
            break;
        }
    }

    return result == 0;
}

void DGT_Hash2CalcHmac(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len)
{
    DGTHash2Context sha1_ctx;
    u8 sha1_buf[DGT_HASH2_DIGEST_SIZE];

    DGTiHMACFuncs hash2func = { DGT_HASH2_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash2func.context = &sha1_ctx;
    hash2func.hash_buf = sha1_buf;
    hash2func.HashReset = (HashResetFunc)DGT_Hash2Reset;
    hash2func.HashSetSource = (HashSetSourceFunc)DGT_Hash2SetSource;
    hash2func.HashGetDigest = (HashGetDigestFunc)DGT_Hash2GetDigest;

    HmacCalc(digest, bin_ptr, bin_len, key_ptr, key_len, &hash2func);
}

int DGT_Hash2CalcHmacForRms(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len)
{
    DGTHash2Context sha1_ctx;
    u8 sha1_buf[DGT_HASH2_DIGEST_SIZE];

    DGTiHMACFuncs hash2func = { DGT_HASH2_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash2func.context = &sha1_ctx;
    hash2func.hash_buf = sha1_buf;
    hash2func.HashReset = (HashResetFunc)DGT_Hash2Reset;
    hash2func.HashSetSource = (HashSetSourceFunc)DGT_Hash2SetSource;
    hash2func.HashGetDigest = (HashGetDigestFunc)DGT_Hash2GetDigest;

    return Hmac_MakeForRMS(digest, romh_ptr, romh_len, mbin_ptr, mbin_len, sbin_ptr, sbin_len, key_ptr, key_len, &hash2func);
}

int DGT_Hash2TestHmacForRms(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len)
{
    DGTHash2Context sha1_ctx;
    u8 sha1_buf[DGT_HASH2_DIGEST_SIZE];

    DGTiHMACFuncs hash2func = { DGT_HASH2_DIGEST_SIZE, DGT_HASH_BLOCK_SIZE };

    hash2func.context = &sha1_ctx;
    hash2func.hash_buf = sha1_buf;
    hash2func.HashReset = (HashResetFunc)DGT_Hash2Reset;
    hash2func.HashSetSource = (HashSetSourceFunc)DGT_Hash2SetSource;
    hash2func.HashGetDigest = (HashGetDigestFunc)DGT_Hash2GetDigest;

    return Hmac_TestForRMS(digest, romh_ptr, romh_len, mbin_ptr, mbin_len, sbin_ptr, sbin_len, key_ptr, key_len, &hash2func);
}
