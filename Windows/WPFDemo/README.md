# TRTCWPFDemo

本 Demo 主要提供 TRTC SDK 的自定义渲染功能在 WPF 框架下如何使用的简单示例。

## TXLiteAVVideoView

使用 TRTC SDK 自定义渲染功能实现的自定义 View，可供客户直接拷贝使用，或根据实际业务情况对该类进行修改和扩展。

**主要实现代码：[TXLiteAVVideoView.cs](https://github.com/tencentyun/TRTCSDK/tree/master/Windows/WPFDemo/TXLiteAVVideoView.cs)**

> 注意：目前内部只实现了 BGRA32 的数据类型回调并渲染，如需其他类型数据（如 I420）实现，请自行扩展。

## 如何使用

主要示例代码：[MainWindow.xaml.cs](https://github.com/tencentyun/TRTCSDK/tree/master/Windows/WPFDemo/MainWindow.xaml.cs)

### 本地画面渲染

#### 步骤一：打开本地采集接口，并传入空窗口句柄

```
mTRTCCloud.startLocalPreview(IntPtr.Zero);
```

#### 步骤二：创建 TXLiteAVVideoView 并绑定 SDK 渲染回调

```
TXLiteAVVideoView view = new TXLiteAVVideoView();
view.RegEngine(localUserId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, mTRTCCloud, true);
```

####  步骤三：设置 TXLiteAVVideoView 属性并添加到父控件中

```
view.SetRenderMode(TRTCVideoFillMode.TRTCVideoFillMode_Fit);   // 设置显示的填充模式
view.Width = 320;    //宽高仅供参考，具体可根据实际业务设置
view.Height = 240;   //宽高仅供参考，具体可根据实际业务设置
this.videoContainer.Children.Add(view);         // 添加到父控件中
```

### 远端画面渲染

#### 步骤一：在 SDK 回调 onUserVideoAvailable(userId, true) 后开启远端画面接口，传入空窗口句柄

```
mTRTCCloud.startRemoteView(userId, IntPtr.Zero);
```

#### 步骤二：创建 TXLiteAVVideoView 并绑定 SDK 渲染回调

```
TXLiteAVVideoView view = new TXLiteAVVideoView();
view.RegEngine(userId, TRTCVideoStreamType.TRTCVideoStreamTypeBig, mTRTCCloud);
```

####  步骤三：设置 TXLiteAVVideoView 属性并添加到父控件中

```
view.SetRenderMode(TRTCVideoFillMode.TRTCVideoFillMode_Fit);   // 设置显示的填充模式
view.Width = 320;    //宽高仅供参考，具体可根据实际业务设置
view.Height = 240;   //宽高仅供参考，具体可根据实际业务设置
this.videoContainer.Children.Add(view);         // 添加到父控件中
```

> 本地辅流与远端辅流基本与上述步骤相同，都需要通过打开采集接口或开启远端画面接口才会有数据返回。

### 移除画面渲染

获取需要移除的 TXLiteAVVideoView 实例并取消与 SDK 内部的绑定和在父控件中移除。

```
TXLiteAVVideoView view = GetTXLiteAVVideoView(userId, streamType);
view.RemoveEngine(mTRTCCloud);
this.videoContainer.Children.Remove(view);
```

退出房间后取消所有绑定和回调监听。

```
foreach (var item in mVideoViews)
{
    if (item.Value != null)
    {
        item.Value.RemoveEngine(mTRTCCloud);
        this.videoContainer.Children.Remove(item.Value);
    }
}
TXLiteAVVideoView.RemoveAllRegEngine();
```
