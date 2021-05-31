/**
 * TRTC CDN发布模块
 *
 * 参考此模块中的方法调用，可以设置将当前进房推流转推到腾讯云CDN服务器：
 * - startPublishing : 开始向腾讯云的直播 CDN 推流：
 * - 如果需要推流功能，需要先在实时音视频 控制台 中的功能配置页开启“启用旁路推流”才能生效。
 * - 如果控制台中选择“指定流旁路”：则可以通过显式调用startPublishing启动推流，流ID为参数指定的流ID
 * - 如果控制台中选择“全局自动旁路”：则无需调用startPublishing也会在进房后自动推流，流ID可以通过
 * - enterRoom的streamId字段设置，调用startPublish接口的作用则是，可以通过调用改变流ID，
 * - 注意自动旁路不支持通过stopPublishing停止推流
 * -
 * - stopPublishing : 停止推流，如上所述，在启动全局自动旁路时，此接口不生效
 * -
 * - 注意：onStartPublishing()仅作为本地接口调用的成功状态通知，不作为云端推流成功的状态参考
 * - 注意：在启动全局自动旁路时，调用stopPublishing会通过onStopPublish回调错误码"-102069"
 */

#ifndef TESTCDNPUBLISH_H
#define TESTCDNPUBLISH_H

#include <QDialog>
#include "ui_TestCdnPublishDialog.h"
#include "trtc_cloud_callback_default_impl.h"

class TestCdnPublish:public QDialog,public TrtcCloudCallbackDefaultImpl{
    Q_OBJECT
public:
    explicit TestCdnPublish(QWidget* parent = nullptr);
    ~TestCdnPublish();
private:
    void stopPublishing();
    void startPublishing(std::string streamId);
    //============= ITRTCCloudCallback start ===============//
    void onStartPublishing (int err, const char *errMsg) override;
    void onStopPublishing (int err, const char *errMsg) override;
    //============= ITRTCCloudCallback end =================//

private slots:
    void on_switchPublishStatus_clicked();
    void on_streamIdLineEt_textChanged(const QString &streamId);

public:
    void showEvent(QShowEvent *) override;

private:
    Ui::TestCdnPublishDialog* ui;
    bool is_publishing_ = false;
    bool is_manual_closing_ = false;
};

#endif // TESTCDNPUBLISH_H
