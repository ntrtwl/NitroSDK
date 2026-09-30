#ifndef NITRO_DGT_SHA1_ASM_H_
#define NITRO_DGT_SHA1_ASM_H_

#include <nitro/dgt/dgt.h>
#include <nitro/types.h>

void DGTi_hash2_arm4_small(DGTHash2Context *ctx, u8 *source, u32 length);
void DGTi_hash2_arm4_fast(DGTHash2Context *ctx, u8 *source, u32 length);

#endif
