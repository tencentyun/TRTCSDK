//
//  TRTCVideoCall+NewMessage.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/9/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

extension TRTCVideoCall {
    @objc public func onNewMessage(_ msgs: [Any]!) {
        if let msg = msgs.first as? TIMMessage, let elem = msg.getElem(0),
            let cus = elem as? TIMCustomElem, let model = VideoCallUtils.shared.data2CallModel(data: cus.data)
        {
            if model.calltype != .video {
                return
            }
            TRTCCloud.sharedInstance().delegate = self
            if model.version == videoCallVersion, let user = msg.sender() {
                debugPrint("📳 on call msg: sender:\(user) call_id:\(model.callid), room_id:\(model.roomid), action:\(model.action.debug)")
                let timeCheck = checkCallTimeOut(msg: msg)
                if !timeCheck.0 {
                    handleCallModel(user: user, model: model, leftTime: max(0, timeOut - timeCheck.1))
                    // add user to resp list
                    if model.callid == curCallID {
                        if !curRespList.contains(user) {
                            curRespList.append(user)
                        }
                    }
                }
            }
        }
    }
    func checkCallTimeOut(msg: TIMMessage) -> (Bool, Double) {
        let timeInterval = Date.init().timeIntervalSince(msg.timestamp())
        return (timeInterval >= timeOut, timeInterval)
    }
}
