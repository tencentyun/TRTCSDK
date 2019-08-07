#pragma once
#include <string>
namespace TrtcUtil
{
    std::string genRandomNumString(int length); //length > 0 && length <= 20
    std::wstring getAppDirectory();
    void getSizeAlign16(long originWidth, long originHeight, long& align16Width, long& align16Height);
    void convertCaptureResolution(int resolution, long& width, long& height);
}
