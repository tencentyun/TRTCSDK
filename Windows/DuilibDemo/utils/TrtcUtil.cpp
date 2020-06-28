#include "TrtcUtil.h"
#include <time.h>
#include <windows.h>
#include <cmath>
#include "TRTCCloudDef.h"

std::string TrtcUtil::genRandomNumString(int length)
{
    int flag, i;
    std::string calStr = "12345678901234567890";
    if (length <= 0 || length > 20)
        return calStr;

    srand((unsigned)time(NULL));

    for (i = 0; i < length; i++)
    {
        flag = 2;//= rand() % 3;          
        switch (flag)
        {
            //case 0: retStr[i] = 'A' + rand() % 26; break;
            //case 1: retStr[i] = 'a' + rand() % 26; break;              
        case 2: calStr[i] = '0' + rand() % 10; break;
        default: calStr[i] = 'x'; break;
        }
    }

    return calStr.substr(0, length);
}

std::wstring TrtcUtil::getAppDirectory()
{
    wchar_t szCurrentDirectory[MAX_PATH] = { 0 };
    DWORD dwCurDirPathLen;
    dwCurDirPathLen = ::GetModuleFileNameW(NULL, szCurrentDirectory, MAX_PATH);
    std::wstring appPath;
    appPath = szCurrentDirectory;
    int pos = appPath.find_last_of(L'\\');
    int size = appPath.size();
    std::wstring _appFilePath = appPath.erase(pos, size);
    _appFilePath += L"\\";
    return _appFilePath;
}

void TrtcUtil::getSizeAlign16(long originWidth, long originHeight, long & align16Width, long & align16Height)
{
    // 转换16对齐的宽高
    // 宽度和高度能被16整除，并尽量保留宽高比

    // 640x360 或 360x640，通常换算为640x368 或 368x640，但实际656x368 或 368x656更加接近原始宽高比，做下适配
    if (640 == originWidth && 360 == originHeight)
    {
        align16Width = 640;
        align16Height = 368;

        return;
    }
    else if (360 == originWidth && 640 == originHeight)
    {
        align16Width = 368;
        align16Height = 640;

        return;
    }

    bool isWidthAlign16 = (0 == originWidth % 16);
    bool isHeightAlign16 = (0 == originHeight % 16);
    if (isWidthAlign16 && isHeightAlign16) {
        align16Width = originWidth;
        align16Height = originHeight;
    }
    else if (!isWidthAlign16 && isHeightAlign16) {
        align16Width = (originWidth + 15) / 16 * 16;

        double originRatio = (double)originWidth / originHeight;
        double modRatio = (double)align16Width / originHeight;
        double add16Ratio = (double)align16Width / (originHeight + 16);
        if (std::fabs(modRatio - originRatio) <= std::fabs(add16Ratio - originRatio)) {
            align16Height = originHeight;
        }
        else {
            align16Height = originHeight + 16;
        }
    }
    else if (isWidthAlign16 && !isHeightAlign16) {
        align16Height = (originHeight + 15) / 16 * 16;

        double originRatio = (double)originWidth / originHeight;
        double modRatio = (double)originWidth / align16Height;
        double add16Ratio = (double)(originWidth + 16) / align16Height;
        if (std::fabs(modRatio - originRatio) <= std::fabs(add16Ratio - originRatio)) {
            align16Width = originWidth;
        }
        else {
            align16Width = originWidth + 16;
        }
    }
    else { // !isWidthAlign16 && !isHeightAlign16
        align16Width = (originWidth + 15) / 16 * 16;
        align16Height = (originHeight + 15) / 16 * 16;
    }
}

void TrtcUtil::convertCaptureResolution(int resolution, long & width, long & height)
{
    switch (resolution)
    {
    case TRTCVideoResolution_120_120:
        getSizeAlign16(120, 120, width, height);
        break;
    case TRTCVideoResolution_160_160:
        getSizeAlign16(160, 160, width, height);
        break;
    case TRTCVideoResolution_270_270:
        getSizeAlign16(270, 270, width, height);
        break;
    case TRTCVideoResolution_480_480:
        getSizeAlign16(480, 480, width, height);
        break;
    case TRTCVideoResolution_160_120:
        getSizeAlign16(160, 120, width, height);
        break;
    case TRTCVideoResolution_240_180:
        getSizeAlign16(240, 180, width, height);
        break;
    case TRTCVideoResolution_280_210:
        getSizeAlign16(280, 210, width, height);
        break;
    case TRTCVideoResolution_320_240:
        getSizeAlign16(320, 240, width, height);
        break;
    case TRTCVideoResolution_400_300:
        getSizeAlign16(400, 300, width, height);
        break;
    case TRTCVideoResolution_480_360:
        getSizeAlign16(480, 360, width, height);
        break;
    case TRTCVideoResolution_640_480:
        getSizeAlign16(640, 480, width, height);
        break;
    case TRTCVideoResolution_960_720:
        getSizeAlign16(960, 720, width, height);
        break;
    case TRTCVideoResolution_160_90:
        getSizeAlign16(160, 90, width, height);
        break;
    case TRTCVideoResolution_256_144:
        getSizeAlign16(256, 144, width, height);
        break;
    case TRTCVideoResolution_320_180:
        getSizeAlign16(320, 180, width, height);
        break;
    case TRTCVideoResolution_480_270:
        getSizeAlign16(480, 270, width, height);
        break;
    case TRTCVideoResolution_640_360:
        getSizeAlign16(640, 360, width, height);
        break;
    case TRTCVideoResolution_960_540:
        getSizeAlign16(960, 540, width, height);
        break;
    case TRTCVideoResolution_1280_720:
        getSizeAlign16(1280, 720, width, height);
        break;
    case TRTCVideoResolution_1920_1080:
        getSizeAlign16(1920, 1080, width, height);
        break;
    default:
        break;
    }
}

std::wstring TrtcUtil::convertMSToTime(long lCurMS, long lDurationMS)
{
    std::wstring strTime = L"00:00/00:00";

    int nTotalDurationSecond = lDurationMS / 1000;
    int nDurationMinute = nTotalDurationSecond / 60;
    int nDurationSecond = nTotalDurationSecond % 60;

    int nTotalCurSecond = lCurMS / 1000;
    int nCurMinute = nTotalCurSecond / 60;
    int nCurSecond = nTotalCurSecond % 60;

    wchar_t buf[1024];
    wsprintf(buf, L"%02d:%02d/%02d:%02d", nCurMinute, nCurSecond, nDurationMinute, nDurationSecond);

    strTime = buf;

    return strTime;
}
