// stdafx.h : 标准系统包含文件的包含文件，
// 或是经常使用但不常更改的
// 特定于项目的包含文件
//

#pragma once


#define WIN32_LEAN_AND_MEAN             // 从 Windows 头中排除极少使用的资料
// Windows 头文件:
#include <windows.h>

// C 运行时头文件
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <tchar.h>
#include "resource.h"

#include <ObjBase.h>
#include "UIlib.h"
#include "UserMassegeIdDefine.h"
#include <gdiplus.h>
using namespace Gdiplus;
using namespace DuiLib;

//std::wstring a2w(const std::string &str, unsigned int codePage = CP_ACP);
//std::string w2a(const std::wstring &wstr, unsigned int codePage = CP_ACP);
//std::string UTF8ToANSI(const std::string& str);
//std::string ANSIToUTF8(const std::string& str);

#ifndef FormatStr
#define FormatStr(str, buffSize, ...) { char buf[buffSize]={0}; sprintf_s(buf, buffSize, __VA_ARGS__); str = buf; }
#endif //FormatStr

#ifndef UNICODE
#define TString            std::string
#define TStr2A(str)        (str)
#else
#define TString            std::wstring
#define TStr2A(str)        w2a(str)
#endif//UNICODE
