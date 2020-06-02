//
//  TCAnchorViewController+LiveDelegate.swift
//  trtcScenesDemo
//
//  Created by 刘智民 on 2020/3/3.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

let maxLinkMicCount = 3

extension TCAnchorViewController: TRTCLiveRoomDelegate {
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onError code: Int, message: String?) {
        
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomTextMsg message: String, fromUser user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = TCMsgModelType.normalMsg.rawValue
        logicView.handleIMMessage(info, msgText: message)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomCustomMsg command: String, message: String, fromUser user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = Int(command) ?? 0
        logicView.handleIMMessage(info, msgText: message)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorEnter userID: String) {
         onAnchorEnter(userID)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorExit userID: String) {
        onAnchorExit(userID)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRequestJoinAnchor user: TRTCLiveUserInfo, reason: String?, timeout: Double) {
        //linkMic
        onRequestJoinAnchor(user, reason: reason, timeout: timeout)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRequestRoomPK user: TRTCLiveUserInfo, timeout: Double) {
        //PK
        onRequestRoomPK(user, timeout: timeout)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceEnter user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = 2
        logicView.handleIMMessage(info, msgText: "")
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceExit user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = 3
        logicView.handleIMMessage(info, msgText: "")
    }
    
    public func trtcLiveRoomOnQuitRoomPK(_ trtcLiveRoom: TRTCLiveRoomImpl) {
        self.curPkRoom = nil
        TCUtil.toastTip("对方主播已结束PK", parentView: view)
        linkFrameRestore()
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRoomInfoChange info: TRTCLiveRoomInfo) {
        self.roomStatus = info.roomStatus.rawValue
        if info.roomStatus == .single || info.roomStatus == .linkMic {
            self.curPkRoom = nil
            UIView.animate(withDuration: 0.1) {
                self.videoParentView.frame = self.view.frame
                self.linkFrameRestore()
            }
        } else if info.roomStatus == .roomPK {
             UIView.animate(withDuration: 0.1) {
                self.videoParentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2, height: self.view.frame.size.height / 2)
                self.switchPKMode()
            }
        }
    }
}
