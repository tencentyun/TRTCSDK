// stdafx.cpp : 只包括标准包含文件的源文件
// HelloDuilib.pch 将作为预编译头
// stdafx.obj 将包含预编译类型信息

#include "stdafx.h"

// TODO: 在 STDAFX.H 中
// 引用任何所需的附加头文件，而不是在此文件中引用

#pragma comment(lib, "Gdiplus.lib")

class GDIPlusHelper
{
public:
    GDIPlusHelper()
    {
        ::GdiplusStartup(&gdiplustoken, &gdiplusstartupinput, NULL);
    }

    ~GDIPlusHelper()
    {
        ::GdiplusShutdown(gdiplustoken);
    }

private:
    GdiplusStartupInput gdiplusstartupinput;
    ULONG_PTR gdiplustoken;
};
static GDIPlusHelper gdiplushelper;
