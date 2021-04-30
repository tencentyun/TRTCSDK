// HelloDuilib.cpp : 定义应用程序的入口点。
//

#include "stdafx.h"
#include "TRTCMainViewController.h"
#include "TRTCLoginViewController.h"
#include "DataCenter.h"
#include "TRTCCloudCore.h"
#include "util/crashdump.h"
#include <windows.h>
#include <TlHelp32.h>
#include "util/log.h"
#include "utils/TrtcUtil.h"
#include "Utils/BugReport.h"
LPBYTE g_lpResourceZIPBuffer = NULL;
void InitResource()
{
    // 资源类型
#ifdef _DEBUG
    CPaintManagerUI::SetResourceType(UILIB_FILE);
    //CPaintManagerUI::SetResourceType(UILIB_ZIPRESOURCE);
#else
    CPaintManagerUI::SetResourceType(UILIB_FILE);
    //CPaintManagerUI::SetResourceType(UILIB_ZIPRESOURCE);
#endif
    // 资源路径
    CDuiString strResourcePath = CPaintManagerUI::GetInstancePath();
    // 加载资源
    switch (CPaintManagerUI::GetResourceType())
    {
    case UILIB_FILE:
    {
        strResourcePath += _T("trtcskin");
        CPaintManagerUI::SetResourcePath(strResourcePath.GetData());
        break;
    }
    case UILIB_ZIPRESOURCE:
    {
        /*
        strResourcePath += _T("trtcskin");
        CPaintManagerUI::SetResourcePath(strResourcePath.GetData());

        HRSRC hResource = ::FindResource(CPaintManagerUI::GetResourceDll(), MAKEINTRESOURCE(IDR_ZIPRES_SKIN), _T("ZIPRES"));
        if (hResource == NULL)
            return;
        HGLOBAL hGlobal = ::LoadResource(CPaintManagerUI::GetResourceDll(), hResource);
        DWORD dwSize = 0;
        if (hGlobal == NULL)
        {
            ::FreeResource(hResource);
            return;
        }
        dwSize = ::SizeofResource(CPaintManagerUI::GetResourceDll(), hResource);
        if (dwSize == 0)
            return;
        g_lpResourceZIPBuffer = new BYTE[dwSize];
        if (g_lpResourceZIPBuffer != NULL)
        {
            ::CopyMemory(g_lpResourceZIPBuffer, (LPBYTE)::LockResource(hGlobal), dwSize);
        }
        ::FreeResource(hResource);
        CPaintManagerUI::SetResourceZip(g_lpResourceZIPBuffer, dwSize);
        */
    }
    break;
    }
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPSTR /*lpCmdLine*/, int nCmdShow)
{
    LINFO(L"WinMain:: App run begin");
 
    PROCESSENTRY32 pe32;
    pe32.dwSize = sizeof(pe32);

    HANDLE hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hProcessSnap == INVALID_HANDLE_VALUE) {
        return false;
    }

    BOOL bResult = Process32First(hProcessSnap, &pe32);
    int count = 0;
    while (bResult)
    {
        if (!wcscmp(pe32.szExeFile, L"TRTCDuilibDemo.exe"))
        {
            count++;
        }
        bResult = Process32Next(hProcessSnap, &pe32);
    }
    CloseHandle(hProcessSnap);

    if (count >= 2)
    {
        return false;
    }
    ::CoInitialize(NULL);
#ifdef _DEBUG
    //::MessageBoxW(NULL, NULL, NULL, MB_OK);   // 方便附加调试
#endif // DEBUG

    bool load_crash_monitor = false;
    BugReport * crash_report = new BugReport();
    CrashDump* crash_dump = nullptr ; 
    //先尝试加载crash上报模块。
    if (crash_report->LoadCrashMonitor()) {
        const char* str_sdk_version = TRTCCloudCore::GetInstance()->getTRTCCloud()->getSDKVersion();
        std::map<int, std::string> version_map = TrtcUtil::split(const_cast<char *>(str_sdk_version), ".");
        if (version_map.size() >= 4) {
            load_crash_monitor = crash_report->InitCrashMonitor(stoi(version_map[0].c_str()), stoi(version_map[1].c_str()), stoi(version_map[3].c_str()));
        }
    }

    //如果加载crash上报模块失败，则加载本地crash捕获模块。
    if (!load_crash_monitor) {
        delete crash_report;
        crash_report = nullptr;
        crash_dump = new CrashDump();
    }

    CPaintManagerUI::SetInstance(hInstance);
    InitResource();

    CDataCenter::GetInstance()->Init();

    TRTCLoginViewController* pLogin = new TRTCLoginViewController();
    if (pLogin == NULL) return 0;
    pLogin->Create(NULL, _T("TRTCDuilibDemo"), WS_VISIBLE | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, WS_EX_WINDOWEDGE);
    pLogin->CenterWindow();
    pLogin->ShowWindow(true);

    CPaintManagerUI::MessageLoop();
    ::CoUninitialize();

    TRTCCloudCore::Destory();

    if (crash_dump) {
        delete crash_dump;
        crash_dump = nullptr;
    }

    LINFO(L"WinMain:: App quit end");
    return 0;
}
