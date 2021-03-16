#pragma once
#include "UIlib.h"
namespace DuiLib {

class VideoWnd : public WindowImplBase {
   public:
    VideoWnd(void);
    ~VideoWnd(void);

   public:
    void MoveWindow(int x, int y, int nWidth, int nHeight);
   protected:
    virtual CDuiString GetSkinFolder();
    virtual CDuiString GetSkinFile();
    virtual LPCTSTR GetWindowClassName(void) const;

    virtual LRESULT HandleMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    virtual LRESULT OnClose(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled);
    virtual void Notify(TNotifyUI& msg);
    virtual LRESULT ResponseDefaultKeyEvent(WPARAM wParam);
    virtual void OnClick(TNotifyUI& msg);
    virtual void InitWindow();

};

}  // namespace DuiLib