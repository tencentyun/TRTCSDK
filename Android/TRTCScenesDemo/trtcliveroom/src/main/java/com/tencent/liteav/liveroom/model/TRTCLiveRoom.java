package com.tencent.liteav.liveroom.model;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;

import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.liveroom.model.impl.TRTCLiveRoomImpl;
import com.tencent.rtmp.ui.TXCloudVideoView;

import java.util.List;

public abstract class TRTCLiveRoom {
    protected TRTCLiveRoom() {
    }

    /**
     * 获取 TRTCLiveRoom 单例对象
     *
     * @param context  Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return TRTCLiveRoom 实例
     *
     * @note 可以调用 {@link TRTCLiveRoom#destroySharedInstance()} 销毁单例对象
     */
    public static synchronized TRTCLiveRoom sharedInstance(Context context) {
        return TRTCLiveRoomImpl.sharedInstance(context);
    }

    /**
     * 销毁 TRTCLiveRoom 单例对象
     *
     * @note 销毁实例后，外部缓存的 TRTCLiveRoom 实例不能再使用，需要重新调用 {@link TRTCLiveRoom#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        TRTCLiveRoomImpl.destroySharedInstance();
    }

    /**
     * 设置组件回调接口
     *
     * 您可以通过 TRTCLiveRoomDelegate 获得 TRTCLiveRoom 的各种状态通知
     *
     * @param delegate 回调接口
     *
     * @note 默认是在 Main Thread 中回调，如果需要自定义回调线程，可使用 {@link TRTCLiveRoom#setDelegateHandler(Handler)}
     */
    public abstract void setDelegate(TRTCLiveRoomDelegate delegate);

    /**
     * 设置组件回调的线程
     *
     * @param handler 线程
     */
    public abstract void setDelegateHandler(Handler handler);

    /**
     * 登录到组件系统
     */
    public abstract void login(int sdkAppId, String userId, String userSign, TRTCLiveRoomDef.TRTCLiveRoomConfig config, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 设置用户信息
     * @param userName 用户昵称
     * @param avatarURL 用户头像
     * @param callback 设置结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 创建房间（主播调用）
     *
     * 主播开播的正常调用流程是：
     * 1.【主播】调用 startCameraPreview() 打开摄像头预览，此时可以调整美颜参数。
     * 2.【主播】调用 createRoom 创建直播间，房间创建成功与否会通过 ActionCallback 通知给主播。
     *
     * @param roomId 房间标识。
     * @param roomInfo 房间信息，用于房间描述的信息，比如房间名称，封面信息。
     * @param callback 创建房间的结果回调
     */
    public abstract void createRoom(int roomId, TRTCLiveRoomDef.TRTCCreateRoomParam roomInfo, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 销毁房间（主播调用）
     *
     * 主播在创建房间后，可以调用这个函数来销毁房间
     */
    public abstract void destroyRoom(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 进入房间（观众调用）
     *
     * 观众观看直播的正常调用流程是：
     * 1.【观众】通过业务后台拿到最新的直播房间列表。
     * 2.【观众】选择一个直播间以后，调用 enterRoom() 进入该房间。
     *
     * @param roomId 房间标识
     * @param callback 进入房间的结果回调
     */
    public abstract void enterRoom(int roomId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 退出房间
     *
     * @param callback 退出房间的结果回调
     */
    public abstract void exitRoom(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 获取房间列表的详细信息
     *
     * 通过业务后台拿到所有的房间号 roomIdList 后，调用该函数可以获取房间的详细信息
     *
     * @see {@link TRTCLiveRoomDef.TRTCLiveRoomInfo}
     *
     * @param roomIdList 房间号列表
     * @param callback 房间详细信息回调
     */
    public abstract void getRoomInfos(List<Integer> roomIdList, TRTCLiveRoomCallback.RoomInfoCallback callback);

    /**
     * 获取房间内所有的主播信息
     * @param callback 用户详细信息回调
     */
    public abstract void getAnchorList(TRTCLiveRoomCallback.UserListCallback callback);

    /**
     * 获取房间内所有的观众信息
     * @param callback 用户详细信息回调
     */
    public abstract void getAudienceList(TRTCLiveRoomCallback.UserListCallback callback);

    /**
     * 开启本地视频的预览画面
     *
     * @param isFront YES：前置摄像头；NO：后置摄像头。
     * @param view 承载视频画面的控件
     * @param callback 操作回调
     */
    public abstract void startCameraPreview(boolean isFront, TXCloudVideoView view, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止本地视频采集及预览
     */
    public abstract void stopCameraPreview();

    /**
     * 开始直播
     * 1. 主播开播的时候调用
     * 2. 观众连麦后调用
     * @param streamId 用户直播的id
     * @param callback 操作回调
     */
    public abstract void startPublish(String streamId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止直播
     * 1. 主播停止直播时调用
     * 2. 观众退麦时调用
     * @param callback 操作回调
     */
    public abstract void stopPublish(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 播放远端视频画面
     *
     * @param userId 对方的用户id
     * @param view 承载视频画面的控件
     * @param callback 操作回调
     *
     * @note 在 onAnchorEnter 回调时，调用这个接口
     */
    public abstract void startPlay(String userId, TXCloudVideoView view, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 停止播放远端视频画面
     *
     * @param userId 对方的用户信息
     * @param callback 操作回调
     *
     * @note 在 onAnchorExit 回调时，调用这个接口
     */
    public abstract void stopPlay(String userId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 观众请求连麦
     *
     * 主播和观众的连麦流程可以简单描述为如下几个步骤：
     * 1. 【观众】调用 requestJoinAnchor() 向主播发起连麦请求。
     * 2. 【主播】会收到 {@link TRTCLiveRoomDelegate#onRequestJoinAnchor} 的回调通知。
     * 3. 【主播】调用 responseJoinAnchor() 确定是否接受观众的连麦请求。
     * 4. 【观众】会收到 {@link TRTCLiveRoomCallback.ActionCallback} 回调通知，可以得知请求是否被同意。
     * 5. 【观众】如果请求被同意，则调用 startCameraPreview() 开启本地摄像头。
     * 6. 【观众】然后调用 startPublish() 正式进入推流状态。
     * 7. 【主播】一旦观众进入连麦状态，主播就会收到 {@link TRTCLiveRoomDelegate#onAnchorEnter)} 通知。
     * 8. 【主播】主播调用 startPlay() 就可以看到连麦观众的视频画面。
     * 9. 【观众】如果直播间里已经有其他观众正在跟主播进行连麦，那么新加入的这位连麦观众也会收到 onAnchorEnter() 通知，用于展示（startPlay）其他连麦者的视频画面。
     *
     * @param reason 连麦原因
     * @param callback 请求连麦的回调
     *
     * @see {@link TRTCLiveRoomDelegate#onRequestJoinAnchor}
     */
    public abstract void requestJoinAnchor(String reason, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 主播处理连麦请求
     *
     * 主播在收到 {@link TRTCLiveRoomDelegate#onRequestJoinAnchor} 回调之后会需要调用此接口来处理观众的连麦请求。
     *
     * @param userId 观众 ID
     * @param agree true：同意；false：拒绝
     * @param reason 同意/拒绝连麦的原因描述
     */
    public abstract void responseJoinAnchor(String userId, boolean agree, String reason);

    /**
     * 主播踢除连麦观众
     *
     * 主播调用此接口踢除连麦观众后，被踢连麦观众会收到 {@link TRTCLiveRoomDelegate#onKickoutJoinAnchor()} 回调通知
     *
     * @param userId 连麦观众 ID
     *
     * @see {@link TRTCLiveRoomDelegate#onKickoutJoinAnchor()}
     */
    public abstract void kickoutJoinAnchor(String userId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 请求跨房 PK
     *
     * 主播和主播之间可以跨房间 PK，两个正在直播中的主播 A 和 B，他们之间的跨房 PK 流程如下：
     * 1. 【主播 A】调用 requestRoomPK() 向主播 B 发起连麦请求。
     * 2. 【主播 B】会收到 {@link TRTCLiveRoomDelegate#onRequestRoomPK} 回调通知。
     * 3. 【主播 B】调用 responseRoomPK() 确定是否接受主播 A 的 PK 请求。
     * 4. 【主播 B】如果接受了主播 A 的要求，等待 {@link TRTCLiveRoomDelegate#onAnchorEnter)} 通知，然后调用 startPlay() 来显示主播 A 的视频画面。
     * 5. 【主播 A】会收到 {@link TRTCLiveRoomCallback.ActionCallback} 回调通知，可以得知请求是否被同意。
     * 6. 【主播 A】如果请求被同意，等待 {@link TRTCLiveRoomDelegate#onAnchorEnter)} 通知，然后调用 startPlay() 来显示主播 B 的视频画面
     *
     * @param roomId 被邀约房间 ID
     * @param userId 被邀约主播 ID
     * @param callback 请求跨房 PK 的结果回调
     *
     * @see {@link TRTCLiveRoomDelegate#onRequestRoomPK}
     */
    public abstract void requestRoomPK(int roomId, String userId, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 响应跨房 PK 请求
     *
     * 主播响应其他房间主播的 PK 请求。
     *
     * @param userId 发起 PK 请求的主播 ID
     * @param agree true：同意；false：拒绝
     * @param reason 同意/拒绝 PK 的原因描述
     */
    public abstract void responseRoomPK(String userId, boolean agree, String reason);

    /**
     * 退出跨房 PK
     *
     * 当两个主播中的任何一个退出跨房 PK 状态后，另一个主播会收到 {@link TRTCLiveRoomDelegate#onQuitRoomPK} 回调通知。
     *
     * @param callback 退出跨房 PK 的结果回调
     */
    public abstract void quitRoomPK(TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 切换前后摄像头
     */
    public abstract void switchCamera();

    /**
     * 设置是否镜像展示
     */
    public abstract void setMirror(boolean isMirror);

    /**
     * 静音本地音频
     */
    public abstract void muteLocalAudio(boolean mute);

    /**
     * 静音远端音频
     */
    public abstract void muteRemoteAudio(String userId, boolean mute);

    /**
     * 静音所有远端音频
     */
    public abstract void muteAllRemoteAudio(boolean mute);

    /**
     * 发送文本消息
     *
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomTextMsg(String message, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 发送自定义文本消息
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, TRTCLiveRoomCallback.ActionCallback callback);

    /**
     * 是否在界面中展示debug信息
     */
    public abstract void showVideoDebugLog(boolean isShow);

    /**
     * BGM控制相关
     */
    public abstract TRTCBGMManager getBGMManger();

    /**
     * 美颜相关
     */
    public abstract TXBeautyManager getBeautyManager();

    /**
     * 设置指定素材滤镜特效
     *
     * @param image 指定素材，即颜色查找表图片。**必须使用 png 格式**
     */
    public abstract void setFilter(Bitmap image);

    /**
     * 设置滤镜浓度
     * <p>
     * 在美女秀场等应用场景里，滤镜浓度的要求会比较高，以便更加突显主播的差异。
     * 我们默认的滤镜浓度是0.5，如果您觉得滤镜效果不明显，可以使用下面的接口进行调节。
     *
     * @param concentration 从0到1，越大滤镜效果越明显，默认值为0.5。
     */
    public abstract void setFilterConcentration(float concentration);

    /**
     * 设置绿幕背景视频（企业版有效，其它版本设置此参数无效）
     * <p>
     * 此处的绿幕功能并非智能抠背，它需要被拍摄者的背后有一块绿色的幕布来辅助产生特效
     *
     * @param file 视频文件路径。支持 MP4；null：表示关闭特效。
     */
    @TargetApi(18)
    public abstract void setGreenScreenFile(String file);
}
