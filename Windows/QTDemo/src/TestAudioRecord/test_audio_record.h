/**
 * TRTC 音频录制
 *
 * - 使用音频录制功能，SDK 会将通话过程中的所有音频(包括本地音频，远端音频，BGM等)录制到一个文件里。 无论是否进房，调用该接口都生效。 如果调用 exitRoom 时还在录音，录音会自动停止。
 * -
 * - 使用方式参考：
 * - startAudioRecording();
 * - stopAudioRecording();
 * - handleWithRecordingResult(int result);
 */

/**
 * Audio recording
 *
 * - The audio recording feature records all audio during a call, including local audio, remote audio, and background music, into a file.  This API works regardless of whether you have entered the room.  When exitRoom is called, audio recording will stop automatically.
 * -
 * - For the specific method, please refer to:
 * - startAudioRecording()
 * - stopAudioRecording()
 * - handleWithRecordingResult(int result)
 */

#ifndef TESTAUDIORECORD_H
#define TESTAUDIORECORD_H

#include <QDir>
#include <QString>
#include <QFileDialog>
#include <QFileInfo>
#include <QDateTime>
#include <QMessageBox>
#include <QTimer>
#include <QDesktopServices>
#include <QProcess>

#include "ITRTCCloud.h"
#include "ui_TestAudioRecordDialog.h"
#include "trtc_cloud_callback_default_impl.h"
#include "base_dialog.h"

class TestAudioRecord:
        public BaseDialog,
        public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestAudioRecord(QWidget *parent = nullptr);
    ~TestAudioRecord();

    void startAudioRecording();
    void stopAudioRecording();
    void handleWithRecordingResult(int result);

private slots:

    void on_pushButtonStartStopRecord_clicked();

    void onRecordingTimeUpdate();

    void on_pushButtonRecordPathChoose_clicked();

    void on_pushButtonOpenPath_clicked();

public:
    //UI-related
    void closeEvent(QCloseEvent *event) override;

private:
    //UI-related
    QString formatTimeString(qint64 timeSeconds);
    void showPathInGraphicalShell(QWidget *parent, const QString &path);
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private:
    bool is_recording_ = false;
    uint64_t current_recording_time_seconds_ = 0;
    uint64_t current_playback_position_seconds_ = 0;
    uint64_t current_playback_duration_seconds_ = 0;
    QString last_record_file_path;

    std::unique_ptr<Ui::TestAudioRecordDialog> ui_audio_record_;
    trtc::ITRTCCloud *trtccloud_;
    QTimer *qtimer_ = new QTimer();

};

#endif // TESTAUDIORECORD_H
