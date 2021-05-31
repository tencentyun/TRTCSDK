/**
 * TRTC 视频设置
 *
 * - 此模块展示了设置了如何设置本地采集到视频数据的编码方式（决定了远端用户看到的效果），以及如何设置本地采集视频数据的渲染方式（决定本地显示的效果"localpreview"）
 * - 核心接口调用：setVideoEncoderParam()，setLocalRenderParams()，具体API说明可参考https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#aa2bc2739031035b40e8f2a76184c20d9
 * -
 * - 调用方法参考：updateVideoEncoderParams() / updateLocalRenderParams()
 */

#ifndef TESTVIDEOSETTING_H
#define TESTVIDEOSETTING_H

#include <QDialog>
#include <QHash>

#include "ITRTCCloud.h"
#include "ui_TestVideoSettingDialog.h"

class TestVideoSetting:
        public QDialog
{
    Q_OBJECT
public:
    explicit TestVideoSetting(QWidget *parent = nullptr);
    ~TestVideoSetting();

private:

    void updateVideoEncoderParams();
    void updateLocalRenderParams();

private slots:
    void on_comboBoxVideoResolution_currentIndexChanged(int index);

    void on_comboBoxResolutionMode_currentIndexChanged(int index);

    void on_comboBoxVideoFps_currentIndexChanged(int index);

    void on_comboBoxVideoFillMode_currentIndexChanged(int index);

    void on_horizontalSliderVideoBitrate_valueChanged(int value);

    void on_checkBoxEnableAdjustRes_stateChanged(int state);

    void on_checkBoxEnableEncSmallVideoStream_stateChanged(int state);

private:
    //UI-related
    void setupVideoResolutionMap();

private:

    std::unique_ptr<Ui::TestVideoSettingDialog> ui_video_setting_;
    QHash<int, trtc::TRTCVideoResolution> video_resolution_hashmap_;
    trtc::ITRTCCloud *trtccloud_;

};

#endif // TESTVIDEOSETTING_H
