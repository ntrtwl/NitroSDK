#ifndef NITRO_DGT_HMAC_H_
#define NITRO_DGT_HMAC_H_

#include <nitro/types.h>

typedef void (*HashResetFunc)(void *ctx);
typedef void (*HashSetSourceFunc)(void *ctx, const void *input, u32 length);
typedef void (*HashGetDigestFunc)(void *ctx, void *digest);

typedef struct DGTiHMACFuncs {
    const u32 dlength;
    const u32 blength;
    void *context;
    u8 *hash_buf;
    HashResetFunc HashReset;
    HashSetSourceFunc HashSetSource;
    HashGetDigestFunc HashGetDigest;
} DGTiHMACFuncs;

void HmacCalc(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len, DGTiHMACFuncs *funcs);
int Hmac_MakeForRMS(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len, DGTiHMACFuncs *funcs);
int Hmac_TestForRMS(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len, DGTiHMACFuncs *funcs);

#endif
