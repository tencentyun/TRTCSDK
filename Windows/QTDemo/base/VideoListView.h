//  QTSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef QTMACDEMO_BASE_VIDEOLISTVIEW_H
#define QTMACDEMO_BASE_VIDEOLISTVIEW_H

#include <QDialog>
#include "ITRTCCloud.h"
#include <QProgressBar>
#include "base/AlertDialog.h"
#include "base/Defs.h"
#include <mutex>

namespace Ui {
class VideoListView;
}

class VideoListViewItem : public QWidget {
    Q_OBJECT
 public:
    explicit VideoListViewItem(QWidget *parent = nullptr) : QWidget(parent) { }

    QPaintEngine *paintEngine() const {
        return nullptr;
    }
};

class VideoListView : public QDialog, public trtc::ITRTCCloudCallback {
    Q_OBJECT

 public:
    VideoListView(QWidget *parent = nullptr);
    ~VideoListView() override;
    QPaintEngine* paintEngine() const override;

    // 用户ID数组
    QVector<QString> m_userIds;

    QWidget *getLocalView();
    void enterRoom(const trtc::TRTCParams& params, trtc::TRTCAppScene scene);

 private:
    Ui::VideoListView *ui;
    trtc::ITRTCCloud *m_trtcCloud;

    // 本地登录用户的ID
    QString m_userId;
    std::mutex m_remoteVideoViewsMutex;
    AlertDialog m_alertDialog;

    // 房间内的成员列表数组，存储的是远端userId
    QVector<QString> m_roomMembers;

    // 展示用户画面的视图集合
    QVector<QWidget *> m_videoViews;
    QVector<QPushButton *> m_audios;
    QVector<QPushButton *> m_videos;
    QVector<QProgressBar *> m_progressBars;

    void muteRemoteStream(ControlButtonType type, bool mute, int index);
    void updateButtonState(QPushButton *button, bool state, ControlButtonType type, QProgressBar *progressBar = nullptr);

    // 更新成员列表
    void updateRoomMembers();
    // 刷新远端用户视图控件，一般当有用户进出房间时调用
    void refreshRemoteVideoViews(int index);

    void exitRoom();
    void setupList();
    void updateVideoViews(bool enabled);

    // 重置，退房时调用
    void reset();

    void onExitRoom(int reason) override;
    void onEnterRoom(int result) override;
    void onRemoteUserEnterRoom(const char *userId) override;
    void onRemoteUserLeaveRoom(const char *userId, int reason) override;
    void onUserVideoAvailable(const char *userId, bool available) override;
    void onUserSubStreamAvailable(const char *userId, bool available) override;
    void onError(TXLiteAVError errCode, const char *errMsg, void *extraInfo) override;
    void onWarning(TXLiteAVWarning warningCode, const char *warningMsg, void *extraInfo) override;
    void onUserVoiceVolume(trtc::TRTCVolumeInfo* userVolumes, uint32_t userVolumesCount, uint32_t totalVolume) override;

 private slots:
    void on_switchDashBoardButton_clicked(bool checked);
    void on_switchAllRemoteVideo_clicked(bool checked);
    void on_switchAllRemoteAudio_clicked(bool checked);

    // 简单起见，本Demo中下述 audio&video 的相关控制函数比较激进粗糙
    // 真实开发中应考虑封装优化下
    void on_audio0_clicked();
    void on_video0_clicked();
    void on_audio1_clicked();
    void on_video1_clicked();
    void on_audio2_clicked();
    void on_video2_clicked();
    void on_audio3_clicked();
    void on_video3_clicked();
    void on_audio4_clicked();
    void on_video4_clicked();
    void on_audio5_clicked();
    void on_video5_clicked();
    void on_audio6_clicked();
    void on_video6_clicked();
    void on_audio7_clicked();
    void on_video7_clicked();
};

#endif  // QTMACDEMO_BASE_VIDEOLISTVIEW_H
