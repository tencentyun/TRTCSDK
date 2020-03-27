//
//  TRTCLiveRoomIMActionType.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
let trtcLiveRoomProtocolVersion = "1.0.0"

enum TRTCLiveRoomIMActionType: Int, Codable {
    case unknown = 0

    case requestJoinAnchor = 100 // 请求连麦
    case respondJoinAnchor  // 回复连麦请求
    case kickoutJoinAnchor  // 踢除连麦观众
    case notifyJoinAnchorStream  // 上麦观众通知主播streamId

    case requestRoomPK = 200  // 请求跨房PK
    case respondRoomPK  // 回复跨房PK请求
    case quitRoomPK  // 退出跨房PK

    case roomTextMsg = 300  // 发送文本消息
    case roomCustomMsg  // 发送自定义消息
    
    case updateGroupInfo = 400  // 发送房间信息更新通知
}
