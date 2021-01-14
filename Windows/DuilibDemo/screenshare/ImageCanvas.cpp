#include "stdafx.h"
#include "ImageCanvas.h"
#include <gdiplus.h>
#include <gdiplus.h>
using namespace Gdiplus;

CImageCanvas::CImageCanvas()
{
}

CImageCanvas::~CImageCanvas()
{
}

bool CImageCanvas::DoPaint(HDC hDC, const RECT& rcPaint, CControlUI* pStopControl)
{
    if (m_data.size() == 0) return CControlUI::DoPaint(hDC, rcPaint, pStopControl);

    Gdiplus::Graphics graphics(hDC);
    Gdiplus::Bitmap* bitmap;
    bitmap = new Gdiplus::Bitmap(m_width, m_height, m_width * 4, PixelFormat32bppARGB, (BYTE*)m_data.c_str());
    Gdiplus::Image* pImage = (Gdiplus::Image*)bitmap;
    Rect rcDst{ m_rcItem.left, m_rcItem.top, m_rcItem.right - m_rcItem.left, m_rcItem.bottom - m_rcItem.top };
    graphics.SetInterpolationMode(Gdiplus::InterpolationModeHighQualityBicubic);
    graphics.DrawImage(pImage, rcDst, 0, 0, m_width, m_height, Gdiplus::UnitPixel);
    delete bitmap;

    return true;
}

void CImageCanvas::setPaintData(uint32_t width, uint32_t height, const std::string& data) {
    m_width = width;
    m_height = height;
    m_data = data;
}
