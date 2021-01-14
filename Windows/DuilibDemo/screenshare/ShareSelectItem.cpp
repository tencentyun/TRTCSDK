#include "stdafx.h"
#include "ShareSelectItem.h"
#include "ImageCanvas.h"
#include "util/Base.h"

ShareSelectItem::ShareSelectItem()
{
}

ShareSelectItem::~ShareSelectItem()
{
}

CVerticalLayoutUI* ShareSelectItem::CreateControl(CPaintManagerUI* pManager)
{
    CDialogBuilder builer;
    m_pRootControl = static_cast<CVerticalLayoutUI*>(builer.Create(_T("ShareSelectItem.xml"), NULL, this, pManager));
    return m_pRootControl;
}

void ShareSelectItem::setWndInfo(const TRTCScreenCaptureSourceInfo& info)
{
    m_info = info;

    CHorizontalLayoutUI* pHLayout = static_cast<CHorizontalLayoutUI*>(m_pRootControl->GetItemAt(2));
    CLabelUI* pLabel = static_cast<CLabelUI*>(pHLayout->GetItemAt(1));
    //pLabel->SetText(m_info.hwnd ? ToTStr(m_info.wndTitle).c_str() : _T("屏幕"));
    std::wstring sourceName = UTF82Wide(m_info.sourceName);
    if (sourceName.compare(L"Screen1") == 0)
        pLabel->SetText(_T("显示器-1"));
    else if (sourceName.compare(L"Screen2") == 0)
        pLabel->SetText(_T("显示器-2"));
    else if (sourceName.compare(L"Screen3") == 0)
        pLabel->SetText(_T("显示器-3"));
    else if (sourceName.compare(L"Screen4") == 0)
        pLabel->SetText(_T("显示器-4"));
    else if (sourceName.compare(L"Screen5") == 0)
        pLabel->SetText(_T("显示器-5"));
    else
    {
        pLabel->SetText(sourceName.c_str());
    }
    if (m_info.sourceName != nullptr)
    {
        m_sourceName.assign(m_info.sourceName);
    }
    m_info.sourceName = m_sourceName.c_str();

    CImageCanvas* pWndView = static_cast<CImageCanvas*>(m_pRootControl->GetItemAt(0));
    CControlUI* pControl = static_cast<CControlUI*>(m_pRootControl->GetItemAt(1));

    if (m_info.thumbBGRA.length == 0 || m_info.thumbBGRA.buffer == nullptr) {
        std::string iconData(m_info.iconBGRA.buffer, m_info.iconBGRA.length);
        pWndView->setPaintData(m_info.iconBGRA.width, m_info.iconBGRA.height, iconData);
    } else {
        std::string thumbData(m_info.thumbBGRA.buffer, m_info.thumbBGRA.length);
        pWndView->setPaintData(m_info.thumbBGRA.width, m_info.thumbBGRA.height, thumbData);
    }
    
    pWndView->SetVisible(true);
    pControl->SetVisible(false);
}

TRTCScreenCaptureSourceInfo ShareSelectItem::getWndInfo()
{
    return m_info;
}

bool ShareSelectItem::checkSelect(CControlUI* pSender)
{
    return pSender == m_pRootControl->GetItemAt(3);
}

void ShareSelectItem::select(bool bSelected)
{
    m_pRootControl->SetBkColor(bSelected ? 0xFFDFFFDF : 0x00000000);
}

HWND ShareSelectItem::getHwnd()
{
    return m_info.sourceId;
}

CControlUI* ShareSelectItem::CreateControl(LPCTSTR pstrClass)
{
    if (_tcsicmp(pstrClass, _T("ImageCanvas")) == 0)
    {
        return new CImageCanvas();
    }
    return NULL;
}