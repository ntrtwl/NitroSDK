#include "nitro/cht/pictocatch.h"

typedef struct AwcSystemGameInfo {
    vu16 parent_type;
    vu16 debug_info;
    vu8 active_channel;
    vu8 child_num;
    vu16 protocol_version;
} AwcSystemGameInfo;

#define AWC_PROTOCOL_VERSION 0x4

enum AWCParentInfo {
    AWC_PARENTINFO_PSEUDO = 0x2348,
    AWC_PARENTINFO_PARENT = 0xBD8A,
};

BOOL CHT_IsPictochatParent(const WMBssDesc *pWmBssDesc)
{
    AwcSystemGameInfo info;

    if (pWmBssDesc == NULL) {
        return FALSE;
    }
    if (pWmBssDesc->gameInfoLength == 0) {
        return FALSE;
    }

    MI_CpuCopy8(pWmBssDesc->gameInfo.userGameInfo, &info, sizeof(AwcSystemGameInfo));
    DC_StoreRange(&info, sizeof(AwcSystemGameInfo));

    return pWmBssDesc->gameInfo.ggid == 0
        && (info.parent_type == AWC_PARENTINFO_PSEUDO || info.parent_type == AWC_PARENTINFO_PARENT)
        && info.protocol_version == AWC_PROTOCOL_VERSION;
}

int CHT_GetPictochatClientNum(const WMBssDesc *pWmBssDesc)
{
    AwcSystemGameInfo info;

    if (pWmBssDesc == NULL) {
        return -1;
    }
    if (pWmBssDesc->gameInfoLength == 0) {
        return -1;
    }

    MI_CpuCopy8(pWmBssDesc->gameInfo.userGameInfo, &info, sizeof(AwcSystemGameInfo));
    DC_StoreRange(&info, sizeof(AwcSystemGameInfo));

    return info.child_num;
}

int CHT_GetPictochatRoomNumber(const WMBssDesc *pWmBssDesc)
{
    AwcSystemGameInfo info;

    if (pWmBssDesc == NULL) {
        return -1;
    }
    if (pWmBssDesc->gameInfoLength == 0) {
        return -1;
    }

    MI_CpuCopy8(pWmBssDesc->gameInfo.userGameInfo, &info, sizeof(AwcSystemGameInfo));
    DC_StoreRange(&info, sizeof(AwcSystemGameInfo));

    return info.active_channel;
}
