#include "test_beauty_and_watermark.h"

TestBeautyAndWaterMark::TestBeautyAndWaterMark(QWidget *parent):
    BaseDialog(parent),
    ui_beauty_and_watermark_(new Ui::TestBeautyAndWaterMarkDialog)
{
    ui_beauty_and_watermark_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    trtccloud = getTRTCShareInstance();
}

TestBeautyAndWaterMark::~TestBeautyAndWaterMark() {

    if(trtccloud != nullptr) {
        trtccloud = nullptr;
    }
}

void TestBeautyAndWaterMark::setWatermark()
{
    const QString qtmp_file = qtemp_dir_.path() + "/watermark.png";
    QByteArray qtmp_file_bytearray = qtmp_file.toLatin1();
    QFile::copy(":watermark/image/watermark/watermark.png", qtmp_file);
    const char *file_path = qtmp_file_bytearray.data();
    trtccloud->setWaterMark(trtc::TRTCVideoStreamType::TRTCVideoStreamTypeBig,
                            file_path,
                            trtc::TRTCWaterMarkSrcType::TRTCWaterMarkSrcTypeFile,
                            0,
                            0,
                            0.3,
                            0.2,
                            0.5);
}

void TestBeautyAndWaterMark::unsetWatermark()
{
    trtccloud->setWaterMark(trtc::TRTCVideoStreamType::TRTCVideoStreamTypeBig,
                            nullptr,
                            trtc::TRTCWaterMarkSrcType::TRTCWaterMarkSrcTypeFile,
                            0,
                            0,
                            0.1,
                            0.1,
                            0.9);
}

void TestBeautyAndWaterMark::showEvent(QShowEvent *event)
{
    ui_beauty_and_watermark_->horizontalSliderBeautyLevel->setValue(current_beauty_level_);
    ui_beauty_and_watermark_->horizontalSliderruddinessLevel->setValue(current_ruddiness_level_);
    ui_beauty_and_watermark_->horizontalSliderWhitenessLevel->setValue(current_whiteness_level_);
    updateBeautyStyle();
    BaseDialog::showEvent(event);
}

void TestBeautyAndWaterMark::updateBeautyStyle()
{
    if(trtccloud != nullptr) {
        trtccloud->setBeautyStyle(current_beauty_style_,
                                  current_beauty_level_,
                                  current_whiteness_level_,
                                  current_ruddiness_level_);
    }
}

void TestBeautyAndWaterMark::on_comboBoxBeautyStyle_currentIndexChanged(int index)
{
    if(index == 0) {
        current_beauty_style_ = trtc::TRTCBeautyStyle::TRTCBeautyStyleSmooth;
    } else if (index == 1) {
        current_beauty_style_ = trtc::TRTCBeautyStyle::TRTCBeautyStyleNature;
    }
    updateBeautyStyle();
}



void TestBeautyAndWaterMark::on_horizontalSliderBeautyLevel_valueChanged(int value)
{
    current_beauty_level_ = (uint32_t)(value);
    updateBeautyStyle();
}

void TestBeautyAndWaterMark::on_horizontalSliderWhitenessLevel_valueChanged(int value)
{
    current_whiteness_level_ = (uint32_t)(value);
    updateBeautyStyle();
}

void TestBeautyAndWaterMark::on_horizontalSliderruddinessLevel_valueChanged(int value)
{
    current_ruddiness_level_ = (uint32_t)(value);
    updateBeautyStyle();
}

void TestBeautyAndWaterMark::on_checkBoxWaterMark_stateChanged(int check_state)
{
    if(check_state == Qt::CheckState::Unchecked) {
        unsetWatermark();
    } else if (check_state == Qt::CheckState::Checked) {
        setWatermark();
    }
}

void TestBeautyAndWaterMark::retranslateUi() {
    ui_beauty_and_watermark_->retranslateUi(this);
}