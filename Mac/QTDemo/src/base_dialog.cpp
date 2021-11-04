#include "base_dialog.h"

#include <QEvent>
#include <QDebug>

#ifdef _WIN32
namespace {
WNDPROC old_wndproc;
WNDPROC new_wndproc;

LRESULT wndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    if (msg == WM_NCLBUTTONDOWN) {
        bool isDragFullWindow;
        SystemParametersInfo(SPI_GETDRAGFULLWINDOWS, 0, &isDragFullWindow, 0);
        if (isDragFullWindow) {
            SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, false, NULL, 0);
            CallWindowProc(old_wndproc, hwnd, msg, wparam, lparam);
            SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, true, NULL, 0);
            return 0;
        }
    }
    return CallWindowProc(old_wndproc, hwnd, msg, wparam, lparam);
}
} // namespace

namespace wndproc_setting {
void initAndSetWndProc(HWND hwnd) {
    new_wndproc = reinterpret_cast<WNDPROC>(wndProc);
    old_wndproc = reinterpret_cast<WNDPROC>(SetWindowLong(hwnd, GWLP_WNDPROC, reinterpret_cast<LONG>(new_wndproc)));
}
} // namespace wndproc_setting
#endif //_WIN32

BaseDialog::BaseDialog(QWidget* parent)
    : QDialog(parent)
{
}

BaseDialog::~BaseDialog()
{
}

void BaseDialog::showEvent(QShowEvent* event) {
#ifdef _WIN32
    registerWndProc(reinterpret_cast<HWND>(this->winId()));
#endif // _WIN32
}

void BaseDialog::closeEvent(QCloseEvent* event) {
#ifdef _WIN32
    recoverWndProc(reinterpret_cast<HWND>(this->winId()));
#endif // _WIN32
}

void BaseDialog::changeEvent(QEvent* event) {
    if (QEvent::LanguageChange == event->type()) {
        this->retranslateUi();
        this->updateDynamicTextUI();
    }
    QWidget::changeEvent(event);
}

void BaseDialog::updateDynamicTextUI() {}

void BaseDialog::resetUI() {}

#ifdef _WIN32
void BaseDialog::registerWndProc(HWND hwnd) {
    SetWindowLong(hwnd, GWLP_WNDPROC, reinterpret_cast<LONG>(new_wndproc));
}

void BaseDialog::recoverWndProc(HWND hwnd) {
    SetWindowLong(hwnd, GWLP_WNDPROC, reinterpret_cast<LONG>(old_wndproc));
}

#endif // _WIN32
