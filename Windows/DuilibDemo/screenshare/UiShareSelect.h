#pragma once

#include "ShareSelectItem.h"

class UiShareSelect : public WindowImplBase
{
	DUI_DECLARE_MESSAGE_MAP()
public:
	UiShareSelect();
	~UiShareSelect();

	void setBoardWnd(HWND hBoardWnd);

	void centerToDesktop();

	TRTCScreenCaptureSourceInfo getSelectWnd() const;

protected:
	virtual CDuiString GetSkinFile() override;
	virtual LPCTSTR GetWindowClassName(void) const override;

	virtual void InitWindow() override;

	void _onBtnClose(TNotifyUI& msg);
	void _onBtnConfirm(TNotifyUI& msg);

	void _onSelChanged(TNotifyUI& msg);

	void _cleanShareSelectItems();

private:
	HWND m_hBoardWnd = NULL;

	HWND m_hSelectWnd = NULL;
	std::vector<ShareSelectItem*>	m_vecShareSelectItem;

	static size_t ms_nLastSelectedIndex;
};

