#include "log.h"

#include <assert.h>
#include <windows.h>
#include <assert.h>
#include <ShlObj.h>

static FILE* file = NULL;
void onExitClean()
{
    if (NULL != file)
    {
        ::fclose(file);
        file = NULL;
    }
}

Log::Log(const std::wstring& strFilePath, const std::wstring& strFunctionName, int iLine)
    : m_strFilePath(strFilePath)
    , m_strFunctionName(strFunctionName)
    , m_iLine(iLine)
{
    Log::Write(InLevel, m_strFilePath, m_strFunctionName, m_iLine, _W(""));
}

Log::~Log()
{
    Log::Write(OutLevel, m_strFilePath, m_strFunctionName, m_iLine, _W(""));
}

void Log::Write(ENM_LOGGER_LEVEL logLevel,
    const std::wstring& strFilePath,
    const std::wstring& strFunctionName,
    int iLine,
    LPCWSTR pszFormat, ...)
{
    size_t iLastSlash = strFilePath.rfind(_W('\\'));
    std::wstring strFileName = (iLastSlash < strFilePath.size() - 1 ? strFilePath.substr(iLastSlash + 1) : strFilePath);

    std::wstring strModuleName = _W("[#");
    strModuleName.append(_GetModuleName());
    strModuleName.append(_W("#]"));

    std::wstring strPidAndTid = _W("[");
    strPidAndTid.append(_GetDWORString(::GetCurrentProcessId()));
    strPidAndTid.append(_W(", "));
    strPidAndTid.append(_GetDWORString(::GetCurrentThreadId()));
    strPidAndTid.append(_W("]"));

    std::wstring strDateTime = _GetDateTimeString();

    if (OutLevel != logLevel)
    {
        strFileName.append(_W(":"));
        strFileName.append(_GetDWORString(static_cast<DWORD>(iLine)));
    }

    const size_t nLogBufferLength = 14 * 4096;
    WCHAR szLog[nLogBufferLength] = { 0 };
    int nCount = ::swprintf_s(szLog, nLogBufferLength, _W("%-20s %-14s %-24s %-8s %-48s %-32s [")
        , strModuleName.c_str()
        , strPidAndTid.c_str()
        , strDateTime.c_str()
        , _GetLevel(logLevel).c_str()
        , _GetShortFuncName(strFunctionName).c_str()
        , strFileName.c_str());

    if (nCount < 0 || static_cast<size_t>(nCount) >= nLogBufferLength)
    {
        assert(FALSE);
        return;
    }

    va_list ap;
    va_start(ap, pszFormat);
    nCount += ::vswprintf_s(szLog + static_cast<size_t>(nCount), nLogBufferLength - static_cast<size_t>(nCount), pszFormat, ap);
    va_end(ap);

    if (nCount < 0 || static_cast<size_t>(nCount) >= nLogBufferLength)
    {
        assert(FALSE);
        return;
    }

    nCount += ::swprintf_s(szLog + static_cast<size_t>(nCount), nLogBufferLength - static_cast<size_t>(nCount), _W("]\n"));

    ::OutputDebugStringW(szLog);

    if (NULL == file)
    {
        std::atexit(onExitClean);
        file = _CreateFile();
    }

    if (NULL != file)
    {
        ::fputws(szLog, file);
        ::fflush(file);
    }
}

FILE* Log::_CreateFile()
{
    WCHAR fullPath[MAX_PATH] = { 0 };
    if (::SHGetFolderPathW(NULL, CSIDL_APPDATA, NULL, 0, fullPath) < 0)
    {
        ::OutputDebugStringW(L"SHGetFolderPathA CSIDL_APPDATA failed.\n");
        return NULL;
    }

    std::wstring logDir(fullPath);
    logDir.append(L"\\Tencent\\TRTCApp\\demolog\\");

    BOOL bRet = ::CreateDirectoryW(logDir.c_str(), NULL);
    if (FALSE == bRet && ERROR_ALREADY_EXISTS != ::GetLastError())
    {
        return NULL;
    }

    wchar_t filePath[MAX_PATH] = { 0 };
    for (int i = 0; ; ++i)  // 避免同名
    {
        SYSTEMTIME sys_time = { 0 };
        ::GetLocalTime(&sys_time);

        ::swprintf_s(filePath, _countof(filePath) - 1, L"%sTRTCApp_%04u_%02u_%02u_%02u_%02u_%02u_%d.log"
            , logDir.c_str()
            , sys_time.wYear, sys_time.wMonth, sys_time.wDay
            , sys_time.wHour, sys_time.wMinute, sys_time.wSecond, i);

        if (::GetFileAttributesW(filePath) == INVALID_FILE_ATTRIBUTES)
        {
            break;
        }
    }

    FILE* file = ::_wfsopen(filePath, L"wb+", _SH_DENYWR);

    return file;
}

std::wstring Log::_GetModuleName()
{
    // 获取当前代码所在模块的路径
    MEMORY_BASIC_INFORMATION stMemInfo = { 0 };
    ::VirtualQuery((PVOID)_GetModuleName, &stMemInfo, sizeof(MEMORY_BASIC_INFORMATION));

    HMODULE hModule = (HMODULE)stMemInfo.AllocationBase;

    WCHAR szFullPath[MAX_PATH] = { 0 };
    ::GetModuleFileNameW(hModule, szFullPath, MAX_PATH);

    LPWSTR lpszLastSlash = ::wcsrchr(szFullPath, _W('\\'));
    return (NULL == lpszLastSlash ? _W("") : lpszLastSlash + 1);
}

std::wstring Log::_GetShortFuncName(const std::wstring& strFunctionName)
{
    // 只包含类名和函数名

    if (strFunctionName.size() <= 2)
    {
        return strFunctionName;
    }

    std::size_t index1 = strFunctionName.rfind(_W("::"));
    if (std::wstring::npos == index1)
    {
        return strFunctionName;
    }
    else
    {
        std::size_t index2 = strFunctionName.rfind(_W("::"), 0 == index1 ? 0 : index1 - 1);
        return (std::wstring::npos == index2 ? strFunctionName : strFunctionName.substr(index2 + 2));
    }
}

std::wstring Log::_GetDateTimeString()
{
    SYSTEMTIME stTime = { 0 };
    ::GetLocalTime(&stTime);

    WCHAR szTmp[32] = { 0 };
    ::swprintf_s(szTmp, _countof(szTmp), _W("[%02u-%02u %02u:%02u:%02u.%u]"), stTime.wMonth, stTime.wDay
        , stTime.wHour, stTime.wMinute, stTime.wSecond, stTime.wMilliseconds);

    return szTmp;
}

std::wstring Log::_GetDWORString(DWORD dwVal)
{
    WCHAR szTmp[16] = { 0 };
    ::swprintf_s(szTmp, _countof(szTmp), _W("%ld"), dwVal);

    return szTmp;
}

std::wstring Log::_GetLevel(ENM_LOGGER_LEVEL logLevel)
{
    if (InLevel == logLevel)
    {
        return (_W("[IN]"));
    }
    else if (OutLevel == logLevel)
    {
        return (_W("[OUT]"));
    }
    else if (TrackLevel == logLevel)
    {
        return (_W("[T]"));
    }
    else if (InfoLevel == logLevel)
    {
        return (_W("[I]"));
    }
    else if (WarningLevel == logLevel)
    {
        return (_W("[W]"));
    }
    else if (ErrorLevel == logLevel)
    {
        return (_W("[E]"));
    }
    else if (FatalLevel == logLevel)
    {
        return (_W("[F]"));
    }
    else
    {
        assert(FALSE);
        return _W("");
    }
}
