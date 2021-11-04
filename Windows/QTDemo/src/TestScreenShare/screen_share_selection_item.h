/**
 * TRTC 屏幕分享备选框显示组件
 *
 * - 负责TRTCScreenCaptureSourceInfo的UI预览，具体参考：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCTypeDef__cplusplus.html#structtrtc_1_1TRTCScreenCaptureSourceInfo
 */

/**
 * Screen sharing selection
 *
 * - Responsible for preview of ScreenCaptureSourceInfo. For details, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCTypeDef__cplusplus.html#structtrtc_1_1TRTCScreenCaptureSourceInfo
 */

#ifndef SCREENSHARESELECTIONITEM_H
#define SCREENSHARESELECTIONITEM_H

#include <QWidget>
#include "ITRTCCloud.h"
#include "ui_ScreenShareSelectionItem.h"
class ScreenShareSelectionItem:public QWidget
{
    Q_OBJECT
public:
    explicit ScreenShareSelectionItem(trtc::TRTCScreenCaptureSourceInfo& screenCaptureSourceInfo, QWidget* parent = nullptr);
    ~ScreenShareSelectionItem();
    trtc::TRTCScreenCaptureSourceInfo getScreenCaptureSourceinfo() const;
    bool isSelected() const;
    void setSelected(bool selected);

protected:
    virtual void mouseReleaseEvent(QMouseEvent * ev);

signals:
    void onCheckStatusChanged(ScreenShareSelectionItem* item,bool status);

private slots:
    void on_radioButtonSelected_clicked(bool checked);

private:
    void initView();

private:
    std::unique_ptr<Ui::ScreenShareSelectionItem> ui_screen_share_selection_item_;
    trtc::TRTCScreenCaptureSourceInfo screen_capture_sourceinfo_;
};

#endif // SCREENSHARESELECTIONITEM_H
