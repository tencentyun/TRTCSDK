#include "stdafx.h"
#include "UiShareSelect.h"
#include "TRTCCloudCore.h"

DUI_BEGIN_MESSAGE_MAP(UiShareSelect, WindowImplBase)
DUI_ON_CLICK_CTRNAME(_T("closebtn"), _onBtnClose)
DUI_ON_CLICK_CTRNAME(_T("btnConfirm"), _onBtnConfirm)
DUI_ON_MSGTYPE(DUI_MSGTYPE_SELECTCHANGED, _onSelChanged)
DUI_ON_MSGTYPE(DUI_MSGTYPE_TEXTCHANGED, _onTextChanged)
DUI_END_MESSAGE_MAP()

size_t UiShareSelect::ms_nLastSelectedIndex = 0;



UiShareSelect::UiShareSelect()
{
}

UiShareSelect::~UiShareSelect()
{
    _cleanShareSelectItems();
}

void UiShareSelect::setBoardWnd(HWND hBoardWnd)
{
    m_hBoardWnd = hBoardWnd;
}

void UiShareSelect::centerToDesktop()
{
    RECT rc;
    ::GetWindowRect(m_hWnd, &rc);

    int width = rc.right - rc.left;
    int height = rc.bottom - rc.top;
    int x = (::GetSystemMetrics(SM_CXSCREEN) - width) / 2;
    int y = (::GetSystemMetrics(SM_CYSCREEN) - height) / 2;
    
    ::MoveWindow(m_hWnd, x, y, width, height, FALSE);
}

TRTCScreenCaptureSourceInfo UiShareSelect::getSelectWnd() const
{
    return m_vecShareSelectItem[ms_nLastSelectedIndex]->getWndInfo();
}

RECT UiShareSelect::getRect() const 
{
    return m_rect;
}

TRTCScreenCaptureProperty UiShareSelect::getProperty() const
{
    return m_screen_property;
}

CDuiString UiShareSelect::GetSkinFile()
{
    return _T("ShareSelect.xml");
}

LPCTSTR UiShareSelect::GetWindowClassName(void) const
{
    return _T("UiShareSelect");
}

void UiShareSelect::InitWindow()
{
    CTileLayoutUI* pLayout = static_cast<CTileLayoutUI*>(m_pm.FindControl(_T("layoutBody")));
    if (!pLayout) return;

    pLayout->RemoveAll();
    _cleanShareSelectItems();

    COptionUI* check_cap_mouse = static_cast<COptionUI*>(m_pm.FindControl(_T("check_cap_mouse")));
    COptionUI* check_cap_highlight = static_cast<COptionUI*>(m_pm.FindControl(_T("check_cap_highlight")));
    COptionUI* check_high_performance = static_cast<COptionUI*>(m_pm.FindControl(_T("check_high_performance")));
    COptionUI* check_cap_child_wnd = static_cast<COptionUI*>(m_pm.FindControl(_T("check_cap_child_wnd")));
    if (check_cap_mouse && check_cap_highlight && check_high_performance) {
        check_cap_mouse->Selected(true);
        check_cap_highlight->Selected(true);
        check_high_performance->Selected(true);
        check_cap_child_wnd->Selected(false);
    }

    ITRTCScreenCaptureSourceList* wndInfoList = TRTCCloudCore::GetInstance()->GetWndList();
 
    ms_nLastSelectedIndex = 0;
    if (ms_nLastSelectedIndex >= wndInfoList->getCount()) ms_nLastSelectedIndex = wndInfoList->getCount() - 1;

    for (size_t i = 0; i < wndInfoList->getCount(); ++i)
    {
        if (!CDataCenter::GetInstance()->need_minimize_windows_ && wndInfoList->getSourceInfo(i).isMinimizeWindow) {
            continue;
        }
        ShareSelectItem* pItem = new ShareSelectItem();
        CVerticalLayoutUI* pUI = pItem->CreateControl(&m_pm);
        pUI->SetFixedWidth(150);
        pUI->SetFixedHeight(100);
        pItem->setWndInfo(wndInfoList->getSourceInfo(i));
        if (i == ms_nLastSelectedIndex) pItem->select(true);
        pLayout->Add(pUI);
        m_vecShareSelectItem.push_back(pItem);
    }
    wndInfoList->release();

}

void UiShareSelect::_onBtnClose(TNotifyUI& msg)
{
    Close(IDCANCEL);
}

void UiShareSelect::_onBtnConfirm(TNotifyUI& msg)
{
    Close(IDOK);
}

void UiShareSelect::_onSelChanged(TNotifyUI& msg)
{
    COptionUI* pOpenSender = static_cast<COptionUI*>(msg.pSender);
    if (msg.pSender->GetName() == _T("check_cap_mouse")) {
        m_screen_property.enableCaptureMouse = pOpenSender->IsSelected();
    }
    else if (msg.pSender->GetName() == _T("check_cap_highlight")) {
        m_screen_property.enableHighLight = pOpenSender->IsSelected();
    }
    else if (msg.pSender->GetName() == _T("check_high_performance")) {
        m_screen_property.enableHighPerformance = pOpenSender->IsSelected();
    }
    else if (msg.pSender->GetName() == _T("check_cap_child_wnd")) {
        m_screen_property.enableCaptureChildWindow = pOpenSender->IsSelected();
    }
    for (size_t i = 0; i < m_vecShareSelectItem.size(); ++i)
    {
        if (m_vecShareSelectItem[i]->checkSelect(msg.pSender))
        {
            m_vecShareSelectItem[i]->select(true);
            m_hSelectWnd = m_vecShareSelectItem[i]->getHwnd();
            ms_nLastSelectedIndex = i;
        }
        else
        {
            m_vecShareSelectItem[i]->select(false);
        }
    }
}

void UiShareSelect::_onTextChanged(TNotifyUI & msg)
{
    CEditUI* edit_rect_left = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_rect_left__wnd")));
    CEditUI* edit_rect_right = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_rect_right__wnd")));
    CEditUI* edit_rect_top = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_rect_top__wnd")));
    CEditUI* edit_rect_bottom = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_rect_bottom__wnd")));
    if (edit_rect_left && edit_rect_right && edit_rect_top && edit_rect_bottom) {
        m_rect.left = _wtoi(edit_rect_left->GetText());
        m_rect.right = _wtoi(edit_rect_right->GetText());
        m_rect.top = _wtoi(edit_rect_top->GetText());
        m_rect.bottom = _wtoi(edit_rect_bottom->GetText());
    }

    CEditUI* edit_highlight_color = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_highlight_color")));
    CEditUI* edit_highlight_width = static_cast<CEditUI*>(m_pm.FindControl(_T("edit_highlight_width")));
    if (edit_highlight_color) {
        m_screen_property.highLightColor = _wtoi(edit_highlight_color->GetText());
    }
    if (edit_highlight_width) {
        m_screen_property.highLightWidth = _wtoi(edit_highlight_width->GetText());
    }
}

void UiShareSelect::_cleanShareSelectItems()
{
    for (auto& var : m_vecShareSelectItem)
    {
        delete var;
    }
    m_vecShareSelectItem.clear();
}
