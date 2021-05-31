/**
 * TRTC 视频自定义渲染，即不依赖TRTC库的默认渲染能力，接收视频数据，自定义渲染
 *
 * - 核心方法调用：setLocalVideoRenderCallback()/setRemoteVideoRenderCallback()，通过设置回调接收SDK接收到的本地/远程数据，进行自定义的渲染操作
 * -
 * - 调用方法参考 :
 * - startLocalVideoRender() / stopLocalVideoRender()
 * - startRemoteVideoRender() / stopRemoteVideoRender()
 * -
 * - 具体API说明可参见https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__ITRTCCloud__cplusplus.html#ad64031e060146f7985263aad994fc733
 */

#ifndef TESTCUSTOMRENDER_H
#define TESTCUSTOMRENDER_H

#include <QDialog>
#include "ITRTCCloud.h"
#include "gl_yuv_widget.h"
#include "ui_TestCustomRenderDialog.h"

class TestCustomRender:public QDialog,public trtc::ITRTCVideoRenderCallback
{
    Q_OBJECT
public:
    explicit TestCustomRender(QWidget * parent = nullptr);
    ~TestCustomRender();

private:
    void startLocalVideoRender();
    void startRemoteVideoRender(std::string& userId);

    void stopLocalVideoRender();
    void stopRemoteVideoRender(std::string& userId);

    //============= ITRTCVideoRenderCallback start ===================//
    void onRenderVideoFrame(const char *userId, trtc::TRTCVideoStreamType streamType, trtc::TRTCVideoFrame *frame) override;
    //=============  ITRTCVideoRenderCallback end  ===================//

private slots:
    void on_btnStartCustomRender_clicked();

signals:
    void renderViewSize(int wdith,int height);

public:
    void closeEvent(QCloseEvent* event) override;
    void showEvent(QShowEvent *) override;

    void stopRender();

    void startRender();

    void refrshUsers();

private:
    void initViews();
    void destroyCustomRender();
    void adapterRenderViewSize(int width,int height);

private:
    std::unique_ptr<Ui::TestCustomRenderDialog> ui_test_custom_render_;
    GLYuvWidget* gl_yuv_widget_ = nullptr;
    bool started_custom_render = false;
    std::string current_render_user_id;

    bool view_resized_ = false;
};

#endif // TESTCUSTOMRENDER_H
