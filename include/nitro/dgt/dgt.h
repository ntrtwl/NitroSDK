#ifndef NITRO_DGT_DGT_H_
#define NITRO_DGT_DGT_H_

#include <nitro/dgt/common.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct DGTHash1Context {
	union {
		struct {
			u32 a, b, c, d;
		};
		u32 state[4];
	};
	u64 length;
	union {
		u32 buffer32[16];
		u8 buffer8[64];
	};
} DGTHash1Context;

#if defined(SDK_DGT_HASH2_CODE_SAFE) || defined(SDK_WIN32) || defined(SDK_FROM_TOOL)
    typedef struct DGTHash2Context {
        u32 Intermediate_Hash[5];
        u32 Length_Low;
        u32 Length_High;
        int Message_Block_Index;
        u8 Message_Block[64];
        int Computed;
        int Corrupted;
    } DGTHash2Context;
#else
    typedef struct DGTHash2Context {
        u32 h0, h1, h2, h3, h4;
        u32 Nl, Nh;
        int num;
        u32 data[64 / 4];
        int dummy[2];
    } DGTHash2Context;
#endif

#ifdef SDK_DGT_HASH1_CODE_SAFE
    void DGT_Hash1Reset(DGTHash1Context *ctx);
    void DGT_Hash1SetSource(DGTHash1Context *ctx, u8 *input, u32 length);
    void DGT_Hash1GetDigest_R(u8 digest[16], DGTHash1Context *ctx);
#else
    void DGT_Hash1Reset(DGTHash1Context *ctx);
    void DGT_Hash1SetSource(DGTHash1Context *ctx, const void *input, u32 length);
    void DGT_Hash1GetDigest_R(void *digest, DGTHash1Context *ctx);
#endif

#if defined(SDK_DGT_HASH2_CODE_SAFE) || defined(SDK_WIN32) || defined(SDK_FROM_TOOL)
    void DGT_Hash2Reset(DGTHash2Context *ctx);
    void DGT_Hash2SetSource(DGTHash2Context *ctx, u8 *input, u32 length);
    void DGT_Hash2GetDigest(DGTHash2Context *ctx, u8 digest[20]);
#else
    void DGT_Hash2Reset(DGTHash2Context *ctx);
    void DGT_Hash2SetSource(DGTHash2Context *ctx, const u8 *input, u32 length);
    void DGT_Hash2GetDigest(DGTHash2Context *ctx, u8 *digest);
#endif

void DGT_Hash1CalcHmac(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len);
void DGT_Hash2CalcHmac(void *digest, void *bin_ptr, int bin_len, void *key_ptr, int key_len);

int DGT_Hash1CalcHmacForRms(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len);
int DGT_Hash2CalcHmacForRms(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len);
int DGT_Hash1TestHmacForRms(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len);
int DGT_Hash2TestHmacForRms(void *digest, void *romh_ptr, int romh_len, void *mbin_ptr, int mbin_len, void *sbin_ptr, int sbin_len, void *key_ptr, int key_len);
int DGT_SetOverlayTableMode(int flag);

#ifdef __cplusplus
}
#endif

#endif
