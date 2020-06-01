//
//  TRTCOnlineCall+room.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/24/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

extension TRTCVideoCall: TRTCCloudDelegate {
    
    func enterRoom() {
        //开启美颜
        let beauty = TRTCCloud.sharedInstance()?.getBeautyManager()
        //自然美颜
        beauty?.setBeautyStyle(.nature)
        beauty?.setBeautyLevel(6)
        
        let param = TRTCParams()
        param.sdkAppId = UInt32(SDKAPPID)
        param.userId = VideoCallUtils.shared.curUserId()
        param.roomId = curRoomID
        param.userSig = GenerateTestUserSig.genTestUserSig(param.userId)
        param.privateMapKey = ""
        
        //编码设置
        let videoEncParam = TRTCVideoEncParam()
        videoEncParam.videoResolution = ._960_540
        videoEncParam.videoFps = 15
        videoEncParam.videoBitrate = 1000
        videoEncParam.resMode = .portrait
        videoEncParam.enableAdjustRes = true
        TRTCCloud.sharedInstance()?.setVideoEncoderParam(videoEncParam)
        
        TRTCCloud.sharedInstance().delegate = self
        TRTCCloud.sharedInstance()?.setAudioQuality(.speech)
        TRTCCloud.sharedInstance().enterRoom(param, appScene: (.videoCall))
        TRTCCloud.sharedInstance()?.startLocalAudio()
        TRTCCloud.sharedInstance()?.enableAudioVolumeEvaluation(300)
        isMicMute = false
        isHandsFreeOn = true
        isInRoom = true
    }
    
    func quitRoom() {
        TRTCCloud.sharedInstance()?.stopLocalAudio()
        TRTCCloud.sharedInstance()?.stopLocalPreview()
        TRTCCloud.sharedInstance()?.exitRoom()
        isMicMute = false
        isHandsFreeOn = true
        isInRoom = false
    }
    
    public func onEnterRoom(_ result: Int) {
        if result < 0 {
            curLastModel.code = result
            if let del = delegate {
                del.onCallEnd?()
            }
            hangup()
        }
    }
    
    public func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        curLastModel.code = Int(errCode.rawValue)
        if let del = delegate {
            del.onCallEnd?()
        }
        hangup()
    }
    
    public func onRemoteUserEnterRoom(_ userId: String) {
        curInvitingList = curInvitingList.filter {
            $0 != userId
        }
        if !curRoomList.contains(userId) {
            curRoomList.append(userId)
        }
        if let del = delegate {
            del.onUserEnter?(uid: userId)
        }
    }
    
    public func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        curInvitingList = curInvitingList.filter {
            $0 != userId
        }
        curRoomList = curRoomList.filter {
            $0 != userId
        }
        if let del = delegate {
            del.onUserLeave?(uid: userId)
        }
        checkAutoHangUp()
    }
    
    public func onUserAudioAvailable(_ userId: String, available: Bool) {
       if let del = delegate {
            del.onUserAudioAvailable?(uid: userId, available: available)
        }
    }
    
    public func onUserVideoAvailable(_ userId: String, available: Bool) {
        if let del = delegate {
            del.onUserVideoAvailable?(uid: userId, available: available)
        }
    }
    
    public func onUserVoiceVolume(_ userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        if let del = delegate {
            for info in userVolumes {
                if let userId = info.userId {
                    del.onUserVoiceVolume?(uid: userId, volume: UInt32(info.volume))
                } else {
                    del.onUserVoiceVolume?(uid: VideoCallUtils.shared.curUserId(), volume: UInt32(info.volume))
                }
            }
        }
    }
}
