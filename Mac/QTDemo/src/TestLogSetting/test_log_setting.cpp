#include "test_log_setting.h"

#include <QFileDialog>
#include <QDateTime>
#include <QDebug>

#include "ITRTCCloud.h"

TestLogSetting::TestLogSetting(QWidget *parent) :
    BaseDialog(parent),
    ui_test_log_setting_(new Ui::TestLogSettingDialog)
{
    ui_test_log_setting_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    getTRTCShareInstance()->setLogCallback(this);
}

TestLogSetting::~TestLogSetting(){
    getTRTCShareInstance()->setLogCallback(nullptr);
}

void TestLogSetting::setLogLevel(){
    trtc::TRTCLogLevel log_level = static_cast<trtc::TRTCLogLevel>(ui_test_log_setting_->setLogLevelCb->currentIndex());
    getTRTCShareInstance()->setLogLevel(log_level);
}

void TestLogSetting::setConsoleEnabled(){
    getTRTCShareInstance()->setConsoleEnabled(ui_test_log_setting_->setConsoleEnabledCb->isChecked());
}

void TestLogSetting::setLogCompressEnabled(){
    getTRTCShareInstance()->setLogCompressEnabled(ui_test_log_setting_->logCompressCb->isChecked());
}

void TestLogSetting::setLogDirPath(){
    QString file_path = QFileDialog::getExistingDirectory(this, tr("Open Directory"), "./", QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);

    if(file_path.length() != 0) {
        QFileInfo fileInfo(QDir::toNativeSeparators(file_path));
        if(!fileInfo.isDir()){
            return;
        }
        std::string path_str = fileInfo.absoluteFilePath().toStdString();
        const char * log_path = path_str.c_str();
        getTRTCShareInstance()->setLogDirPath(log_path);
        ui_test_log_setting_->logDirPathLe->setText(fileInfo.absoluteFilePath());
        ui_test_log_setting_->logCompressCb->setEnabled(true);
    }
}



//============= ITRTCLogCallback start =================//
void TestLogSetting::onLog(const char *log, trtc::TRTCLogLevel level, const char *module){

    QByteArray localMsg = QString::fromUtf8(log).toLocal8Bit();
    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    fprintf(stdout, "%s %s [%s] - %s\n",  current_date_time.toLocal8Bit().constData(), "LOG_LEVEL_MSG[level]",module,localMsg.constData());
}
//============= ITRTCLogCallback end ===================//

void TestLogSetting::on_setLogLevelCb_currentIndexChanged(int index){
     setLogLevel();
}

void TestLogSetting::on_logCompressCb_clicked(bool checked){
    setLogCompressEnabled();
}
void TestLogSetting::on_selectLogOutputDirBtn_clicked(){
    setLogDirPath();
}

void TestLogSetting::on_setConsoleEnabledCb_clicked(bool checked){
    setConsoleEnabled();
}

void TestLogSetting::retranslateUi() {
    ui_test_log_setting_->retranslateUi(this);
}