#pragma once
class ICrashAgent;
class BugReport {
public:
    BugReport();
    ~BugReport();
public:
    bool LoadCrashMonitor();
    bool InitCrashMonitor(int nMajorVersion, int nMinorVersion, int nBuild);

private:
    ICrashAgent* crash_agent_ = nullptr;
};

