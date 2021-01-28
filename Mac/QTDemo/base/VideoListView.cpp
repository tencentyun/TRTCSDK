//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#include "VideoListView.h"
#include "ui_VideoListView.h"
#include <QtDebug>
#include "ui_TestVideoSetting.h"
#ifdef __APPLE__
#include "GenerateTestUserSig.h"
#endif
#ifdef _WIN32
#include "GenerateTestUsersig.h"
#endif

VideoListView::VideoListView(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::VideoListView) {
    ui->setupUi(this);
    m_trtcCloud = getTRTCShareInstance();
    if (m_trtcCloud == nullptr) return;

    m_trtcCloud->addCallback(this);

    setupList();
    updateVideoViews(true);
}

VideoListView::~VideoListView() {
    reset();
    delete ui;
    if (m_trtcCloud != nullptr) {
        m_trtcCloud->removeCallback(this);
        m_trtcCloud = nullptr;
    }
}

QWidget *VideoListView::getLocalView() {
    if (m_videoViews.count() > 0) {
        return m_videoViews.at(0);
    }
    return nullptr;
}

void VideoListView::enterRoom(const trtc::TRTCParams& params, trtc::TRTCAppScene scene) {
    m_userId = QString(params.userId);

    m_trtcCloud->setDefaultStreamRecvMode(true, true);
    m_trtcCloud->enableAudioVolumeEvaluation(300);

    m_trtcCloud->enterRoom(params, scene);
    m_trtcCloud->startLocalAudio(trtc::TRTCAudioQualityDefault);

    // 真实开发中可根据不同场景灵活调用
    m_trtcCloud->startLocalPreview(reinterpret_cast<trtc::TXView>(ui->videoView0->winId()));
    m_trtcCloud->setBeautyStyle(trtc::TRTCBeautyStyleSmooth, 6, 6, 6);
}

void VideoListView::updateRoomMembers() {
    bool isEmpty = m_roomMembers.count() == 0;
    ui->switchAllRemoteVideo->setEnabled(isEmpty == false);
    ui->switchAllRemoteAudio->setEnabled(isEmpty == false);
    if (isEmpty) {
        ui->memberLabel->setText(QString::fromLocal8Bit("暂无成员~").toUtf8());
        return;
    }

    QString memberIds = QString::fromLocal8Bit("成员列表: ");
    for (int i = 0; i < m_roomMembers.count(); i++) {
        memberIds = memberIds + m_roomMembers.at(i) + (i == m_roomMembers.count() - 1 ? "" : ", ");
    }
    QByteArray mids = memberIds.toUtf8();
    ui->memberLabel->setText(mids);
}

void VideoListView::reset() {
    updateVideoViews(true);
    updateRoomMembers();
    ui->switchAllRemoteVideo->setEnabled(false);
    ui->switchAllRemoteAudio->setEnabled(false);
    ui->switchDashBoardButton->setEnabled(false);
}

void VideoListView::updateVideoViews(bool hidden) {
    std::lock_guard<std::mutex> lk(m_remoteVideoViewsMutex);
    for (int i = 0; i < m_videoViews.count(); i++) {
        QWidget *videoView = m_videoViews[i];
        videoView->setHidden(hidden);
        QProgressBar *progressBar = m_progressBars[i];
        progressBar->setHidden(hidden);

        QPushButton *audio = m_audios[i];
        audio->setHidden(hidden);
        QPushButton *video = m_videos[i];
        video->setHidden(hidden);
        updateButtonState(audio, false, Audio, progressBar);
        updateButtonState(video, false, Video);
    }

#ifdef _WIN32
    // fix the white border issue for win-system
    if (m_videoViews.count() < 1) return;
    QPalette pal;
    pal.setColor(QPalette::Background, Qt::black);
    m_videoViews[0]->setAutoFillBackground(true);
    m_videoViews[0]->setPalette(pal);
#endif
}

void VideoListView::onEnterRoom(int result) {
    if (result > 0) {
        // 进房成功
        ui->videoView0->setHidden(false);
        ui->video0->setHidden(false);
        ui->audio0->setHidden(false);
        ui->progressBar0->setHidden(false);
        m_userIds.push_back(m_userId);
        ui->switchDashBoardButton->setEnabled(true);
    } else {
        // 进房失败
        QString errorTip(QString::fromLocal8Bit("进房失败，错误码：").toUtf8());
        errorTip.append(QString::number(result));
        errorTip.append(QString::fromLocal8Bit("\n请您检查房间号、用户ID等输入是否合法\n或您可尝试重新输入房间号、用户ID").toUtf8());
        std::string msg = errorTip.toStdString();
        m_alertDialog.showMessageTip(msg.c_str());
    }
}

void VideoListView::onExitRoom(int reason) {
    ui->videoView0->setHidden(true);
    m_roomMembers.clear();
    m_userIds.clear();
    reset();
}

void VideoListView::onRemoteUserEnterRoom(const char *userId) {
    m_roomMembers.push_back(QString(userId));
    updateRoomMembers();
}

void VideoListView::onRemoteUserLeaveRoom(const char *userId, int reason) {
    m_roomMembers.remove(m_roomMembers.indexOf(QString(userId)));
    updateRoomMembers();
}

void VideoListView::onUserVoiceVolume(trtc::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) {
    if (userVolumes == nullptr) return;

    int volume = (int)userVolumes->volume;
    if (strlen(userVolumes->userId) < 1) {
        // 自己在说话
        ui->progressBar0->setValue(volume);
    } else {
        QString uid = QString(userVolumes->userId);
        int index = m_userIds.indexOf(uid);
        if (index > 0 && index < m_progressBars.count() - 1) {
            m_progressBars[index]->setValue(volume);
        }
    }
}

void VideoListView::onUserVideoAvailable(const char *userId, bool available) {
    int index = m_userIds.indexOf(QString(userId));
    if (available) {
        if (index < 0) {
            m_userIds.push_back(QString(userId));
            refreshRemoteVideoViews(m_userIds.count() - 1);
            ui->switchAllRemoteAudio->setChecked(false);
            ui->switchAllRemoteVideo->setChecked(false);
        } else {
            // 因为第0个永远是本地画面，所以从1开始refresh
            refreshRemoteVideoViews(1);
        }
    } else {
        m_trtcCloud->stopRemoteView(userId, trtc::TRTCVideoStreamTypeSmall);
        m_userIds.remove(index);
        refreshRemoteVideoViews(index);
    }
}

void VideoListView::refreshRemoteVideoViews(int from) {
    for (int i = from; i < m_videoViews.count(); i++) {
        bool needUpdate = i < m_userIds.count();
        if (needUpdate) {
            std::string str = m_userIds.at(i).toStdString();
            m_trtcCloud->startRemoteView(str.c_str(), trtc::TRTCVideoStreamTypeSmall, reinterpret_cast<trtc::TXView>(m_videoViews[i]->winId()));
            on_switchAllRemoteAudio_clicked(false);
            on_switchAllRemoteVideo_clicked(false);
        }
        m_audios.at(i)->setHidden(!needUpdate);
        m_videos.at(i)->setHidden(!needUpdate);
        m_videoViews.at(i)->setHidden(!needUpdate);
        m_progressBars.at(i)->setHidden(!needUpdate);
    }
}

void VideoListView::onUserSubStreamAvailable(const char *userId, bool available) {
    if (available) {
        m_trtcCloud->startRemoteView(userId, trtc::TRTCVideoStreamTypeSub, (trtc::TXView)(ui->screenCaptureView->winId()));
    } else {
        m_trtcCloud->stopRemoteView(userId, trtc::TRTCVideoStreamTypeSub);
    }
}

void VideoListView::on_switchAllRemoteVideo_clicked(bool checked) {
    m_trtcCloud->muteAllRemoteVideoStreams(checked);
    for (int i = 1; i < m_videos.count(); i++) {
        updateButtonState(m_videos[i], checked, Video);
    }
}

void VideoListView::on_switchAllRemoteAudio_clicked(bool checked) {
    m_trtcCloud->muteAllRemoteAudio(checked);
    for (int i = 1; i < m_audios.count(); i++) {
        updateButtonState(m_audios[i], checked, Audio, m_progressBars[i]);
    }
}

/**
 * 简单起见，本Demo中下述 audio & video 的相关控制事件定义的比较激进粗糙，真实开发中应考虑封装优化 *
 */
void VideoListView::on_audio0_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 1) return;

    if (flag) ui->audio0->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/audio_close.png);}");
    else ui->audio0->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/audio_normal.png);}");
    if (flag == false) {
        if (m_progressBars[0] != nullptr) m_progressBars[0]->setValue(0);
    }

    m_trtcCloud->muteLocalAudio(flag);
}
void VideoListView::on_video0_clicked() {
    static bool flag = false; flag = !flag;
    if (flag) ui->video0->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/video_close.png);}");
    else ui->video0->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/video_normal.png);}");

    m_trtcCloud->muteLocalVideo(flag);
}

void VideoListView::on_audio1_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 2) return;
    updateButtonState(ui->audio1, flag, Audio, m_progressBars[1]);
    muteRemoteStream(Audio, flag, 1);
}
void VideoListView::on_video1_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video1, flag, Video);
    muteRemoteStream(Video, flag, 1);
}

void VideoListView::on_audio2_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 3) return;
    updateButtonState(ui->audio2, flag, Audio, m_progressBars[2]);
    muteRemoteStream(Audio, flag, 2);
}
void VideoListView::on_video2_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video2, flag, Video);
    muteRemoteStream(Video, flag, 2);
}

void VideoListView::on_audio3_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 4) return;
    updateButtonState(ui->audio3, flag, Audio, m_progressBars[3]);
    muteRemoteStream(Audio, flag, 3);
}
void VideoListView::on_video3_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video3, flag, Video);
    muteRemoteStream(Video, flag, 3);
}

void VideoListView::on_audio4_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 5) return;
    updateButtonState(ui->audio4, flag, Audio, m_progressBars[4]);
    muteRemoteStream(Audio, flag, 4);
}
void VideoListView::on_video4_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video4, flag, Video);
    muteRemoteStream(Video, flag, 4);
}

void VideoListView::on_audio5_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 6) return;
    updateButtonState(ui->audio5, flag, Audio, m_progressBars[5]);
    muteRemoteStream(Audio, flag, 5);
}
void VideoListView::on_video5_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video5, flag, Video);
    muteRemoteStream(Video, flag, 5);
}

void VideoListView::on_audio6_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 7) return;
    updateButtonState(ui->audio6, flag, Audio, m_progressBars[6]);
    muteRemoteStream(Audio, flag, 6);
}
void VideoListView::on_video6_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video6, flag, Video);
    muteRemoteStream(Video, flag, 6);
}

void VideoListView::on_audio7_clicked() {
    static bool flag = false; flag = !flag;
    if (m_progressBars.count() < 8) return;
    updateButtonState(ui->audio7, flag, Audio, m_progressBars[7]);
    muteRemoteStream(Audio, flag, 7);
}
void VideoListView::on_video7_clicked() {
    static bool flag = false; flag = !flag;
    updateButtonState(ui->video7, flag, Video);
    muteRemoteStream(Video, flag, 7);
}

void VideoListView::muteRemoteStream(ControlButtonType type, bool mute, int index) {
    if (index < 0 || index > m_userIds.count() - 1) return;
    if (type == Audio) {
        std::string uid = m_userIds.at(index).toStdString();
        m_trtcCloud->muteRemoteAudio(uid.c_str(), mute);
    } else if (type == Video) {
        std::string uid = m_userIds.at(index).toStdString();
        m_trtcCloud->muteRemoteVideoStream(uid.c_str(), mute);
    }
}

void VideoListView::updateButtonState(QPushButton *button, bool state, ControlButtonType type, QProgressBar *progressBar) {
    if (type == Audio) {
        if (state) button->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/audio_close.png);}");
        else button->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/audio_normal.png);}");
        if (state == false) {
            ui->switchAllRemoteAudio->setChecked(false);
            if (progressBar != nullptr) progressBar->setValue(0);
        }
    } else if (type == Video) {
        if (state) button->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/video_close.png);}");
        else button->setStyleSheet("QPushButton{border-image: url(:/switch/image/switch/video_normal.png);}");
        if (state == false) ui->switchAllRemoteVideo->setChecked(false);
    }
}

void VideoListView::on_switchDashBoardButton_clicked(bool checked) {
    m_trtcCloud->showDebugView(checked ? 2 : 0); // 0不显示信息，1显示简略信息，2显示详细信息
}

void VideoListView::setupList() {
    // 目前最多支持 8 个画面的布局
    m_videoViews.push_back(ui->videoView0);
    m_videoViews.push_back(ui->videoView1);
    m_videoViews.push_back(ui->videoView2);
    m_videoViews.push_back(ui->videoView3);
    m_videoViews.push_back(ui->videoView4);
    m_videoViews.push_back(ui->videoView5);
    m_videoViews.push_back(ui->videoView6);
    m_videoViews.push_back(ui->videoView7);

    m_progressBars.push_back(ui->progressBar0);
    m_progressBars.push_back(ui->progressBar1);
    m_progressBars.push_back(ui->progressBar2);
    m_progressBars.push_back(ui->progressBar3);
    m_progressBars.push_back(ui->progressBar4);
    m_progressBars.push_back(ui->progressBar5);
    m_progressBars.push_back(ui->progressBar6);
    m_progressBars.push_back(ui->progressBar7);

    m_audios.push_back(ui->audio0);
    m_audios.push_back(ui->audio1);
    m_audios.push_back(ui->audio2);
    m_audios.push_back(ui->audio3);
    m_audios.push_back(ui->audio4);
    m_audios.push_back(ui->audio5);
    m_audios.push_back(ui->audio6);
    m_audios.push_back(ui->audio7);

    m_videos.push_back(ui->video0);
    m_videos.push_back(ui->video1);
    m_videos.push_back(ui->video2);
    m_videos.push_back(ui->video3);
    m_videos.push_back(ui->video4);
    m_videos.push_back(ui->video5);
    m_videos.push_back(ui->video6);
    m_videos.push_back(ui->video7);

    for (int i = 0; i < m_videoViews.count(); i++) {
        QWidget *videoView = m_videoViews.at(i);
        if (videoView != nullptr) videoView->setAttribute(Qt::WA_PaintOnScreen, true);
    }
}

QPaintEngine *VideoListView::paintEngine() const {
    return nullptr;
}

void VideoListView::onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo)
{ qDebug() << "errCode: " << errCode << "  errMsg: " << errMsg << "  extraInfo: " << extraInfo; }
void VideoListView::onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo)
{ qDebug() << "warningCode: " << warningCode << "  warningMsg: " << warningMsg << "  extraInfo: " << extraInfo; }
