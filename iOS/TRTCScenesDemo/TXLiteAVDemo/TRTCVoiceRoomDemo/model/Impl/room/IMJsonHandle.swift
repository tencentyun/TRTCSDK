//
//  IMProtocol.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/9.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation
import SwiftyJSON

/// 负责生产处理IM room 属性需要的字段
public class IMJsonHandle {
    
    public class Define {
        public static let KEY_ATTR_VERSION: String = "version"
        public static let VALUE_ATTR_VERSION: String = "1.0"
        public static let KEY_ROOM_INFO: String = "roomInfo"
        public static let KEY_SEAT: String = "seat"
        
        public static let KEY_CMD_VERSION = "version"
        public static let VALUE_CMD_VERSION = "1.0"
        public static let KEY_CMD_ACTION = "action"
        
        public static let KEY_INVITATION_VERSION = "version"
        public static let VALUE_INVITATION_VERSION = "1.0"
        public static let KEY_INVITATION_CMD = "command"
        public static let KEY_INVITATION_CONTENT = "content"
        
        public static let CODE_UNKNOWN = 0
        public static let CODE_ROOM_DESTROY = 200
        
        public static let CODE_ROOM_CUSTOM_MSG = 301
    }
    
    public static func getInitRoomMap(roomInfo: TXRoomInfo, seatInfoList: [TXSeatInfo]) -> [String: String] {
        var result = [String: String]()
        result[Define.KEY_ATTR_VERSION] = Define.VALUE_ATTR_VERSION
        let jsonRoomInfo = roomInfo.toJSONString() ?? "{}"
        result[Define.KEY_ROOM_INFO] = jsonRoomInfo
        seatInfoList.enumerated().forEach { (item) in
            let index = item.offset
            let info = item.element
            let jsonInfo = info.toJSONString() ?? "{}"
            result["\(Define.KEY_SEAT)\(index)"] = jsonInfo
        }
        return result
    }
    
    public static func getSeatInfoListJsonStr(seatInfoList: [TXSeatInfo]) -> [String: String] {
        var result = [String: String]()
        seatInfoList.enumerated().forEach { (item) in
            let index = item.offset
            let info = item.element
            let json = info.toJSONString() ?? "{}"
            result["\(Define.KEY_SEAT)\(index)"] = json
        }
        return result
    }
    
    public static func getSeatInfoJsonStr(index: Int, info: TXSeatInfo) -> [String: String] {
        var result = [String: String]()
        let json = info.toJSONString() ?? "{}"
        result["\(Define.KEY_SEAT)\(index)"] = json.replacingOccurrences(of: "\\", with: "")
        return result
    }
    
    public static func getRoomInfoFromAttr(map: [String: String]) -> TXRoomInfo? {
        guard let jsonString = map[Define.KEY_ROOM_INFO] else { return nil }
        let info = TXRoomInfo.deserialize(from: jsonString)
        return info
    }
    
    public static func getSeatListFromAttr(map: [String: String], seatSize: Int) -> [TXSeatInfo] {
        var result = [TXSeatInfo]()
        for index in 0..<seatSize {
            if let jsonString = map["\(Define.KEY_SEAT)\(index)"] {
                let seatInfo = TXSeatInfo.deserialize(from: jsonString) ?? TXSeatInfo.init()
                result.append(seatInfo)
            } else {
                let seatInfo = TXSeatInfo.init()
                result.append(seatInfo)
            }
        }
        return result
    }
    
    public static func getInvitationMsg(roomId: String, cmd: String, content: String) -> String {
        let data = TXInviteData.init()
        data.roomId = roomId
        data.command = cmd
        data.message = content
        let json = data.toJSONString() ?? "{roomId: \"\", cmd: \"\(cmd)\", content: \"\(content)\"}"
        return json
    }
    
    public static func parseInvitationMsg(json: String) -> TXInviteData? {
        return TXInviteData.deserialize(from: json)
    }
    
    public static func getRoomDestroyMsg() -> String {
        var jsonDic = [String: Any]()
        jsonDic[Define.KEY_ATTR_VERSION] = Define.VALUE_ATTR_VERSION
        jsonDic[Define.KEY_CMD_ACTION] = Define.CODE_ROOM_DESTROY
        guard let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: .init(rawValue: 0)) else {
            return ""
        }
        return String.init(data: data, encoding: .utf8) ?? ""
    }
    
    public static func getCusMsgJsonStr(cmd: String, msg: String) -> String {
        var jsonDic = [String: Any]()
        jsonDic[Define.KEY_ATTR_VERSION] = Define.VALUE_ATTR_VERSION
        jsonDic[Define.KEY_CMD_ACTION] = Define.CODE_ROOM_CUSTOM_MSG
        jsonDic["command"] = cmd
        jsonDic["message"] = msg
        guard let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: .init(rawValue: 0)) else {
            return ""
        }
        return String.init(data: data, encoding: .utf8) ?? ""
    }
    
    public static func poarseCusMsg(jsonObj: JSON) -> (cmd: String, message: String) {
        guard let cmd = jsonObj.dictionaryValue["command"]?.stringValue, let message = jsonObj.dictionaryValue["command"]?.stringValue else {
            return (cmd: "", message: "")
        }
        return (cmd: cmd, message: message)
    }
}
