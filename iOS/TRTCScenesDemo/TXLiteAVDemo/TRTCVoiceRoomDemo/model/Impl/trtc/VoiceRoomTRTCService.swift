//
//  VoiceRoomTRTCService.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/11.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

public protocol VoiceRoomTRTCServiceDelegate: class {
    func onTRTCAnchorEnter(userId: String)
    func onTRTCAnchorExit(userId: String)
    func onTRTCAudioAvailable(userId: String, available: Bool)
    func onError(errorCode: Int, message: String)
    func onNetWorkQuality(trtcQuality: TRTCQualityInfo, arrayList: [TRTCQualityInfo])
    func onUserVoiceVolume(userVolumes: [TRTCVolumeInfo], totalVolume: Int)
}

public class VoiceRoomTRTCService: NSObject {
    static let PLAY_TIME_OUT: Int = 5000
    
    private static let instance = VoiceRoomTRTCService.init()
    private override init() {}
    
    public static func getInstance() -> VoiceRoomTRTCService {
        return VoiceRoomTRTCService.instance
    }
    
    private var mTRTCCloud: TRTCCloud {
        return TRTCCloud.sharedInstance()
    }
    
    private var isInRoom: Bool = false
    private weak var delegate: VoiceRoomTRTCServiceDelegate?
    
    private var userId: String = ""
    private var roomId: String = ""
    private var mTRTCParms: TRTCParams?
    private var enterRoomCallback: TXCallback?
    private var exitRoomCallback: TXCallback?
    
    public func setDelegate(_ delegate: VoiceRoomTRTCServiceDelegate) {
        self.delegate = delegate
    }
    
    public func enterRoom(sdkAppId: Int32, roomId: String, userId: String, userSign: String, role: Int, callback: TXCallback?) {
        guard sdkAppId != 0 && roomId != "" && userId != "" && userSign != "" else {
            TRTCLog.out("error: enter trtc room fail. params invalid. room id:\(roomId), userId:\(userId), userSig is empty: \(userSign == "")")
            callback?(-1, "enter trtc room fail.")
            return
        }
        guard let roomIdIntValue = UInt32.init(roomId) else {
            TRTCLog.out("error: enter trtc room fail. params invalid. room id:\(roomId))")
            callback?(-1, "enter trtc room fail.")
            return
        }
        self.userId = userId
        self.roomId = roomId
        self.enterRoomCallback = callback
        TRTCLog.out("enter room. app id :\(sdkAppId). room id: \(roomId), userID: \(userId)")
        let trtcParams = TRTCParams.init()
        trtcParams.sdkAppId = UInt32(sdkAppId)
        trtcParams.userId = userId
        trtcParams.userSig = userSign
        trtcParams.role = TRTCRoleType.init(rawValue: role) ?? TRTCRoleType.audience
        trtcParams.roomId = roomIdIntValue
        mTRTCParms = trtcParams
        internalEnterRoom()
    }
    
    public func exitRoom(callback: TXCallback?) {
        TRTCLog.out("exit room.")
        userId = ""
        mTRTCParms = nil
        enterRoomCallback = nil
        exitRoomCallback = callback
        mTRTCCloud.exitRoom()
    }
    
    public func muteLocalAudio(isMute: Bool) {
        TRTCLog.out("mute local audio, mute: \(isMute)")
        mTRTCCloud.muteLocalAudio(isMute)
    }
    
    public func muteRemoteAudio(userId: String, mute: Bool) {
        TRTCLog.out("mute remote audio, user id: \(userId), mute: \(mute)")
        mTRTCCloud.muteRemoteAudio(userId, mute: mute)
    }
    
    public func muteAllRemoteAudio(isMute: Bool) {
        TRTCLog.out("mute all remote audio, mute:\(isMute)")
        mTRTCCloud.muteAllRemoteAudio(isMute)
    }
    
    public func setAuidoQuality(quality: Int) {
        mTRTCCloud.setAudioQuality(TRTCAudioQuality(rawValue: quality) ?? TRTCAudioQuality.default)
    }
    
    public func startMicrophone() {
        mTRTCCloud.startLocalAudio()
    }
    
    public func stopMicrophone() {
        mTRTCCloud.stopLocalAudio()
    }
    
    public func switchToAnchor() {
        mTRTCCloud.switch(TRTCRoleType.anchor)
        mTRTCCloud.startLocalAudio()
    }
    
    public func switchToAudience() {
        mTRTCCloud.stopLocalAudio()
        mTRTCCloud.switch(TRTCRoleType.audience)
    }
    
    public func setSpeaker(useSpeaker: Bool) {
        mTRTCCloud.setAudioRoute(useSpeaker ? .modeSpeakerphone : .modeEarpiece)
    }
    
    public func setAudioCaptureVolume(volume: Int) {
        mTRTCCloud.setAudioCaptureVolume(volume)
    }
    
    public func setAudioPlayoutVolume(volume: Int) {
        mTRTCCloud.setAudioPlayoutVolume(volume)
    }
    
    public func startFileDumping(trtcAudioRecordingParams: TRTCAudioRecordingParams) {
        mTRTCCloud.startAudioRecording(trtcAudioRecordingParams)
    }
    
    public func stopFileDumping() {
        mTRTCCloud.stopAudioRecording()
    }
    
    public func enableAudioEvalutaion(enable: Bool) {
        mTRTCCloud.enableAudioVolumeEvaluation(enable ? 300 : 0)
    }
    
    
}

extension VoiceRoomTRTCService {
    private func internalEnterRoom() {
        guard let parms = mTRTCParms else { return }
        mTRTCCloud.delegate = self
        mTRTCCloud.enterRoom(parms, appScene: TRTCAppScene.voiceChatRoom)
    }
}

extension VoiceRoomTRTCService: TRTCCloudDelegate {
    public func onEnterRoom(_ result: Int) {
        TRTCLog.out("on enter room. result: \(result)")
        if result > 0 {
            isInRoom = true
            enterRoomCallback?(0, "enter room success")
        } else {
            isInRoom = false
            enterRoomCallback?(Int32(result), "enter room fail")
        }
        enterRoomCallback = nil
    }
    
    public func onExitRoom(_ reason: Int) {
        TRTCLog.out("on exit room. result: \(reason)")
        isInRoom = false
        exitRoomCallback?(0, "exit room success")
        exitRoomCallback = nil
    }
    
    public func onRemoteUserEnterRoom(_ userId: String) {
        TRTCLog.out("on user enter, user id: \(userId)")
        delegate?.onTRTCAnchorEnter(userId: userId)
    }
    
    public func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        TRTCLog.out("on user exit. id: \(userId)")
        delegate?.onTRTCAnchorExit(userId: userId)
    }
    
    public func onUserAudioAvailable(_ userId: String, available: Bool) {
        TRTCLog.out("on user audio available, usr id: \(userId), available:\(available)")
        delegate?.onTRTCAudioAvailable(userId: userId, available: available)
    }
    
    public func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        TRTCLog.out("on error: \(String(describing: errMsg)), code: \(errCode)")
        delegate?.onError(errorCode: Int(errCode.rawValue), message: errMsg ?? "")
    }
    
    public func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        delegate?.onNetWorkQuality(trtcQuality: localQuality, arrayList: remoteQuality)
    }
    
    public func onUserVoiceVolume(_ userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        delegate?.onUserVoiceVolume(userVolumes: userVolumes, totalVolume: totalVolume)
    }
    
    public func onSetMixTranscodingConfig(_ err: Int32, errMsg: String) {
        TRTCLog.out("on set mix transcoding, code: \(err), msg:\(errMsg)")
    }
    
}
