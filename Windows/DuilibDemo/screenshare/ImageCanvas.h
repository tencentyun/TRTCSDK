#pragma once
#include "UIlib.h"
using namespace DuiLib;

class CImageCanvas : public CControlUI
{
public:
    CImageCanvas();
    ~CImageCanvas();

    virtual bool DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl) override;

    void setPaintData(uint32_t width, uint32_t height, const std::string& data);

private:
    uint32_t    m_width = 0;
    uint32_t    m_height = 0;
    std::string m_data;
};

