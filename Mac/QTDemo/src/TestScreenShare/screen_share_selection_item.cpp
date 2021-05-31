#include "screen_share_selection_item.h"

ScreenShareSelectionItem::ScreenShareSelectionItem(trtc::TRTCScreenCaptureSourceInfo& screenCaptureSourceInfo
    ,QWidget * parent)
    :QWidget(parent)
    ,ui_screen_share_selection_item_(new Ui::ScreenShareSelectionItem)
    ,screen_capture_sourceinfo_(screenCaptureSourceInfo){
    ui_screen_share_selection_item_->setupUi(this);
    initView();
}

ScreenShareSelectionItem::~ScreenShareSelectionItem(){

}

void ScreenShareSelectionItem::initView()
{
    QImage image(reinterpret_cast<const uchar*>(screen_capture_sourceinfo_.thumbBGRA.buffer),
                 screen_capture_sourceinfo_.thumbBGRA.width,
                screen_capture_sourceinfo_.thumbBGRA.height,
                 QImage::Format_ARGB32);
    QPixmap pixmap = QPixmap::fromImage(image);
    pixmap = pixmap.scaled(ui_screen_share_selection_item_->windowItem->size());

    ui_screen_share_selection_item_->windowItem->setAutoFillBackground(true);
    ui_screen_share_selection_item_->windowItem->setPixmap(pixmap);
    ui_screen_share_selection_item_->labelWindowsName->setText(screen_capture_sourceinfo_.sourceName);
}

bool ScreenShareSelectionItem::isSelected() const{
    return ui_screen_share_selection_item_->radioButtonSelected->isChecked();
}

void ScreenShareSelectionItem::setSelected(bool selected){
    ui_screen_share_selection_item_->radioButtonSelected->setChecked(selected);
}

void ScreenShareSelectionItem::mouseReleaseEvent(QMouseEvent *ev){
    bool is_selected  = ui_screen_share_selection_item_->radioButtonSelected->isChecked();
    if(is_selected){
        return;
    }
    emit onCheckStatusChanged(this,!is_selected);
    ui_screen_share_selection_item_->radioButtonSelected->setChecked(!is_selected);
}

trtc::TRTCScreenCaptureSourceInfo ScreenShareSelectionItem::getScreenCaptureSourceinfo() const
{
    return static_cast<trtc::TRTCScreenCaptureSourceInfo>(screen_capture_sourceinfo_);
}

void ScreenShareSelectionItem::on_radioButtonSelected_clicked(bool checked){
    emit onCheckStatusChanged(this,checked);
}
