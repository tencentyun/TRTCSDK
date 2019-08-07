#ifndef __TMPLOG_H__
#define __TMPLOG_H__

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <string>
#include <assert.h>

// 宽字符转换宏
#define __W(str)    L##str
#define _W(str)     __W(str)

typedef enum LOGGER_LEVEL
{
    TrackLevel      = 0,
    InfoLevel       = 1,
    WarningLevel    = 2,
    ErrorLevel      = 3,
    FatalLevel      = 4,

    // 标识函数进入和退出
    InLevel         = 5,
    OutLevel        = 6
} ENM_LOGGER_LEVEL;

class Log
{
public:
    Log(const std::wstring& strFilePath, const std::wstring& strFunctionName, int iLine);
    ~Log();
public:
    static void Write(ENM_LOGGER_LEVEL logLevel,
        const std::wstring& strFilePath,
        const std::wstring& strFunctionName,
        int iLine,
        LPCWSTR pszFormat, ...);
public:
    static FILE* _CreateFile();
    static std::wstring _GetModuleName();
    static std::wstring _GetShortFuncName(const std::wstring& strFunctionName);
    static std::wstring _GetDateTimeString();
    static std::wstring _GetDWORString(DWORD dwVal);
    static std::wstring _GetLevel(ENM_LOGGER_LEVEL logLevel);
private:
    const std::wstring      m_strFilePath;
    const std::wstring      m_strFunctionName;
    int                     m_iLine;
};

#if defined(USE_LOG)
    #define LTRACE(formatstr, ...)      Log::Write(TrackLevel,    _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__)
    #define LINFO(formatstr, ...)       Log::Write(InfoLevel,     _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__)

    #define LWARNING(formatstr, ...)                                                                            \
            do                                                                                                  \
            {                                                                                                   \
                Log::Write(WarningLevel, _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__);   \
                assert(FALSE);                                                                               \
            } while (false)

    #define LERROR(formatstr, ...)                                                                              \
            do                                                                                                  \
            {                                                                                                   \
                Log::Write(ErrorLevel, _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__);     \
                assert(FALSE);                                                                               \
            } while (false)

    #define LFATAL(formatstr, ...)                                                                              \
            do                                                                                                  \
            {                                                                                                   \
                Log::Write(FatalLevel, _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__);     \
                assert(FALSE);                                                                               \
            } while (false)

    #define LOGOUT(level, formatstr, ...)                                                                       \
            do                                                                                                  \
            {                                                                                                   \
                Log::Write(level, _W(__FILE__), _W(__FUNCTION__), __LINE__, formatstr, ##__VA_ARGS__)           \
                if (WarningLevel == level || ErrorLevel == level || FatalLevel == level)                        \
                {                                                                                               \
                    assert(FALSE);                                                                           \
                }                                                                                               \
            } while (false)

    #define LOGGER                      Log __tmp_logger__(_W(__FILE__), _W(__FUNCTION__), __LINE__)
#else
    #define LTRACE(formatstr, ...)
    #define LINFO(formatstr, ...)
    #define LWARNING(formatstr, ...)
    #define LERROR(formatstr, ...)
    #define LFATAL(formatstr, ...)
    #define LOGOUT(level, formatstr, ...)

    #define LOGGER
#endif

#endif /* __TMPLOG_H__ */
