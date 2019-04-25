#include "stdafx.h"
#include "UiShareSelect.h"
#include "TRTCCloudCore.h"

DUI_BEGIN_MESSAGE_MAP(UiShareSelect, WindowImplBase)
DUI_ON_CLICK_CTRNAME(_T("closebtn"), _onBtnClose)
DUI_ON_CLICK_CTRNAME(_T("btnConfirm"), _onBtnConfirm)
DUI_ON_MSGTYPE(DUI_MSGTYPE_SELECTCHANGED, _onSelChanged)
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

    ITRTCScreenCaptureSourceList* wndInfoList = TRTCCloudCore::GetInstance()->GetWndList();

	ms_nLastSelectedIndex = 0;
	if (ms_nLastSelectedIndex >= wndInfoList->getCount()) ms_nLastSelectedIndex = wndInfoList->getCount() - 1;

	for (size_t i = 0; i < wndInfoList->getCount(); ++i)
	{
		ShareSelectItem* pItem = new ShareSelectItem();
		CVerticalLayoutUI* pUI = pItem->CreateControl(&m_pm);
		pUI->SetFixedWidth(150);
		pUI->SetFixedHeight(100);
		pItem->setWndInfo(wndInfoList->getSourceInfo(i));
		pLayout->Add(pUI);
		if (i == ms_nLastSelectedIndex) pItem->select(true);
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

void UiShareSelect::_cleanShareSelectItems()
{
	for (auto& var : m_vecShareSelectItem)
	{
		delete var;
	}
	m_vecShareSelectItem.clear();
}
