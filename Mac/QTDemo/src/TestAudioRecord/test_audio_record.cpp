#include "test_audio_record.h"

TestAudioRecord::TestAudioRecord(QWidget *parent):
    BaseDialog(parent),
    ui_audio_record_(new Ui::TestAudioRecordDialog)
{
    ui_audio_record_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    trtccloud_ = getTRTCShareInstance();
    trtccloud_->addCallback(this);
    qtimer_->setInterval(1000);
    connect(qtimer_, SIGNAL(timeout()), this, SLOT(onRecordingTimeUpdate()));
}

TestAudioRecord::~TestAudioRecord()
{
    if(trtccloud_ != nullptr) {
        stopAudioRecording();
        trtccloud_->removeCallback(this);
        trtccloud_ = nullptr;
    }

    if(qtimer_ != nullptr) {
        qtimer_->stop();
        delete qtimer_;
    }
}

void TestAudioRecord::startAudioRecording()
{
    QString file_path = ui_audio_record_->lineEditRecordFilePath->text();
    if(file_path.length() == 0) {
        QMessageBox::warning(NULL, "Failed to start recording", "Enter a valid path.");
        return;
    }
    trtc::TRTCAudioRecordingParams params;
    QFileInfo fileInfo(file_path);
    std::string temp = fileInfo.absoluteFilePath().toStdString();
    last_record_file_path = QString(temp.c_str());
    params.filePath = temp.c_str();
    int result = trtccloud_->startAudioRecording(params);
    handleWithRecordingResult(result);
}

void TestAudioRecord::stopAudioRecording()
{
    trtccloud_->stopAudioRecording();
    qtimer_->stop();
    current_recording_time_seconds_ = 0;
    is_recording_ = false;
    ui_audio_record_->lineEditRecordFilePath->setText("");
    ui_audio_record_->labelRecordingDuration->setText("00:00");
    updateDynamicTextUI();
}

void TestAudioRecord::handleWithRecordingResult(int result)
{
    switch (result) {
    case 0: {
        is_recording_ = true;
        updateDynamicTextUI();
        qtimer_->start();
        break;
    }
    case -1: {
        QMessageBox::warning(NULL, "Failed to start recording", "Recording has started.");
        break;
    }
    case -2: {
        QMessageBox::warning(NULL, "Failed to start recording", "Failed to create file or directory.");
        break;
    }
    case -3: {
        QMessageBox::warning(NULL, "Failed to start recording", "Unsupported audio format.");
        break;
    }
    default: {
        break;
    }
    }
}

void TestAudioRecord::onRecordingTimeUpdate()
{
    current_recording_time_seconds_++;
    QString recording_time = formatTimeString(current_recording_time_seconds_);
    ui_audio_record_->labelRecordingDuration->setText(recording_time);
}

void TestAudioRecord::on_pushButtonStartStopRecord_clicked()
{
    if(is_recording_) {
        stopAudioRecording();
    } else {
        startAudioRecording();
    }
}

void TestAudioRecord::on_pushButtonRecordPathChoose_clicked()
{
    QString file_path = QFileDialog::getExistingDirectory(this, tr("Choose Path"),"./", QFileDialog::DontResolveSymlinks);
    if(file_path.length() != 0) {
        QFileInfo fileInfo(QDir::toNativeSeparators(file_path));
        if(fileInfo.isDir()){
            QDateTime current_date_time = QDateTime::currentDateTime();
            QString file_name = current_date_time.toString("yyyy_MM_dd_hh_mm_ss");
            file_path = file_path + "/" + file_name + ".aac";
        }
        ui_audio_record_->lineEditRecordFilePath->setText(QDir::toNativeSeparators(file_path));
    }
}

void TestAudioRecord::on_pushButtonOpenPath_clicked()
{
    QString file_path = last_record_file_path;
    if(!QFileInfo::exists(file_path)) {
        QMessageBox::warning(NULL, "Failed to view last recording", "Cannot find the file.");
        return;
    }
    showPathInGraphicalShell(this, file_path);
}

void TestAudioRecord::closeEvent(QCloseEvent *event)
{
    if(is_recording_) {
        stopAudioRecording();
    }
    BaseDialog::closeEvent(event);
}

QString TestAudioRecord::formatTimeString(qint64 timeSeconds)
{
    uint32_t seconds = timeSeconds % 60;
    uint32_t minutes = timeSeconds / 60;
    QString formatted_time = QString("%1:%2").arg(minutes, 2, 10, QLatin1Char('0')).arg(seconds, 2, 10, QLatin1Char('0'));
    return formatted_time;
}

void TestAudioRecord::showPathInGraphicalShell(QWidget *parent, const QString &path)
{
    const QFileInfo fileInfo(path);
    // Mac, Windows support folder or file.
#ifndef _WIN32
    QStringList scriptArgs;
    scriptArgs << QLatin1String("-e")
               << QString::fromLatin1("tell application \"Finder\" to reveal POSIX file \"%1\"")
                                     .arg(fileInfo.canonicalFilePath());
    QProcess::execute(QLatin1String("/usr/bin/osascript"), scriptArgs);
    scriptArgs.clear();
    scriptArgs << QLatin1String("-e")
               << QLatin1String("tell application \"Finder\" to activate");
    QProcess::execute(QLatin1String("/usr/bin/osascript"), scriptArgs);
#else
    QStringList args;
    args << "/select," << QDir::toNativeSeparators(path);
    QProcess *process = new QProcess(this);
    process->start("explorer.exe", args);
#endif
}

void TestAudioRecord::updateDynamicTextUI() {
    if (is_recording_) {
        ui_audio_record_->pushButtonStartStopRecord->setText(tr("停止录制"));
    } else {
        ui_audio_record_->pushButtonStartStopRecord->setText(tr("开始录制"));
    }
}

void TestAudioRecord::retranslateUi() {
    ui_audio_record_->retranslateUi(this);
}
