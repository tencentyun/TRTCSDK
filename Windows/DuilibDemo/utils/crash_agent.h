#ifndef CRASH_AGENT_DEFINE_H_
#define CRASH_AGENT_DEFINE_H_

#include <stdint.h>
#include <stdlib.h>
#include <strsafe.h>
#include <windows.h>


#ifndef CA_INLINE
  #define CA_INLINE __forceinline
#endif // !CA_INLINE

#ifndef CA_EXPORT
  #define CA_EXPORT WINAPI
#endif // !CA_INLINE

enum class CrashAgentResult : uint32_t {
  kSuccess = 0,
  kNotFound
};

class ICrashAgent;
using PfCrashCallback = void(*)(ICrashAgent*, void*);

class ICrashAgent
{
public:
  virtual void Install(const wchar_t* name = nullptr, 
      const wchar_t* disp_name = nullptr, int nMajorVersion = 1, int nMinorVersion = 1, int nBuild = 1) = 0;
  virtual void SetCrashCallback(PfCrashCallback callback, void* context) = 0;
  virtual void SetAttachFile(const wchar_t* first, ...) = 0;
  virtual void SetBugReportUin(DWORD dwUin, BOOL bSuccLogin= FALSE) = 0;
  virtual BOOL SetExtInfo(DWORD dwExt1, DWORD dwExt2, LPCTSTR lpszExt3) = 0;
};

using PfCreateCrashAgent = ICrashAgent* (CA_EXPORT*)();

CA_INLINE CrashAgentResult CreateCrashAgent(const char* agent_name, ICrashAgent** agent) {
  char agent_dll[MAX_PATH];

  ::StringCchCopyA(agent_dll, _countof(agent_dll), agent_name);
  if (strstr(agent_name, ".dll") == nullptr) {
    ::StringCchCatA(agent_dll, _countof(agent_dll), ".dll");
  }

  auto handle = ::LoadLibraryA(agent_dll);
  if (handle == nullptr) {
    return CrashAgentResult::kNotFound;
  }

  auto create_func = reinterpret_cast<PfCreateCrashAgent>(::GetProcAddress(handle, "CreateCrashAgent"));
  if (create_func == nullptr) {
    return CrashAgentResult::kNotFound;
  }

  *agent = create_func();
  return CrashAgentResult::kSuccess;
}

#endif
