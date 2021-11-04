/**
 * TRTC 自定义消息发送模块，
 *
 * - 两种消息发送方式：
 * - 1. 借助音视频数据传输通道向当前房间里的其他用户广播您自定义的数据
 * - 2. 将小数据量的自定义数据嵌入视频帧中，即使视频帧被旁路到了直播 CDN 上，这些数据也会一直存在，最常见的用法是把自定义的时间戳（timstamp）用 sendSEIMsg 嵌入视频帧中，这种方案的最大好处就是可以实现消息和画面的完美对齐。
 * -
 * - 音视频数据通道发送消息 : 参考sendCustomMessage()
 * - 视频帧介质发送消息 : 参考sendSEIMessage()
 * - 具体API说明可参见：https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#a858b11d4d32ee0fd69b42d64a1d65389
 */

/**
 * Custom message sending
 *
 * - Two methods:
 * - 1.  Broadcast custom data to other users in the room via the audio/video transmission channel.
 * - 2.  Embed small-volume custom data into video frames, in which case the data will be retained even if the video frames are relayed to live streaming CDNs. The most common practice is using sendSEIMsg to insert custom timestamps into video frames, which can ensure that the messages and video images are in sync.
 * -
 * - Sending messages via the audio/video transmission channel:  sendCustomMessage()
 * - Sending messages by inserting data into video frames:  sendSEIMessage()
 * - For details about the APIs, see: https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#a858b11d4d32ee0fd69b42d64a1d65389
 */

#ifndef TESTCUSTOMMESSAGE_H
#define TESTCUSTOMMESSAGE_H

#include "base_dialog.h"
#include "ui_TestCustomMessageDialog.h"
#include "ITRTCCloud.h"
#include "trtc_cloud_callback_default_impl.h"

class TestCustomMessage:
        public BaseDialog,
        public TrtcCloudCallbackDefaultImpl
{
    Q_OBJECT
public:
    explicit TestCustomMessage(QWidget *parent = nullptr);
    ~TestCustomMessage();

    //============= ITRTCCloudCallback start ===================//
    void onRecvSEIMsg(const char* userId, const uint8_t* message, uint32_t messageSize) override;
    void onMissCustomCmdMsg(const char* userId, int32_t cmdID, int32_t errCode, int32_t missed) override;
    void onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) override;
    //============= ITRTCCloudCallback end ===================//

private:
    void sendCustomMessage();
    void sendSEIMessage();

    void retranslateUi() override;
private slots:
    void on_pushButtonSendCmdMsg_clicked();

    void on_pushButtonSendSEIMsg_clicked();

public:
    //UI-related
    void closeEvent(QCloseEvent *event) override;

private:
    std::unique_ptr<Ui::TestCustomMessageDialog> ui_custom_message_;
    trtc::ITRTCCloud *trtccloud_;
};

#endif // TESTCUSTOMMESSAGE_H
