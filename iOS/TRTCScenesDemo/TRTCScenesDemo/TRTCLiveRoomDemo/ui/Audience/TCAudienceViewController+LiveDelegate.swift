//
//  TCAudienceViewController+LiveDelegate.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 3/9/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

extension TCAudienceViewController: TRTCLiveRoomDelegate {
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onError code: Int, message: String?) {
        
    }
    
    @objc public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomTextMsg message: String, fromUser user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = TCMsgModelType.normalMsg.rawValue
        logicView.handleIMMessage(info, msgText: message)
    }
    
    @objc public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRecvRoomCustomMsg command: String, message: String, fromUser user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = Int(command) ?? 0
        logicView.handleIMMessage(info, msgText: message)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorEnter userID: String) {
        if userID == liveInfo.ownerId {
            isOwnerEnter = true
            liveRoom.startPlay(userID: userID, view: videoParentView) { (code, error) in
                
            }
        } else {
            onAnchorEnter(userID)
        }
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAnchorLeave userID: String) {
        onAnchorExit(userID)
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceEnter user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = 2
        logicView.handleIMMessage(info, msgText: "")
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onAudienceLeave user: TRTCLiveUserInfo) {
        let info = IMUserAble()
        info.imUserId = user.userId
        info.imUserName = user.userName
        info.imUserIconUrl = user.avatarURL
        info.cmdType = 3
        logicView.handleIMMessage(info, msgText: "")
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRoomInfoChange info: TRTCLiveRoomInfo) {
        let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
        if isCdnMode {
            return
        }
        self.roomType = info.type.rawValue
        if info.type == .single || info.type == .linkMic {
            UIView.animate(withDuration: 0.1) {
                self.videoParentView.frame = self.view.frame
                self.linkFrameRestore()
            }
        } else if info.type == .roomPK {
             UIView.animate(withDuration: 0.1) {
                self.videoParentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2, height: self.view.frame.size.height / 2)
                self.switchPKMode()
            }
        }
    }
    
    public func trtcLiveRoomOnKickoutJoinAnchor(_ trtcLiveRoom: TRTCLiveRoomImpl) {
        onKickoutJoinAnchor()
    }
    
    public func trtcLiveRoom(_ trtcLiveRoom: TRTCLiveRoomImpl, onRoomDestroy roomID: String) {
        onLiveEnd()
    }
}
