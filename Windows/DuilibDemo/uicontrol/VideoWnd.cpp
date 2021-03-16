#include "VideoWnd.h"
namespace DuiLib {

VideoWnd::VideoWnd(void) {
}
VideoWnd::~VideoWnd(void) {
}
void VideoWnd::MoveWindow(int x, int y, int nWidth, int nHeight) {
    ::MoveWindow(GetHWND(), x, y, nWidth, nHeight, FALSE);
}
CDuiString VideoWnd::GetSkinFolder() {
    return CPaintManagerUI::GetResourcePath();
}
CDuiString VideoWnd::GetSkinFile() {
    return _T("VideoWnd.xml");
}
LPCTSTR VideoWnd::GetWindowClassName(void) const {
    return _T("VideoWnd");
}

LRESULT VideoWnd::HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_SYSCOMMAND:
            if ((SC_MAXIMIZE & wParam) == SC_MAXIMIZE) return 0;
            break;
    }
    return WindowImplBase::HandleMessage(uMsg, wParam, lParam);
}
LRESULT VideoWnd::OnClose(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled) {
    return WindowImplBase::OnClose(uMsg, wParam, lParam, bHandled);
}
void VideoWnd::Notify(TNotifyUI& msg) {
    CDuiString strName = msg.pSender->GetName();
    WindowImplBase::Notify(msg);
}
LRESULT VideoWnd::ResponseDefaultKeyEvent(WPARAM wParam) {
    if (wParam == VK_RETURN) {
        return FALSE;
    } else if (wParam == VK_ESCAPE) {
        return FALSE;
    }

    return FALSE;
}
void VideoWnd::OnClick(TNotifyUI& msg) {
    CDuiString strName = msg.pSender->GetName();
    WindowImplBase::OnClick(msg);
}
void VideoWnd::InitWindow() {
    WindowImplBase::InitWindow();
}

}  // namespace DuiLib
