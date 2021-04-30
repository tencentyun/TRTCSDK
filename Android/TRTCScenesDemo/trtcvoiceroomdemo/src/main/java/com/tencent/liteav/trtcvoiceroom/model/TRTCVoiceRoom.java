package com.tencent.liteav.trtcvoiceroom.model;

import android.content.Context;
import android.os.Handler;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.trtcvoiceroom.model.impl.TRTCVoiceRoomImpl;

import java.util.List;

public abstract class TRTCVoiceRoom {

    /**
     * 获取 TRTCVoiceRoom 单例对象
     *
     * @param context Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return TRTCVoiceRoom 实例
     * @note 可以调用 {@link TRTCVoiceRoom#destroySharedInstance()} 销毁单例对象
     */
    public static synchronized TRTCVoiceRoom sharedInstance(Context context) {
        return TRTCVoiceRoomImpl.sharedInstance(context);
    }

    /**
     * 销毁 TRTCVoiceRoom 单例对象
     *
     * @note 销毁实例后，外部缓存的 TRTCVoiceRoom 实例不能再使用，需要重新调用 {@link TRTCVoiceRoom#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        TRTCVoiceRoomImpl.destroySharedInstance();
    }

    //////////////////////////////////////////////////////////
    //
    //                 基础接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 TRTCVoiceRoomDelegate 获得 TRTCVoiceRoom 的各种状态通知
     *
     * @param delegate 回调接口
     * @note TRTCVoiceRoom 中的事件，默认是在 Main Thread 中回调给您；如果您需要指定事件回调所在的线程，可使用 {@link TRTCVoiceRoom#setDelegateHandler(Handler)}
     */
    public abstract void setDelegate(TRTCVoiceRoomDelegate delegate);

    /**
     * 设置事件回调所在的线程
     *
     * @param handler 线程，TRTCVoiceRoom 中的各种状态通知，会派发到您指定的 handler 线程。
     */
    public abstract void setDelegateHandler(Handler handler);

    /**
     * 登录
     *
     * @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
     * @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
     * @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
     * @param callback 登录回调，成功时 code 为0
     */
    public abstract void login(int sdkAppId, String userId, String userSig, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout(TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
     *
     * @param userName 用户昵称
     * @param avatarURL 用户头像
     * @param callback 是否设置成功的结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCVoiceRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                 房间管理接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 创建房间（主播调用）
     *
     * 主播正常的调用流程是：
     * 1. 主播调用`createRoom`创建新的语音聊天室，此时传入房间 ID、上麦是否需要房主确认、麦位数等房间属性信息。
     * 2. 主播创建房间成功后，调用`enterSeat`进入座位。
     * 3. 主播收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
     * 4. 主播还会收到麦位表有成员进入的`onAnchorEnterSeat`的事件通知，此时会自动打开麦克风采集。
     *
     * @param roomId 房间标识，需要由您分配并进行统一管理。
     * @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
     * @param callback 创建房间的结果回调，成功时 code 为0.
     */
    public abstract void createRoom(int roomId, TRTCVoiceRoomDef.RoomParam roomParam, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 销毁房间（主播调用）
     *
     * 主播在创建房间后，可以调用这个函数来销毁房间。
     */
    public abstract void destroyRoom(TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 进入房间（观众调用）
     *
     * 观众进房收听的正常调用流程如下：
     * 1.【观众】向您的服务端获取最新的语音聊天室列表，可能包含多个直播间的 roomId 和房间信息。
     * 2. 观众选择一个语音聊天室，调用`enterRoom`并传入房间号即可进入该房间。
     * 3. 进房后会收到组件的`onRoomInfoChange`房间属性变化事件通知，此时可以记录房间属性并做相应改变，例如 UI 展示房间名、记录上麦是否需要请求主播同意等。
     * 4. 进房后会收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
     * 5. 进房后还会收到麦位表有主播进入的`onAnchorEnterSeat`的事件通知。
     *
     * @param roomId 房间标识
     * @param callback 进入房间是否成功的结果回调
     */
    public abstract void enterRoom(int roomId, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 退出房间
     *
     * @param callback 退出房间是否成功的结果回调
     */
    public abstract void exitRoom(TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 获取房间列表的详细信息
     *
     * 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
     *
     * @param roomIdList 房间号列表
     * @param callback 房间详细信息回调
     */
    public abstract void getRoomInfoList(List<Integer> roomIdList, TRTCVoiceRoomCallback.RoomInfoCallback callback);

    /**
     * 获取指定userId的用户信息，如果为null，则获取房间内所有人的信息
     * @param userlistcallback 用户详细信息回调
     */
    public abstract void getUserInfoList(List<String> userIdList, TRTCVoiceRoomCallback.UserListCallback userlistcallback);

    //////////////////////////////////////////////////////////
    //
    //                 麦位管理接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 主动上麦（观众端和主播均可调用）
     *
     * 上麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorEnterSeat`的事件通知。
     *
     * @param seatIndex 需要上麦的麦位序号
     * @param callback 操作回调
     */
    public abstract void enterSeat(int seatIndex, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 主动下麦（观众端和主播均可调用）
     *
     * 下麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
     *
     * @param callback 操作回调
     */
    public abstract void leaveSeat(TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 抱人上麦(主播调用)
     *
     * 主播抱人上麦，房间内所有成员会收到`onSeatListChange`和`onAnchorEnterSeat`的事件通知。
     *
     * @param seatIndex 需要抱麦的麦位序号
     * @param userId  用户id
     * @param callback 操作回调
     */
    public abstract void pickSeat(int seatIndex, String userId, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 踢人下麦(主播调用)
     *
     * 主播踢人下麦，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
     *
     * @param seatIndex 需要踢下麦的麦位序号
     * @param callback 操作回调
     */
    public abstract void kickSeat(int seatIndex, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 静音/解禁对应麦位的麦克风(主播调用)
     *
     * 房间内所有成员会收到`onSeatListChange`和`onSeatMute`的事件通知。
     * 对应 seatIndex 座位上的主播，会自动调用 muteAudio 进行静音/解禁
     *
     * @param seatIndex 麦位序号
     * @param isMute   true:静音 fasle:解除静音
     * @param callback 操作回调
     */
    public abstract void muteSeat(int seatIndex, boolean isMute, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 封禁/解禁某个麦位(主播调用)
     *
     * 房间内所有成员会收到`onSeatListChange`和`onSeatClose`的事件通知。
     *
     * @param seatIndex 麦位序号
     * @param isClose   true:封禁 fasle:解除封禁
     * @param callback 操作回调
     */
    public abstract void closeSeat(int seatIndex, boolean isClose, TRTCVoiceRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                 本地音频操作接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 开启麦克风采集
     */
    public abstract void startMicrophone();

    /**
     * 停止麦克风采集
     */
    public abstract void stopMicrophone();

    /**
     * 开启/关闭 耳返
     * @param enable 开启/关闭
     */
    public abstract void setVoiceEarMonitorEnable(boolean enable);

    /**
     * 设置音质
     * @param quality TRTC_AUDIO_QUALITY_MUSIC/TRTC_AUDIO_QUALITY_DEFAULT/TRTC_AUDIO_QUALITY_SPEECH
     */
    public abstract void setAudioQuality(int quality);

    /**
     * 开启本地静音
     * @param mute 是否静音
     */
    public abstract void muteLocalAudio(boolean mute);

    /**
     * 设置开启扬声器
     * @param useSpeaker true:扬声器 false:听筒
     */
    public abstract void setSpeaker(boolean useSpeaker);

    /**
     * 设置麦克风采集音量
     * @param volume 采集音量 0-100
     */
    public abstract void setAudioCaptureVolume(int volume);

    /**
     * 设置播放音量
     * @param volume 播放音量 0-100
     */
    public abstract void setAudioPlayoutVolume(int volume);

    //////////////////////////////////////////////////////////
    //
    //                 远端用户接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 静音某一个用户的声音
     *
     * @param userId 用户id
     * @param mute true:静音 false：解除静音
     */
    public abstract void muteRemoteAudio(String userId, boolean mute);

    /**
     * 静音所有用户的声音
     *
     * @param mute true:静音 false：解除静音
     */
    public abstract void muteAllRemoteAudio(boolean mute);

    /**
     * 音效控制相关
     */
    public abstract TXAudioEffectManager getAudioEffectManager();

    //////////////////////////////////////////////////////////
    //
    //                 消息发送接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 在房间中广播文本消息，一般用于弹幕聊天
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomTextMsg(String message, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, TRTCVoiceRoomCallback.ActionCallback callback);

    //////////////////////////////////////////////////////////
    //
    //                 邀请信令消息
    //
    //////////////////////////////////////////////////////////
    /**
     * 向用户发送邀请
     *
     * @param cmd 业务自定义指令
     * @param userId 邀请的用户ID
     * @param content 邀请的内容
     * @param callback 发送结果回调
     * @return inviteId 用于标识此次邀请ID
     */
    public abstract String sendInvitation(String cmd, String userId, String content, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 接受邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void acceptInvitation(String id, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 拒绝邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void rejectInvitation(String id, TRTCVoiceRoomCallback.ActionCallback callback);

    /**
     * 取消邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void cancelInvitation(String id, TRTCVoiceRoomCallback.ActionCallback callback);
}
