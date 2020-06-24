//
//  ITXRoomServiceDelegate.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/9.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

public protocol ITXRoomServiceDelegate: class {
    func onRoomDestroy(roomID: String)
    func onRoomRecvRoomTextMsg(roomID: String, message: String, userInfo: TXUserInfo)
    func onRoomRecvRoomCustomMsg(roomID: String, cmd: String, message: String, userInfo: TXUserInfo)
    func onRoomInfoChange(roomInfo: TXRoomInfo)
    func onSeatInfoListChange(seatInfoList: [TXSeatInfo])
    func onRoomAudienceEnter(userInfo: TXUserInfo)
    func onRoomAudienceLeave(userInfo: TXUserInfo)
    func onSeatTake(index: Int, userInfo: TXUserInfo)
    func onSeatClose(index: Int, isClose: Bool)
    func onSeatLeave(index: Int, userInfo: TXUserInfo)
    func onSeatMute(index: Int, mute: Bool)
    func onReceiveNewInvitation(identifier: String, inviter: String, cmd: String, content: String)
    func onInviteeAccepted(identifier: String, invitee: String)
    func onInviteeRejected(identifier: String, invitee: String)
    func onInviteeCancelled(identifier: String, invitee: String)
}
