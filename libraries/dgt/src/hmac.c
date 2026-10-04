#include "hmac.h"

#include <nitro/dgt/dgt.h>
#include <nitro/os.h>
#include <nitro/types.h>

void HmacCalc(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len, DGTiHMACFuncs *funcs)
{
    if (digest == NULL || bin_ptr == NULL || bin_len == 0 || key_ptr == NULL || key_len == 0 || funcs == NULL) {
        return;
    }

    // If the key is too long, it is hashed down
    u8 *kp = (u8 *)key_ptr;
    u8 hashed_key[DGT_HASH_BLOCK_SIZE];
    if (key_len > (int)funcs->blength) {
        funcs->HashReset(funcs->context);
        funcs->HashSetSource(funcs->context, key_ptr, key_len);
        funcs->HashGetDigest(funcs->context, hashed_key);
        kp = hashed_key;
        key_len = funcs->dlength;
    }

    // Create ipad key, xor-ed with 0x36
    int i;
    u8 key_ipad[DGT_HASH_BLOCK_SIZE];
    for (i = 0; i < key_len; i++) {
        key_ipad[i] = kp[i] ^ 0x36;
    }
    for (; i < (int)funcs->blength; i++) {
        key_ipad[i] = 0x36;
    }

    // Initialize hash with ipad key
    funcs->HashReset(funcs->context);
    funcs->HashSetSource(funcs->context, key_ipad, funcs->blength);

    // Add data following ipad
    funcs->HashSetSource(funcs->context, bin_ptr, bin_len);

    // Get intermediate digest
    funcs->HashGetDigest(funcs->context, funcs->hash_buf);

    // Create opad key, xor-ed with 0x5C
    u8 key_opad[DGT_HASH_BLOCK_SIZE];
    for (i = 0; i < key_len; i++) {
        key_opad[i] = kp[i] ^ 0x5C;
    }
    for (; i < (int)funcs->blength; i++) {
        key_opad[i] = 0x5C;
    }

    // Initialize hash with opad key
    funcs->HashReset(funcs->context);
    funcs->HashSetSource(funcs->context, key_opad, funcs->blength);

    // Add intermediate digest following opad
    funcs->HashSetSource(funcs->context, funcs->hash_buf, funcs->dlength);

    // Create final digest
    funcs->HashGetDigest(funcs->context, digest);
}

int Hmac_MakeForRMS(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len,
    DGTiHMACFuncs *funcs)
{
    if (romh_ptr == NULL || romh_len == 0) {
        return 0;
    }

    if (mbin_ptr == NULL || mbin_len == 0) {
        return 0;
    }

    if (sbin_ptr == NULL || sbin_len == 0) {
        return 0;
    }

    if (key_ptr == NULL || key_len == 0) {
        return 0;
    }

    // Allocate space for three digests
    u8 *digest_buf = (u8 *)OS_Alloc(funcs->dlength * 3);
    if (digest_buf == NULL) {
        return 0;
    }

    // Calculate HMAC digest of header, ARM9, ARM7 contiguously in the buffer
    HmacCalc(digest_buf, romh_ptr, romh_len, key_ptr, key_len, funcs);
    HmacCalc(digest_buf + funcs->dlength, mbin_ptr, mbin_len, key_ptr, key_len, funcs);
    HmacCalc(digest_buf + funcs->dlength * 2, sbin_ptr, sbin_len, key_ptr, key_len, funcs);

    // Output the HMAC digest of the intermediate buffer
    HmacCalc(digest, digest_buf, funcs->dlength * 3, key_ptr, key_len, funcs);

    OS_Free(digest_buf);
    return 1;
}

int Hmac_TestForRMS(void *digest,
    void *romh_ptr,
    int romh_len, // ROM header
    void *mbin_ptr,
    int mbin_len, // ARM9 binary
    void *sbin_ptr,
    int sbin_len, // ARM7 binary
    void *key_ptr,
    int key_len,
    DGTiHMACFuncs *funcs)
{
    // Allocate a buffer to hold the comparison digest
    u8 *buf = (u8 *)OS_Alloc(funcs->dlength);
    if (buf == NULL) {
        return 0;
    }

    // Calculate digest
    int result = Hmac_MakeForRMS(buf, romh_ptr, romh_len, mbin_ptr, mbin_len, sbin_ptr, sbin_len, key_ptr, key_len, funcs);
    if (result == 0) {
        OS_Free(buf);
        return 0;
    }

    // Constant-time comparison (for some reason) against the input digest
    int different = 0;
    for (int i = 0; i < (int)funcs->dlength; i++) {
        if (buf[i] != ((u8 *)digest)[i]) {
            different = 1;
        }
    }

    OS_Free(buf);

    if (different) {
        return 0;
    }

    return 1;
}
