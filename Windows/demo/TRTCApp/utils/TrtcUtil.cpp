#include "TrtcUtil.h"
#include <time.h>
#include <windows.h>

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
