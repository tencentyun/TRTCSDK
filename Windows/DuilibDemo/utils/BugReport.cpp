#include "BugReport.h"
#include "crash_agent.h"
BugReport::BugReport() {

}

BugReport::~BugReport() {

}

bool BugReport::LoadCrashMonitor() {
    if (CreateCrashAgent("bugreport.dll", &crash_agent_) == CrashAgentResult::kSuccess) {
        return true;
    }
    return false;
}

bool BugReport::InitCrashMonitor(int nMajorVersion,int nMinorVersion,int nBuild) {
    if (crash_agent_){
        crash_agent_->Install(L"TRTC", L"TRTCDuilibDemo", nMajorVersion,  nMinorVersion, nBuild);
        return true;
    }
    return false;
}
