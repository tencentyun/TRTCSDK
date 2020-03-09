package com.tencent.liteav.demo.trtc.sdkadapter;

import android.os.Bundle;

import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCStatistics;

import java.util.ArrayList;

/**
 * 封装了部分 TRTCCloudListener 的回调，这里使用接口的方式，可以让activity直接实现接口，方便使用
 *
 * @author guanyifeng
 */
public interface TRTCCloudManagerListener {
    /**
     * 加入房间回调
     *
     * @param elapsed 加入房间耗时，单位毫秒
     */
    void onEnterRoom(long elapsed);

    void onExitRoom(int reason);

    void onError(int errCode, String errMsg, Bundle extraInfo);

    /**
     * 有新的主播{@link TRTCCloudDef#TRTCRoleAnchor}加入了当前视频房间
     * 该方法会在主播加入房间的时候进行回调，此时音频数据会自动拉取下来，但是视频需要有 View 承载才会开始渲染。
     * 为了更好的交互体验，Demo 选择在 onUserVideoAvailable 中，申请 View 并且开始渲染。
     * 您可以根据实际需求，选择在 onUserEnter 还是 onUserVideoAvailable 中发起渲染。
     *
     * @param userId 用户标识
     */
    void onUserEnter(String userId);

    /**
     * 主播{@link TRTCCloudDef#TRTCRoleAnchor}离开了当前视频房间
     * 主播离开房间，要释放相关资源。
     * 1. 释放主画面、辅路画面
     * 2. 如果您有混流的需求，还需要重新发起混流，保证混流的布局是您所期待的。
     *
     * @param userId 用户标识
     * @param reason 离开原因代码，区分用户是正常离开，还是由于网络断线等原因离开。
     */
    void onUserExit(String userId, int reason);

    /**
     * 若当对应 userId 的主播有上行的视频流的时候，该方法会被回调，available 为 true；
     * 若对应的主播通过{@link TRTCCloud#muteLocalVideo(boolean)}，该方法也会被回调，available 为 false。
     * Demo 在收到主播有上行流的时候，会通过{@link TRTCCloud#startRemoteView(String, TXCloudVideoView)} 开始渲染
     * Demo 在收到主播停止上行的时候，会通过{@link TRTCCloud#stopRemoteView(String)} 停止渲染，并且更新相关 UI
     *
     * @param userId    用户标识
     * @param available 画面是否开启
     */
    void onUserVideoAvailable(String userId, boolean available);

    /**
     * 是否有辅路上行的回调，Demo 中处理方式和主画面的一致
     *
     * @param userId    用户标识
     * @param available 屏幕分享是否开启
     */
    void onUserSubStreamAvailable(String userId, boolean available);

    /**
     * 是否有音频上行的回调
     * <p>
     * 您可以根据您的项目要求，设置相关的 UI 逻辑，比如显示对端闭麦的图标等
     *
     * @param userId    用户标识
     * @param available true：音频可播放，false：音频被关闭
     */
    void onUserAudioAvailable(String userId, boolean available);

    /**
     * 视频首帧渲染回调
     * <p>
     * 一般客户可不关注，专业级客户质量统计等；您可以根据您的项目情况决定是否进行统计或实现其他功能。
     *
     * @param userId     用户 ID
     * @param streamType 视频流类型
     * @param width      画面宽度
     * @param height     画面高度
     */
    void onFirstVideoFrame(String userId, int streamType, int width, int height);

    /**
     * 音量大小回调
     * <p>
     * 您可以用来在 UI 上显示当前用户的声音大小，提高用户体验
     *
     * @param userVolumes 所有正在说话的房间成员的音量（取值范围0 - 100）。即 userVolumes 内仅包含音量不为0（正在说话）的用户音量信息。其中本地进房 userId 对应的音量，表示 local 的音量，也就是自己的音量。
     * @param totalVolume 所有远端成员的总音量, 取值范围 [0, 100]
     */
    void onUserVoiceVolume(ArrayList<TRTCCloudDef.TRTCVolumeInfo> userVolumes, int totalVolume);

    /**
     * SDK 状态数据回调
     * <p>
     * 一般客户无需关注，专业级客户可以用来进行统计相关的性能指标；您可以根据您的项目情况是否实现统计等功能
     *
     * @param statics 状态数据
     */
    void onStatistics(TRTCStatistics statics);

    /**
     * 跨房连麦会结果回调
     *
     * @param userID
     * @param err
     * @param errMsg
     */
    void onConnectOtherRoom(String userID, int err, String errMsg);

    /**
     * 断开跨房连麦结果回调
     *
     * @param err
     * @param errMsg
     */
    void onDisConnectOtherRoom(int err, String errMsg);

    /**
     * 网络行质量回调
     * <p>
     * 您可以用来在 UI 上显示当前用户的网络质量，提高用户体验
     *
     * @param localQuality  上行网络质量
     * @param remoteQuality 下行网络质量
     */
    void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality);

    /**
     * 音效播放回调
     *
     * @param effectId
     * @param code     0：表示播放正常结束；其他为异常结束，暂无异常值
     */
    void onAudioEffectFinished(int effectId, int code);

    void onRecvCustomCmdMsg(String userId, int cmdID, int seq, byte[] message);

    void onRecvSEIMsg(String userId, byte[] data);
}
