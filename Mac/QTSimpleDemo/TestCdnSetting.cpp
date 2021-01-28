//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "TestCdnSetting.h"
#include "ui_TestCdnSetting.h"
#include "base/Defs.h"

#define PLACE_HOLDER_LOCAL_MAIN   "$PLACE_HOLDER_LOCAL_MAIN$"
#define PLACE_HOLDER_LOCAL_SUB    "$PLACE_HOLDER_LOCAL_SUB$"
#define PLACE_HOLDER_REMOTE       "$PLACE_HOLDER_REMOTE$"
#define MIX_USERS_COUNT           2
using namespace trtc;

TestCdnSetting::TestCdnSetting(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::TestCdnSetting) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();
    m_trtcCloud->addCallback(this);
    m_mixUsersArray = new trtc::TRTCMixUser[MIX_USERS_COUNT];
}

TestCdnSetting::~TestCdnSetting() {
    if (m_trtcCloud != nullptr) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
    if (m_mixUsersArray != nullptr) {
        delete []m_mixUsersArray;
    }
    if (ui != nullptr) {
        delete ui;
    }
}

void TestCdnSetting::setUserId(QString &userId) {
    m_userId = userId.toStdString();
}

void TestCdnSetting::setRoomId(QString &roomId) {
    m_roomId = roomId.toStdString();
}

void TestCdnSetting::on_startPublishingBtn_clicked(bool checked) {
    if (checkMixTranscodingAbility() == false) {
        ui->startPublishingBtn->setChecked(false);
        return;
    }
    if (checked) {
        m_trtcCloud->startPublishing(m_transcodingConfig.streamId, trtc::TRTCVideoStreamTypeBig);
        on_updateMixTranscodingConfigBtn_clicked();

    } else {
        m_trtcCloud->stopPublishing();
        cancleMixTranscodingConfig();
    }
}

void TestCdnSetting::cancleMixTranscodingConfig() {
    m_trtcCloud->setMixTranscodingConfig(nullptr);
}

void TestCdnSetting::closeEvent(QCloseEvent *) {
    hide();
}

void TestCdnSetting::on_videoBitrate_valueChanged(int value) {
    ui->videoBitrateLabel->setText(QString::number(value) + " kbps");
}

void TestCdnSetting::onExitRoom(int reason) {
    ui->startPublishingBtn->setChecked(false);
    cancleMixTranscodingConfig();
}

void TestCdnSetting::onUserVideoAvailable(const char *userId, bool available) {
    int index = m_userIds.indexOf(QString(userId));
    if (available) {
        if (index < 0) {
            m_userIds.push_back(QString(userId));
        }
    } else {
        m_userIds.remove(index);
    }
    on_updateMixTranscodingConfigBtn_clicked();
}

bool TestCdnSetting::checkMixTranscodingAbility() {
    QString streamId = ui->streamId->text();
    uint32_t bizId = ui->bizId->text().toUInt();
    uint32_t videoGOP = ui->videoGOP->text().toUInt();
    uint32_t videoWidth = ui->videoWidth->text().toUInt();
    QString backgroundImage = ui->backgroundImage->text();
    uint32_t videoHeight = ui->videoHeight->text().toUInt();
    uint32_t videoBitrate = static_cast<uint32_t>(ui->videoBitrate->value());
    uint32_t audioBitrate = ui->audioBitrate->text().toUInt();
    uint32_t audioChannels = ui->audioChannels->text().toUInt();
    uint32_t videoFramerate = ui->videoFramerate->text().toUInt();
    uint32_t audioSampleRate = ui->audioSampleRate->currentText().toUInt();
    trtc::TRTCTranscodingConfigMode mode = static_cast<trtc::TRTCTranscodingConfigMode>(ui->mode->currentIndex());

    if (videoFramerate < 1 || videoFramerate > 30) {
        m_messageTipDialog.showMessageTip("视频帧率：非法，\n\n取值范围 (0-30] 的整数");
        return false;
    } else if (streamId.length() < 1) {
        m_messageTipDialog.showMessageTip("直播流 ID：非法，\n\n不能为空");
        return false;
    } else if (videoWidth <= 0) {
        m_messageTipDialog.showMessageTip("分辨率的宽度：非法，\n\n请输入一个整数");
        return false;
    } else if (videoHeight <= 0) {
        m_messageTipDialog.showMessageTip("分辨率的高度：非法，\n\n请输入一个整数");
        return false;
    } else if (bizId == 0) {
        m_messageTipDialog.showMessageTip("腾讯云直播 bizid：非法，\n\n仅支持 uint32_t 类型");
        return false;
    } else if (audioBitrate > 192 || audioBitrate < 32) {
        m_messageTipDialog.showMessageTip("音频码率：非法，\n\n取值范围 [32-192] 的整数");
        return false;
    } else if (audioChannels < 1 || audioChannels > 2) {
        m_messageTipDialog.showMessageTip("音频声道数：非法，\n\n取值范围为 [1-2] 中的整型");
        return false;
    } else if (videoGOP < 1 || videoGOP > 8) {
        m_messageTipDialog.showMessageTip("关键帧间隔：非法，\n\n取值范围 [1-8] 的整数");
        return false;
    } else if (audioSampleRate < 12000 || audioSampleRate > 48000) {
        m_messageTipDialog.showMessageTip("音频采样率：非法，\n\n支持12000HZ、16000HZ、22050HZ、24000HZ、32000HZ、44100HZ、48000HZ");
        return false;
    } else if (mode == trtc::TRTCTranscodingConfigMode_Unknown) {
        m_messageTipDialog.showMessageTip("混流参数配置模式：非法（Unknown）");
        return false;
    }

    m_transcodingConfig.mode = mode;
    m_transcodingConfig.bizId = bizId;
    m_transcodingConfig.appId = SDKAppID;
    m_transcodingConfig.videoGOP = videoGOP;
    m_transcodingConfig.videoWidth = videoWidth;
    m_transcodingConfig.videoHeight = videoHeight;
    m_transcodingConfig.audioBitrate = audioBitrate;
    m_transcodingConfig.videoBitrate = videoBitrate;
    m_transcodingConfig.audioChannels = audioChannels;
    m_transcodingConfig.videoFramerate = videoFramerate;
    m_transcodingConfig.audioSampleRate = audioSampleRate;
    // demo写死0xff0000，实际开发中根据需求来调背景色
    m_transcodingConfig.backgroundColor = 0x000000;

    m_streamId = streamId.toStdString();
    m_transcodingConfig.streamId = m_streamId.c_str();

    m_backgroundImage = backgroundImage.toStdString();
    m_transcodingConfig.backgroundImage = m_backgroundImage.c_str();

    return true;
}

void TestCdnSetting::on_updateMixTranscodingConfigBtn_clicked() {
    if (checkMixTranscodingAbility() == false) {
        return;
    }

    trtc::TRTCTranscodingConfigMode mode = m_transcodingConfig.mode;
    if (mode == trtc::TRTCTranscodingConfigMode_Unknown) {
        cancleMixTranscodingConfig();

    } else if (mode == trtc::TRTCTranscodingConfigMode_Template_PureAudio || mode == trtc::TRTCTranscodingConfigMode_Template_ScreenSharing) {
        m_transcodingConfig.videoWidth = 0;
        m_transcodingConfig.videoHeight = 0;
        m_transcodingConfig.mixUsersArray = nullptr;
        m_transcodingConfig.mixUsersArraySize = 0;
        m_trtcCloud->setMixTranscodingConfig(&m_transcodingConfig);

    } else {
        if (m_mixUsersArray == nullptr) {
            cancleMixTranscodingConfig();
            return;
        }

        uint32_t mixUsersArraySize = static_cast<uint32_t>(m_userIds.count()) + 1; // +1是：本地画面
        bool isPresetLayout = mode == trtc::TRTCTranscodingConfigMode_Template_PresetLayout;

        trtc::TRTCMixUser localUser;
        localUser.zOrder = 1;
        localUser.roomId = m_roomId.c_str();
        localUser.userId = isPresetLayout ? PLACE_HOLDER_LOCAL_MAIN : m_userId.c_str();
        // demo布局逻辑仅简单展示功能，实际开发可根据需求进行合理布局
        RECT localRect;
        localRect.top = 40;
        localRect.left = 40;
        localRect.right = 1200;
        localRect.bottom = 1200;
        localUser.rect = localRect;
        m_mixUsersArray[0] = localUser;

        std::string remoteUid;
        if (mixUsersArraySize > MIX_USERS_COUNT - 1) {
            trtc::TRTCMixUser remoteUser;
            remoteUser.zOrder = 2;
            remoteUser.roomId = m_roomId.c_str();
            remoteUid = m_userIds.at(0).toStdString();
            remoteUser.userId = isPresetLayout ? PLACE_HOLDER_REMOTE : remoteUid.c_str();
            // demo布局逻辑仅简单展示功能，实际开发可根据需求进行合理布局
            RECT remoteRect;
            remoteRect.top = isPresetLayout ? 50 : 100;
            remoteRect.left = isPresetLayout ? 50 : 100;
            remoteRect.right = isPresetLayout ? 200 : 300;
            remoteRect.bottom = isPresetLayout ? 280 : 420;
            remoteUser.rect = remoteRect;
            m_mixUsersArray[1] = remoteUser;
            mixUsersArraySize = MIX_USERS_COUNT;
        }

        m_transcodingConfig.mixUsersArray = m_mixUsersArray;
        m_transcodingConfig.mixUsersArraySize = mixUsersArraySize;
        m_trtcCloud->setMixTranscodingConfig(&m_transcodingConfig);
    }
}

void TestCdnSetting::onEnterRoom(int result) {}
void TestCdnSetting::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) {}
void TestCdnSetting::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) {}
