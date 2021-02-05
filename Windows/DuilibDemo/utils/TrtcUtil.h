#pragma once
#include <string>
#include <map>
#include <windows.h>

namespace TrtcUtil
{
    std::string genRandomNumString(int length); //length > 0 && length <= 20
    std::wstring getAppDirectory();
    void getSizeAlign16(long originWidth, long originHeight, long& align16Width, long& align16Height);
    void convertCaptureResolution(int resolution, long& width, long& height);
    
    std::wstring convertMSToTime(long lCurMS,long lDurationMS);

    std::map<int,std::string> split(char* str, const char* pattern);

    bool SaveBitmapToFile(HBITMAP bitmap, const std::string& filename);  //保存位图到文件
    WORD GetBitmapBitCount();  //计算位图文件每个像素所占字节数
    void ProcessPalette(HBITMAP hBitmap, const BITMAP& bitmap, DWORD paletteSize,
                               LPBITMAPINFOHEADER lpBmpInfoHeader);  //处理调色板
}
