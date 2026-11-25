#include "nitro/irc/irc.h"

#include <nitro.h>

#define COMMAND_READ  1
#define COMMAND_WRITE 2
#define COMMAND_CHECK 8

typedef struct IRCHeader {
    u8 command;
    u8 unitId;
    u8 sumL;
    u8 sumH;
    u32 uniqueId;
} IRCHeader;

#define COM_DATA_SIZE (180 - 4)
#define COM_TRNS_SIZE (1 + sizeof(IRCHeader) + COM_DATA_SIZE)

typedef struct IRCParam {
    u32 addr_width;
    u32 src;
    u32 dst;
    BOOL cmp;
} IRCParam;

static u8 irc_read_wait;
static u8 irc_write_wait;
static u8 irc_command_wait;

static u16 irc_lock_id = (u16)OS_LOCK_ID_ERROR;
static IRCParam irc_param;

static u8 sSendBuf[COM_TRNS_SIZE] ATTRIBUTE_ALIGN(4);
static u8 sRecvBuf[COM_TRNS_SIZE] ATTRIBUTE_ALIGN(4);

void IRC_SetReadWait(u8 time)
{
    irc_read_wait = time;
}

void IRC_SetWriteWait(u8 time)
{
    irc_write_wait = time;
}

static void IRCi_WaitCommand(void)
{
    OSTick time = OS_GetTick();
    while (OS_TicksToMicroSeconds(OS_GetTick() - time) < irc_command_wait) {
    }
}

void IRC_Init(void)
{
    irc_read_wait = 50;
    irc_write_wait = 50;
    irc_command_wait = 50;
    irc_param.addr_width = 1;

    if (irc_lock_id == (u16)OS_LOCK_ID_ERROR) {
        irc_lock_id = OS_GetLockID();
    }
}

void IRC_End(void)
{
    // bug: this is always true, should be (u16)OS_LOCK_ID_ERROR instead
    if (irc_lock_id != OS_LOCK_ID_ERROR) {
        OS_ReleaseLockID(irc_lock_id);
        irc_lock_id = (u16)OS_LOCK_ID_ERROR;
    }
}

SDK_INLINE void IRCi_EnableSpi(u32 cont)
{
    reg_MI_MCCNT0 = MCCNT0_MASTER_ON | MCCNT0_INT_OFF | MMCNT0_SEL_SPI | cont;
}

SDK_INLINE void IRCi_WaitBusy(void)
{
    while ((reg_MI_MCCNT0 & MCCNT0_SPI_BUSY) != 0) {
    }
}

static u8 IRCi_CommWrite(IRCParam *p)
{
    OSTick time = OS_GetTick();

    while (OS_TicksToMicroSeconds(OS_GetTick() - time) < irc_write_wait) {
    }

    reg_MI_MCD0 = MI_ReadByte((void *)p->src);

    p->src++;
    IRCi_WaitBusy();
    vu16 tmp = reg_MI_MCD0;

    return tmp;
}

static void IRCi_CommRead(IRCParam *p)
{
    OSTick time = OS_GetTick();

    while (OS_TicksToMicroSeconds(OS_GetTick() - time) < irc_read_wait) {
    }

    reg_MI_MCD0 = 0;
    IRCi_WaitBusy();

    MI_WriteByte((void *)p->dst, reg_MI_MCD0);

    p->dst++;
}

u8 IRC_Read(u8 *buf)
{
    irc_param.src = (u32)sRecvBuf;
    irc_param.dst = (u32)buf;
    sRecvBuf[0] = COMMAND_READ;
    buf[0] = 0;

    CARD_LockBackup(irc_lock_id);
    OS_LockCard(irc_lock_id);
    IRCi_WaitBusy();

    IRCi_EnableSpi(CSPI_CONTINUOUS_ON | MCCNT0_SPI_CLK_1M);
    IRCi_CommWrite(&irc_param);
    IRCi_WaitCommand();
    IRCi_CommRead(&irc_param);
    IRCi_WaitCommand();

    u8 size = buf[0];
    if (size > COM_TRNS_SIZE) {
        size = 0;
    }
    irc_param.src = (u32)NULL;
    irc_param.dst = (u32)buf;
    buf[0] = 0;
    int i;

    if (size != 0) {
        for (i = 0; i < size; i++) {
            if (i == size - 1) {
                IRCi_EnableSpi(CSPI_CONTINUOUS_OFF | MCCNT0_SPI_CLK_1M);
            }
            IRCi_CommRead(&irc_param);
        }
    } else {
        IRCi_EnableSpi(CSPI_CONTINUOUS_OFF | MCCNT0_SPI_CLK_1M);
        IRCi_CommRead(&irc_param);
    }

    for (i = 0; i < size; i++) {
        buf[i] ^= IRC_MAGIC;
    }

    IRCi_WaitBusy();
    OS_UnLockCard(irc_lock_id);
    CARD_UnlockBackup(irc_lock_id);
    return size;
}

void IRC_Write(u8 *data, u8 size)
{
    irc_param.src = (u32)sSendBuf;
    irc_param.dst = (u32)NULL;
    sSendBuf[0] = COMMAND_WRITE;

    CARD_LockBackup(irc_lock_id);
    OS_LockCard(irc_lock_id);
    IRCi_WaitBusy();

    IRCi_EnableSpi(CSPI_CONTINUOUS_ON | MCCNT0_SPI_CLK_1M);
    IRCi_CommWrite(&irc_param);
    IRCi_WaitCommand();

    irc_param.src = (u32)data;
    for (int i = 0; i < size; i++) {
        if (i == size - 1) {
            IRCi_EnableSpi(CSPI_CONTINUOUS_OFF | MCCNT0_SPI_CLK_1M);
        }
        IRCi_CommWrite(&irc_param);
    }

    IRCi_WaitBusy();
    OS_UnLockCard(irc_lock_id);
    CARD_UnlockBackup(irc_lock_id);
}

u8 IRC_Check(void)
{
    u8 buf[2];
    irc_param.src = (u32)sRecvBuf;
    irc_param.dst = (u32)buf;
    sRecvBuf[0] = COMMAND_CHECK;

    CARD_LockBackup(irc_lock_id);
    OS_LockCard(irc_lock_id);

    OSTick time = OS_GetTick();
    while (OS_TicksToMicroSeconds(OS_GetTick() - time) < 60) {
    }

    IRCi_WaitBusy();

    IRCi_EnableSpi(CSPI_CONTINUOUS_ON | MCCNT0_SPI_CLK_1M);
    buf[0] = IRCi_CommWrite(&irc_param);

    time = OS_GetTick();
    while (OS_TicksToMicroSeconds(OS_GetTick() - time) < 50) {
    }

    IRCi_EnableSpi(CSPI_CONTINUOUS_OFF | MCCNT0_SPI_CLK_1M);
    IRCi_CommRead(&irc_param);

    IRCi_WaitBusy();
    OS_UnLockCard(irc_lock_id);
    CARD_UnlockBackup(irc_lock_id);

    return buf[0];
}
