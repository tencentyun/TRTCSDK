#include "test_bgm_setting.h"
#include <QMessageBox>
#include <QFile>

TestBGMSetting::TestBGMSetting(QWidget* parent):BaseDialog(parent),ui_bgm_setting_(new Ui::TestBGMSettingDialog){
    ui_bgm_setting_->setupUi(this);
    setWindowFlags(windowFlags()&~Qt::WindowContextHelpButtonHint);
    audio_effect_manager_ = getTRTCShareInstance()->getAudioEffectManager();

    connect(this, &TestBGMSetting::start, this, &TestBGMSetting::handleStart);
    connect(this, &TestBGMSetting::complete, this, &TestBGMSetting::handleComplete);
    connect(this, &TestBGMSetting::playProgress, this, &TestBGMSetting::handlePlayProgress);
}
TestBGMSetting::~TestBGMSetting(){
    if(bgm_music_id != -1){
      stopPlayBgmMusic();
    }

    resetDefaultValue();
}

void TestBGMSetting::startPlayBgmMusic(std::string& path,int loopCount,bool publish,bool isShortFile)
{
    trtc::AudioMusicParam audio_music_param(bgm_music_id,const_cast<char*>(path.c_str()));
    audio_music_param.loopCount = loopCount;
    audio_music_param.publish = publish;
    audio_music_param.isShortFile = isShortFile;

    audio_effect_manager_->setMusicObserver(bgm_music_id,this);
    audio_effect_manager_->startPlayMusic(audio_music_param);
}

void TestBGMSetting::stopPlayBgmMusic(){
    audio_effect_manager_->stopPlayMusic(bgm_music_id);
}

void TestBGMSetting::pausePlayBgmMusic(){
    audio_effect_manager_->pausePlayMusic(bgm_music_id);
}
void TestBGMSetting::resumePlayBgmMusic(){
    audio_effect_manager_->resumePlayMusic(bgm_music_id);
}

void TestBGMSetting::setVoiceReverbType(trtc::TXVoiceReverbType type){
    audio_effect_manager_->setVoiceReverbType(type);
}

void TestBGMSetting::setMusicPublishVolume(int volume){
     audio_effect_manager_->setMusicPublishVolume(bgm_music_id,volume);
}
void TestBGMSetting::setMusicPlayoutVolume(int volume){
    audio_effect_manager_->setMusicPlayoutVolume(bgm_music_id,volume);
}
void TestBGMSetting::setAllMusicVolume(int volume){
    audio_effect_manager_->setAllMusicVolume(volume);
}
void TestBGMSetting::setMusicPitch(float pitch){
    audio_effect_manager_->setMusicPitch(bgm_music_id,pitch);
}
void TestBGMSetting::setMusicSpeedRate(float speedRate){
    audio_effect_manager_->setMusicSpeedRate(bgm_music_id,speedRate);
}

void TestBGMSetting::setVoiceCaptureVolume(int volume){
    audio_effect_manager_->setVoiceCaptureVolume(volume);
}
//============= ITXMusicPlayObserver start ===============//
void TestBGMSetting::onStart(int id,int errCode){
    emit start(id,errCode);
}
void TestBGMSetting::onPlayProgress(int id,long curPtsMS,long durationMS){
    emit playProgress(id,curPtsMS,durationMS);
}
void TestBGMSetting::onComplete(int id,int errCode){
    emit complete(id,errCode);
}
//=============  ITXMusicPlayObserver end  ===============//

void TestBGMSetting::handleStart(int id,int errCode){
    if(errCode == 0){
        changeBgmControlerStatus(true);
        started_bgm_status_ = true;
        updateDynamicTextUI();
    } else {
        QMessageBox::warning(this,"Failed to play background music",QString::number(errCode),QMessageBox::Ok);
    }
    ui_bgm_setting_->btnStartBgm->setEnabled(true);
}

void TestBGMSetting::handlePlayProgress(int id,long curPtsMS,long durationMS){
    ui_bgm_setting_->progressbarBgmProgress->setValue(curPtsMS*100 / durationMS);
}

void TestBGMSetting::handleComplete(int id,int errCode){
    ui_bgm_setting_->progressbarBgmProgress->setValue(0);
    started_bgm_status_ = false;
    paused_bgm_status_ = false;
    changeBgmControlerStatus(false);
    resetDefaultValue();
    updateDynamicTextUI();
}

void TestBGMSetting::on_btnStartBgm_clicked(){
    if(started_bgm_status_){
        stopPlayBgmMusic();
        ui_bgm_setting_->progressbarBgmProgress->setValue(0);
        changeBgmControlerStatus(false);
        resetDefaultValue();
        started_bgm_status_ = false;
        paused_bgm_status_ = false;
        bgm_music_id = -1;
        updateDynamicTextUI();
    }else{
        ui_bgm_setting_->btnStartBgm->setEnabled(false);
        bgm_music_id = ui_bgm_setting_->comboxSelectBgmMusic->currentIndex();
        QString bgm_music;

        if(bgm_music_id == 0){
            bgm_music = BGM_FIRST;
        }else if(bgm_music_id == 1){
            bgm_music = BGM_SECOND;
        }else if(bgm_music_id == 2){
            bgm_music = BGM_THIRD;
        }

        QString runPath = QCoreApplication::applicationDirPath();
        QString finalPath = runPath.append(bgm_music);

        QFileInfo file_info(QDir::toNativeSeparators(finalPath));
        if (!file_info.exists()) {
            QMessageBox::warning(this,"Failed to play background music","The music file does not exist.",QMessageBox::Ok);
            return;
        }

        int loop_count = ui_bgm_setting_->etRepeatTimes->text().toInt();
        bool publish = ui_bgm_setting_->cbEnableRemotePush->isChecked();
        bool is_shortfile = ui_bgm_setting_->cbShortFile->isChecked();
        std::string dest_path_str = QDir::toNativeSeparators(file_info.absoluteFilePath()).toStdString().data();
        startPlayBgmMusic(dest_path_str,loop_count,publish,is_shortfile);
    }
}

void TestBGMSetting::on_btnPauseBgm_clicked(){
    if(!started_bgm_status_){
        return;
    }
    if(paused_bgm_status_){
        resumePlayBgmMusic();
    } else {
        pausePlayBgmMusic();
    }
    paused_bgm_status_ = !paused_bgm_status_;
    updateDynamicTextUI();
}

void TestBGMSetting::on_btnRestSetting_clicked(){
    resetDefaultValue();
}

void TestBGMSetting::on_comboxSetVoiceReverbType_currentIndexChanged(int index){
    setVoiceReverbType(static_cast<trtc::TXVoiceReverbType>(index));
}

void TestBGMSetting::on_sliderSetVoiceCaptureVolum_valueChanged(int value){
    setVoiceCaptureVolume(value);
}

void TestBGMSetting::on_sliderSetLocalVolume_valueChanged(int value){
    setMusicPlayoutVolume(value);
}

void TestBGMSetting::on_sliderSetRemoteVolume_valueChanged(int value){
    setMusicPublishVolume(value);
}

void TestBGMSetting::on_sliderSetAllVolume_valueChanged(int value){
    ui_bgm_setting_->sliderSetLocalVolume->setValue(value);
    ui_bgm_setting_->sliderSetRemoteVolume->setValue(value);
    setAllMusicVolume(value);
}

void TestBGMSetting::on_sliderSetPitch_valueChanged(int value){
    float pitch = static_cast<float>(value) / 10;
    setMusicPitch(pitch);
}

void TestBGMSetting::on_sliderSetSpeedRate_valueChanged(int value){
    float rate = static_cast<float>(value) / 10;
    setMusicSpeedRate(rate);
}

void TestBGMSetting::changeBgmControlerStatus(bool enable){
    ui_bgm_setting_->sliderSetAllVolume->setEnabled(enable);
    ui_bgm_setting_->sliderSetPitch->setEnabled(enable);
    ui_bgm_setting_->sliderSetSpeedRate->setEnabled(enable);
    ui_bgm_setting_->sliderSetLocalVolume->setEnabled(enable);
    ui_bgm_setting_->sliderSetRemoteVolume->setEnabled(enable);
}

void TestBGMSetting::resetDefaultValue()
{
    ui_bgm_setting_->sliderSetAllVolume->setValue(100);
    ui_bgm_setting_->sliderSetPitch->setValue(0);
    ui_bgm_setting_->sliderSetSpeedRate->setValue(10);
    ui_bgm_setting_->sliderSetLocalVolume->setValue(100);
    ui_bgm_setting_->sliderSetRemoteVolume->setValue(100);
    ui_bgm_setting_->sliderSetVoiceCaptureVolum->setValue(100);
    ui_bgm_setting_->comboxSetVoiceReverbType->setCurrentIndex(0);
}

void TestBGMSetting::closeEvent(QCloseEvent *event){
    if(started_bgm_status_){
        stopPlayBgmMusic();
        bgm_music_id = -1;
        ui_bgm_setting_->progressbarBgmProgress->setValue(0);
        started_bgm_status_ = false;
        paused_bgm_status_ = false;
        updateDynamicTextUI();
        changeBgmControlerStatus(false);
        resetDefaultValue();
    }
    
    BaseDialog::closeEvent(event);
}

void TestBGMSetting::updateDynamicTextUI() {
    if (paused_bgm_status_) {
        ui_bgm_setting_->btnPauseBgm->setText(tr("恢复播放").toUtf8());
    } else {
        ui_bgm_setting_->btnPauseBgm->setText(tr("暂停播放").toUtf8());
    }
    if (started_bgm_status_) {
        ui_bgm_setting_->btnStartBgm->setText(tr("停止播放").toUtf8());
    } else {
        ui_bgm_setting_->btnStartBgm->setText(tr("开始播放").toUtf8());
    }
}

void TestBGMSetting::retranslateUi() {
    ui_bgm_setting_->retranslateUi(this);
}