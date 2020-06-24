//
//  TRTCAudioCall+NewMessage.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/9/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit

extension TRTCAudioCall {
    @objc public func onRecvNewMessage(_ msg: V2TIMMessage!) {
        if msg.elemType == .ELEM_TYPE_CUSTOM {
            if let elem = msg.customElem,
                let model = AudioCallUtils.shared.data2CallModel(data: elem.data)
            {
                if model.calltype != .audio {
                    return
                }
                TRTCCloud.sharedInstance().delegate = self
                if model.version == audioCallVersion, let user = msg.sender {
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
    }
    
    func checkCallTimeOut(msg: V2TIMMessage) -> (Bool, Double) {
        let timeInterval = Date.init().timeIntervalSince(msg.timestamp as Date)
        return (timeInterval >= timeOut, timeInterval)
    }
}
