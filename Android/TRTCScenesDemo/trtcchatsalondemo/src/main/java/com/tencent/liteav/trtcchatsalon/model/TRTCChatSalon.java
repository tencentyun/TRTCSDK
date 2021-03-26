package com.tencent.liteav.trtcchatsalon.model;

import android.content.Context;
import android.os.Handler;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.trtcchatsalon.model.impl.TRTCChatSalonImpl;

import java.util.List;

public abstract class TRTCChatSalon {

    /**
     * 获取 TRTCChatSalon 单例对象
     *
     * @param context Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
     * @return TRTCChatSalon 实例
     * @note 可以调用 {@link TRTCChatSalon#destroySharedInstance()} 销毁单例对象
     */
    public static synchronized TRTCChatSalon sharedInstance(Context context) {
        return TRTCChatSalonImpl.sharedInstance(context);
    }

    /**
     * 销毁 TRTCChatSalon 单例对象
     *
     * @note 销毁实例后，外部缓存的 TRTCChatSalon 实例不能再使用，需要重新调用 {@link TRTCChatSalon#sharedInstance(Context)} 获取新实例
     */
    public static void destroySharedInstance() {
        TRTCChatSalonImpl.destroySharedInstance();
    }

    //////////////////////////////////////////////////////////
    //
    //                 基础接口
    //
    //////////////////////////////////////////////////////////
    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 TRTCChatSalonDelegate 获得 TRTCChatSalon 的各种状态通知
     *
     * @param delegate 回调接口
     * @note TRTCChatSalon 中的事件，默认是在 Main Thread 中回调给您；如果您需要指定事件回调所在的线程，可使用 {@link TRTCChatSalon#setDelegateHandler(Handler)}
     */
    public abstract void setDelegate(TRTCChatSalonDelegate delegate);

    /**
     * 设置事件回调所在的线程
     *
     * @param handler 线程，TRTCChatSalon 中的各种状态通知，会派发到您指定的 handler 线程。
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
    public abstract void login(int sdkAppId, String userId, String userSig, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 退出登录
     */
    public abstract void logout(TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
     *
     * @param userName 用户昵称
     * @param avatarURL 用户头像
     * @param callback 是否设置成功的结果回调
     */
    public abstract void setSelfProfile(String userName, String avatarURL, TRTCChatSalonCallback.ActionCallback callback);

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
     * 3. 主播还会收到麦位表有成员进入的`onAnchorEnterSeat`的事件通知，此时会自动打开麦克风采集。
     *
     * @param roomId 房间标识，需要由您分配并进行统一管理。
     * @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
     * @param callback 创建房间的结果回调，成功时 code 为0.
     */
    public abstract void createRoom(int roomId, TRTCChatSalonDef.RoomParam roomParam, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 销毁房间（主播调用）
     *
     * 主播在创建房间后，可以调用这个函数来销毁房间。
     */
    public abstract void destroyRoom(TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 进入房间（观众调用）
     *
     * 观众进房收听的正常调用流程如下：
     * 1.【观众】向您的服务端获取最新的语音聊天室列表，可能包含多个直播间的 roomId 和房间信息。
     * 2. 观众选择一个语音聊天室，调用`enterRoom`并传入房间号即可进入该房间。
     * 3. 进房后会收到组件的`onRoomInfoChange`房间属性变化事件通知，此时可以记录房间属性并做相应改变，例如 UI 展示房间名、记录上麦是否需要请求主播同意等。
     * 4. 进房后还会收到麦位表有主播进入的`onAnchorEnterSeat`的事件通知。
     *
     * @param roomId 房间标识
     * @param callback 进入房间是否成功的结果回调
     */
    public abstract void enterRoom(int roomId, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 退出房间
     *
     * @param callback 退出房间是否成功的结果回调
     */
    public abstract void exitRoom(TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 获取房间列表的详细信息
     *
     * 其中的信息是主播在创建 createRoom() 时通过 roomParam 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
     *
     * @param roomIdList 房间号列表
     * @param callback 房间详细信息回调
     */
    public abstract void getRoomInfoList(List<Integer> roomIdList, TRTCChatSalonCallback.RoomInfoCallback callback);

    /**
     * 获取指定userId的用户信息，如果为null，则获取房间内所有人的信息
     * @param userListCallback 用户详细信息回调
     */
    public abstract void getUserInfoList(List<String> userIdList, TRTCChatSalonCallback.UserListCallback userListCallback);

    //////////////////////////////////////////////////////////
    //
    //                 麦位管理接口
    //
    //////////////////////////////////////////////////////////

    /**
     * 主动上麦（观众端和主播均可调用）
     *
     * @param callback 操作回调
     */
    public abstract void enterSeat(TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 主动下麦（观众端和主播均可调用）
     *
     * @param callback 操作回调
     */
    public abstract void leaveSeat(TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 抱人上麦(主播调用)
     *
     * 主播抱人上麦，房间内所有成员会收到`onAnchorEnterSeat`的事件通知。
     *
     * @param userId  用户id
     * @param callback 操作回调
     */
    public abstract void pickSeat(String userId, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 踢人下麦(主播调用)
     *
     * 主播踢人下麦，房间内所有成员会收到onAnchorLeaveSeat`的事件通知。
     *
     * @param userId 需要踢下麦的用户id
     * @param callback 操作回调
     */
    public abstract void kickSeat(String userId, TRTCChatSalonCallback.ActionCallback callback);

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
    public abstract void sendRoomTextMsg(String message, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
     *
     * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
     * @param message 文本消息
     * @param callback 发送结果回调
     */
    public abstract void sendRoomCustomMsg(String cmd, String message, TRTCChatSalonCallback.ActionCallback callback);

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
    public abstract String sendInvitation(String cmd, String userId, String content, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 接受邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void acceptInvitation(String id, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 拒绝邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void rejectInvitation(String id, TRTCChatSalonCallback.ActionCallback callback);

    /**
     * 取消邀请
     * @param id 邀请ID
     * @param callback 接受操作的回调
     */
    public abstract void cancelInvitation(String id, TRTCChatSalonCallback.ActionCallback callback);
}