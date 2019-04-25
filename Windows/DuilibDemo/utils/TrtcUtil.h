#pragma once
#include <string>
namespace TrtcUtil
{
    std::string genRandomNumString(int length); //length > 0 && length <= 20
    std::wstring getAppDirectory();
}
