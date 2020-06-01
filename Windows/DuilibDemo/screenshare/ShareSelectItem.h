#pragma once
#include <TRTCCloudDef.h>
#include "UIlib.h"
using namespace DuiLib;

class ShareSelectItem : public IDialogBuilderCallback
{
public:
    ShareSelectItem();
    ~ShareSelectItem();

    CVerticalLayoutUI* CreateControl(CPaintManagerUI* pManager);
    void setWndInfo(const TRTCScreenCaptureSourceInfo& info);
    TRTCScreenCaptureSourceInfo getWndInfo();
    bool checkSelect(CControlUI* pSender);
    void select(bool bSelected);
    HWND getHwnd();

private:
    virtual CControlUI* CreateControl(LPCTSTR pstrClass) override;

private:
    CVerticalLayoutUI*    m_pRootControl = NULL;
    TRTCScreenCaptureSourceInfo m_info;
    std::string m_sourceName;
};

