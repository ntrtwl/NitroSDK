#ifndef NITRO_IRC_H
#define NITRO_IRC_H

#include <nitro/types.h>

#define IRC_MAGIC 0xAA

void IRC_SetReadWait(u8 time);
void IRC_SetWriteWait(u8 time);
void IRC_Init(void);
void IRC_End(void);
u8 IRC_Read(u8 *buf);
void IRC_Write(u8 *data, u8 size);
u8 IRC_Check(void);

#endif // NITRO_IRC_H
