#include "TrtcUtil.h"
#include <time.h>
#include <windows.h>
#include <cmath>
#include <shlwapi.h>
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

std::map<int,std::string> TrtcUtil::split(char * str, const char * pattern)
{
    std::map<int,std::string> resultMap;
    char* tmpStr = strtok(str, pattern);
    int num = 0;
    while (tmpStr != NULL)
    {
        resultMap[num] = (std::string(tmpStr));
        tmpStr = strtok(NULL, pattern);
        num++;
    }
    return resultMap;
}

bool TrtcUtil::SaveBitmapToFile(HBITMAP hBitmap, const std::string& filename) {
    // 1. 创建位图文件
    const auto file = CreateFileA(filename.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                                  FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, nullptr);
    if (file == INVALID_HANDLE_VALUE) {
        return false;
    }

    // 2. 计算位图文件每个像素所占字节数
    const auto bitCount = GetBitmapBitCount();

    // 3. 获取位图结构
    BITMAP bitmap;
    ::GetObject(hBitmap, sizeof(bitmap), reinterpret_cast<LPSTR>(&bitmap));

    //位图中像素字节大小(32字节对齐)
    const DWORD bmBitsSize = ((bitmap.bmWidth * bitCount + 31) / 32) * 4 * bitmap.bmHeight;

    //调色板大小
    const DWORD paletteSize = 0;

    // 4. 构造位图信息头
    BITMAPINFOHEADER bmpInfoHeader;  //位图信息头结构
    bmpInfoHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmpInfoHeader.biWidth = bitmap.bmWidth;
    bmpInfoHeader.biHeight = bitmap.bmHeight;
    bmpInfoHeader.biPlanes = 1;
    bmpInfoHeader.biBitCount = bitCount;
    bmpInfoHeader.biCompression = BI_RGB;
    bmpInfoHeader.biSizeImage = 0;
    bmpInfoHeader.biXPelsPerMeter = 0;
    bmpInfoHeader.biYPelsPerMeter = 0;
    bmpInfoHeader.biClrImportant = 0;
    bmpInfoHeader.biClrUsed = 0;

    // 5. 构造位图文件头
    BITMAPFILEHEADER bmpFileHeader;
    bmpFileHeader.bfType = 0x4D42;  //"BM"
    //位图文件大小
    const DWORD dibSize =
        sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + paletteSize + bmBitsSize;
    bmpFileHeader.bfSize = dibSize;
    bmpFileHeader.bfReserved1 = 0;
    bmpFileHeader.bfReserved2 = 0;
    bmpFileHeader.bfOffBits = static_cast<DWORD>(sizeof(BITMAPFILEHEADER)) +
                              static_cast<DWORD>(sizeof(BITMAPINFOHEADER)) + paletteSize;

    // 6. 为位图内容分配内存
    const auto dib =
        GlobalAlloc(GHND, bmBitsSize + paletteSize + sizeof(BITMAPINFOHEADER));  //内存句柄
    const auto lpBmpInfoHeader =
        static_cast<LPBITMAPINFOHEADER>(GlobalLock(dib));  //指向位图信息头结构
    *lpBmpInfoHeader = bmpInfoHeader;

    // 7. 处理调色板
    ProcessPalette(hBitmap, bitmap, paletteSize, lpBmpInfoHeader);

    // 8. 写入文件
    DWORD written = 0;  //写入文件字节数
    WriteFile(file, reinterpret_cast<LPSTR>(&bmpFileHeader), sizeof(BITMAPFILEHEADER), &written,
              nullptr);  //写入位图文件头
    WriteFile(file, reinterpret_cast<LPSTR>(lpBmpInfoHeader), dibSize, &written,
              nullptr);  //写入位图文件其余内容

    // 9. 清理资源
    GlobalUnlock(dib);
    GlobalFree(dib);
    CloseHandle(file);

    return true;
}

WORD TrtcUtil::GetBitmapBitCount() {
    const auto dc = ::CreateDCA("DISPLAY", nullptr, nullptr, nullptr);
    //当前分辨率下每像素所占字节数
    const auto bits = ::GetDeviceCaps(dc, BITSPIXEL) * GetDeviceCaps(dc, PLANES);
    ::DeleteDC(dc);

    //位图中每像素所占字节数
    WORD bitCount;
    if (bits <= 1)
        bitCount = 1;
    else if (bits <= 4)
        bitCount = 4;
    else if (bits <= 8)
        bitCount = 8;
    else
        bitCount = 24;

    return bitCount;
}

void TrtcUtil::ProcessPalette(HBITMAP hBitmap, const BITMAP& bitmap, DWORD paletteSize,
                              LPBITMAPINFOHEADER lpBmpInfoHeader) {
    HANDLE oldPalette = nullptr;
    HDC dc = nullptr;
    const auto palette = GetStockObject(DEFAULT_PALETTE);
    if (palette != nullptr) {
        dc = ::GetDC(nullptr);
        oldPalette = ::SelectPalette(dc, static_cast<HPALETTE>(palette), FALSE);
        ::RealizePalette(dc);  //实现设备调色板
    }

    //获取该调色板下新的像素值
    GetDIBits(dc, hBitmap, 0, static_cast<UINT>(bitmap.bmHeight),
              reinterpret_cast<LPSTR>(lpBmpInfoHeader) + sizeof(BITMAPINFOHEADER) + paletteSize,
              reinterpret_cast<BITMAPINFO*>(lpBmpInfoHeader), DIB_RGB_COLORS);

    //恢复调色板
    if (oldPalette != nullptr) {
        ::SelectPalette(dc, static_cast<HPALETTE>(oldPalette), TRUE);
        ::RealizePalette(dc);
        ::ReleaseDC(nullptr, dc);
    }
}
