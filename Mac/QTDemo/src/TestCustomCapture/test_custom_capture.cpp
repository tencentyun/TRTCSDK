#include "test_custom_capture.h"

#include <QFile>
#include <QFileInfo>
#include <QMessageBox>
#include <QThread>
#include <QtDebug>
#include "ITRTCCloud.h"

TestCustomCapture::TestCustomCapture(std::shared_ptr<TestUserVideoGroup> testUserVideoGroup, QWidget * parent):
    test_user_video_group_(testUserVideoGroup),
    QDialog(parent),
    ui_test_custom_capture_(new Ui::TestCustomCaptureDialog){
    ui_test_custom_capture_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
}
TestCustomCapture::~TestCustomCapture() {
    destroyCustomCapture();
}

void TestCustomCapture::startCustomAudioData(QString path) {
    std::function<void()> func = [this,path]() {
        QFile file(path);
        if (!file.open(QFile::ReadOnly)) {
            return;
        }
        getTRTCShareInstance()->stopLocalAudio();
        getTRTCShareInstance()->enableCustomAudioCapture(true);
        uint32_t buffer_size = (960 * 44100 / 48000) * (2 * 16 / 8);
        while (!this->stop_custom_audio_sender) {
            if(file.atEnd()){
                file.seek(0);
            }
            QByteArray array;
            array = file.read(buffer_size);
            trtc::TRTCAudioFrame frame;
            frame.audioFormat = trtc::TRTCAudioFrameFormatPCM;
            frame.length = buffer_size;
            frame.data = array.data();
            frame.sampleRate = 44100;
            frame.channel = 2;
            getTRTCShareInstance()->sendCustomAudioData(&frame);
            QThread::msleep((ulong)20);
        }
    };
    custom_audio_thread_ = new std::thread(func);
}
void TestCustomCapture::startCustomVideoData(QString path) {
    std::function<void()> func = [this,path]() {
        QFile file(path);
        if (!file.open(QFile::ReadOnly)) {
            return;
        }

        getTRTCShareInstance()->stopLocalPreview();
        getTRTCShareInstance()->enableCustomVideoCapture(true);

        uint32_t buffer_size = 320 * 240 * 3 / 2;
        while (!this->stop_custom_video_sender) {

            if(file.atEnd()){
                file.seek(0);
            }

            QByteArray array;
            array = file.read(buffer_size);
            trtc::TRTCVideoFrame frame;

            if (ui_test_custom_capture_->cbEnableCustomTimeCapture) {
                frame.timestamp = getTRTCShareInstance()->generateCustomPTS();
            }

            frame.videoFormat = trtc::TRTCVideoPixelFormat_I420;
            frame.bufferType = trtc::TRTCVideoBufferType_Buffer;
            frame.length = buffer_size;
            frame.data = array.data();
            frame.width = 320;
            frame.height = 240;
            getTRTCShareInstance()->sendCustomVideoData(&frame);
            gl_yuv_widget_->slotShowYuv(reinterpret_cast<uchar*>(array.data()),320,240);
            QThread::msleep((ulong)66);
        }
    };
    gl_yuv_widget_  = new GLYuvWidget(ui_test_custom_capture_->videoPlaceHolder);
    gl_yuv_widget_->resize(320,240);
    gl_yuv_widget_->show();
    custom_video_thread_ = new std::thread(func);
}

void TestCustomCapture::stopCustomAudioData() {
    getTRTCShareInstance()->enableCustomAudioCapture(false);
    getTRTCShareInstance()->startLocalAudio(trtc::TRTCAudioQualityDefault);
}
void TestCustomCapture::stopCustomVideoData() {
    getTRTCShareInstance()->enableCustomVideoCapture(false);
    getTRTCShareInstance()->startLocalPreview(test_user_video_group_->getLocalVideoTxView());
}

void TestCustomCapture::closeEvent(QCloseEvent* event){
    destroyCustomCapture();
}

void TestCustomCapture::on_btnAudioCustomCapture_clicked(){
    if(!custom_audiocapture_started){
        QString runPath = QCoreApplication::applicationDirPath();
        QString finalPath = runPath.append("/assets/audio/custom_audio.pcm");
        QFileInfo file_Info(QDir::toNativeSeparators(finalPath));
        if (!file_Info.exists()) {
            QMessageBox::warning(this, "Start Audio CustomCapture Failed", "File Not Exists", QMessageBox::Ok);
            return;
        }

        stop_custom_audio_sender = false;

        startCustomAudioData(file_Info.absoluteFilePath());
        ui_test_custom_capture_->btnAudioCustomCapture->setText(QString::fromLocal8Bit("结束音频自定义采集"));
    }else{
        stop_custom_audio_sender = true;
        if(custom_audio_thread_ != nullptr){
            custom_audio_thread_->join();
            delete custom_audio_thread_;
            custom_audio_thread_ = nullptr;
        }

        stopCustomAudioData();
        ui_test_custom_capture_->btnAudioCustomCapture->setText(QString::fromLocal8Bit("开始音频自定义采集"));
    }
    custom_audiocapture_started = !custom_audiocapture_started;
}

void TestCustomCapture::on_btnVideoCustomCapture_clicked(){
    if(!custom_videocapture_started){
        QString runPath = QCoreApplication::applicationDirPath();
        QString finalPath = runPath.append("/assets/video/320x240_video.yuv");
        QFileInfo file_Info(QDir::toNativeSeparators(finalPath));
        if (!file_Info.exists()) {
            QMessageBox::warning(this, "Start Video CustomCapture Failed", "File Not Exists", QMessageBox::Ok);
            return;
        }
        stop_custom_video_sender = false;
        startCustomVideoData(file_Info.absoluteFilePath());
        ui_test_custom_capture_->btnVideoCustomCapture->setText(QString::fromLocal8Bit("结束视频自定义采集"));
    }else{
        stop_custom_video_sender = true;
        if(custom_video_thread_ != nullptr){
            custom_video_thread_->join();
            delete custom_video_thread_;
            custom_video_thread_ = nullptr;
        }

        if(gl_yuv_widget_ != nullptr){
            delete gl_yuv_widget_;
            gl_yuv_widget_ = nullptr;
        }
        stopCustomVideoData();
        ui_test_custom_capture_->btnVideoCustomCapture->setText(QString::fromLocal8Bit("开始视频自定义采集"));
    }

    custom_videocapture_started = !custom_videocapture_started;
}

void TestCustomCapture::destroyCustomCapture(){
    if(custom_videocapture_started){
        stopCustomAudioData();
     }

    if(custom_audiocapture_started){
        stopCustomVideoData();
    }

    stop_custom_video_sender = true;
    if (custom_video_thread_ != nullptr) {
        custom_video_thread_->join();
        delete custom_video_thread_;
        custom_video_thread_ = nullptr;
    }

    stop_custom_audio_sender = true;
    if (custom_audio_thread_ != nullptr) {
        custom_audio_thread_->join();
        delete custom_audio_thread_;
        custom_audio_thread_ = nullptr;
    }

    if(gl_yuv_widget_ != nullptr){
        delete  gl_yuv_widget_;
        gl_yuv_widget_ = nullptr;
    }

    custom_videocapture_started = false;
    custom_audiocapture_started = false;
    ui_test_custom_capture_->btnVideoCustomCapture->setText(QString::fromLocal8Bit("开始视频自定义采集"));
    ui_test_custom_capture_->btnAudioCustomCapture->setText(QString::fromLocal8Bit("开始音频自定义采集"));
}
