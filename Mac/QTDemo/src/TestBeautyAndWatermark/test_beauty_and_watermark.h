/**
 * TRTC 美颜和水印功能
 *
 * - 美颜:参考updateBeautyStyle:
 * - 设置美颜、美白、红润效果级别
 * - SDK 内部集成了两套风格不同的磨皮算法，一套我们取名叫“光滑”，适用于美女秀场，效果比较明显。 另一套我们取名“自然”，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
 * -
 * - 水印：参考setWatermark()/unsetWatermark()
 * - 设置水印后，远端用户看到你的画面上会叠加水印浮层，注意水印只支持主路视频流
 */

/**
 * Beauty filters and watermarks
 *
 * - For beauty filters, please refer to:updateBeautyStyle:
 * - Set the strength of beauty, skin brightening, and rosy skin effects.
 * - The SDK has two built-in skin smoothing algorithms. One is "smooth", which features more obvious smoothing effect and is designed for showrooms.  The other is "natural", which retains more facial details and is more natural.
 * -
 * - For watermarks, please refer to:  setWatermark()/unsetWatermark()
 * - After you set a watermark, a watermark image will be overlaid on the video seen by remote users. Note that you can add watermarks only to primary-stream videos.
 */

#ifndef TESTBEAUTYANDWATERMARK_H
#define TESTBEAUTYANDWATERMARK_H

#include<QTemporaryDir>
#include<QPixmap>

#include "ITRTCCloud.h"
#include "ui_TestBeautyAndWaterMarkDialog.h"
#include "base_dialog.h"

class TestBeautyAndWaterMark:
        public BaseDialog
{
    Q_OBJECT
public:
    explicit TestBeautyAndWaterMark(QWidget *parent = nullptr);
    ~TestBeautyAndWaterMark();

private:
    void setWatermark();
    void unsetWatermark();
    void updateBeautyStyle();

private slots:
    void on_comboBoxBeautyStyle_currentIndexChanged(int index);

    void on_horizontalSliderBeautyLevel_valueChanged(int value);

    void on_horizontalSliderWhitenessLevel_valueChanged(int value);

    void on_horizontalSliderruddinessLevel_valueChanged(int value);

    void on_checkBoxWaterMark_stateChanged(int check_state);

public:
    void showEvent(QShowEvent *event) override;

private:
    void retranslateUi() override;

private:
    std::unique_ptr<Ui::TestBeautyAndWaterMarkDialog> ui_beauty_and_watermark_;
    trtc::ITRTCCloud *trtccloud;

    QTemporaryDir qtemp_dir_;
    trtc::TRTCBeautyStyle current_beauty_style_ = trtc::TRTCBeautyStyle::TRTCBeautyStyleSmooth;
    uint32_t current_beauty_level_ = 5;
    uint32_t current_whiteness_level_ = 5;
    uint32_t current_ruddiness_level_ = 5;

};

#endif // TESTBEAUTYANDWATERMARK_H
