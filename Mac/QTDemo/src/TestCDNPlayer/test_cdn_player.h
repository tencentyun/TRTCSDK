/**
 * TRTC CDN播放器，直播播放器SDK的封装，可以播放转推腾讯云的CDN流
 * 
 * - 播放器参考：https://cloud.tencent.com/document/product/454/34775
 * -
 * - 只有在您已经开通了直播服务并配置了播放域名的情况下，才能通过 CDN 正常观看这条直播流。
 * - 获取可以转推成功，并在线播放的CDN地址，可参考：
 * - 1. 实现CDN直播观看：https://cloud.tencent.com/document/product/647/16826
 * - 2. 添加自有域名：https://cloud.tencent.com/document/product/267/20381
 */

/**
 * CDN player, which is based on the live player SDK and can play CDN streams relayed to Tencent Cloud
 *
 * - You can watch a live stream over CDNs only after you have activated CSS and configured a playback domain name.
 * - To obtain a valid URL for relayed push and CDN playback, refer to the documents below:
 * - 1.  CDN Relayed Live Streaming: https://intl.cloud.tencent.com/document/product/647/35242
 * - 2.  Adding Domain Name: https://intl.cloud.tencent.com/document/product/267/35970
 */

#ifndef TESTCDNPLAYER_H
#define TESTCDNPLAYER_H

#include "tx_liveplayer_proxy.h"
#include "base_dialog.h"
#include "ui_TestCdnPlayerDialog.h"
class TestCdnPlayer :public BaseDialog
{
    Q_OBJECT
public:
    explicit TestCdnPlayer(QWidget *parent = nullptr);
    ~TestCdnPlayer();

private slots:
    void on_btStart_clicked();
    void on_btPause_clicked();

public:
     void closeEvent(QCloseEvent* event) override;
private:
    void retranslateUi() override;
    void updateDynamicTextUI() override;
private:
    std::unique_ptr<Ui::TestCdnPlayerDialog> ui_test_cdn_player_;
    TXLivePlayerProxy* live_player_ = nullptr;
    bool paused_ = false;
    bool started_ = false;
};

#endif // TESTCDNPLAYER_H

