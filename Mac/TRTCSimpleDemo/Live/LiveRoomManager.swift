//
//  LiveRoomManager.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 tencent. All rights reserved.
//

import Alamofire

let TRTC_LIVE_ROOM_HOST = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest"
let TRTC_LIVE_ROOM_TYPE = "1"

class ResponseObject: NSObject, Codable {
    var errorCode: Int = -1
    var errorMessage: String = ""
}

class LiveRoomItem: NSObject, Codable {
    var type: String   = TRTC_LIVE_ROOM_TYPE
    var createTime: String = ""
    var id: Int = 0
    var roomId: String = ""
    var appId: String  = "\(SDKAppID)"
}

class RoomListRespObject: NSObject, Codable {
    var errorCode: Int = -1
    var errorMessage: String = ""
    var data: [LiveRoomItem] = []
}

class LiveRemoteUser: NSObject {
    var userId: String = ""
    var isVideoMuted = false
    var isAudioMuted = false
    
    init(userId: String) {
        self.userId = userId
    }
}

/**
 * RTC视频互动直播房间管理逻辑
 *
 * 包括房间创建/销毁，房间列表拉取，以及房间内用户的静音、静画（关闭该用户的视频）状态管理
 * 对房间内某个用户设置“静音”、“关闭视频”时，会把状态保存在LiveRoomManager里面
 */
class LiveRoomManager: NSObject {
    
    static let sharedInstance = LiveRoomManager()
    
    /// 用于保存房间内用户的静音和静画状态，以userId为key，存储的是一个LiveRemoteUser对象
    private lazy var roomUserMap = NSMutableDictionary.init()
    
    func isVideoMuted(forUser userId: String) -> Bool {
        if let remoteUser = roomUserMap[userId] {
            return (remoteUser as! LiveRemoteUser).isVideoMuted
        } else {
            return false
        }
    }
    
    func isAudioMuted(forUser userId: String) -> Bool {
        if let remoteUser = roomUserMap[userId] {
            return (remoteUser as! LiveRemoteUser).isAudioMuted
        } else {
            return false
        }
    }
    
    func muteRemoteVideo(forUser userId: String, muted: Bool) {
        if let remoteUser = roomUserMap[userId] {
            (remoteUser as! LiveRemoteUser).isVideoMuted = muted
        }
    }
    
    func muteRemoteAudio(forUser userId: String, muted: Bool) {
        if let remoteUser = roomUserMap[userId] {
            (remoteUser as! LiveRemoteUser).isAudioMuted = muted
        }
    }
    
    func onRemoteUserEnterRoom(userId: String) {
        roomUserMap[userId] = LiveRemoteUser.init(userId: userId)
    }
    
    func onRemoteUserLeaveRoom(userId: String) {
        roomUserMap.removeObject(forKey: userId)
    }
    
    // MARK: 房间列表协议
    /**
     * 获取视频直播房间列表
     */
    func queryLiveRoomList(success: @escaping (_ roomList: [LiveRoomItem])->Void) {
        let params = ["method" : "getRoomList",
                      "appId"  : "\(SDKAppID)",
                      "type"   : TRTC_LIVE_ROOM_TYPE]
        Alamofire.request(TRTC_LIVE_ROOM_HOST, method: .post, parameters: params).responseJSON { [] (data) in
            if let respData = data.data, respData.count > 0 {
                guard let result = try? JSONDecoder().decode(RoomListRespObject.self, from: respData) else {
                    fatalError("queryLiveRoomList, RoomListRespObject decode failed")
                }
                if 0 == result.errorCode {
                    success(result.data)
                } else {
                    print("queryLiveRoomList failed, result:\(result.errorCode), \(result.errorMessage)")
                }
            } else {
                print("queryLiveRoomList failed, resp data is empty")
            }
        }
    }
    
    /**
     * 创建直播房间
     */
    func createLiveRoom(roomId: String?) {
        guard nil != roomId && !(roomId!.isEmpty) else {
            return
        }
        let params = ["method" : "createRoom",
                      "appId"  : "\(SDKAppID)",
                      "roomId" : roomId!,
                      "type"   : TRTC_LIVE_ROOM_TYPE]
        Alamofire.request(TRTC_LIVE_ROOM_HOST, method: .post, parameters: params).responseJSON { [] (data) in
            if let respData = data.data, respData.count > 0 {
                guard let result = try? JSONDecoder().decode(ResponseObject.self, from: respData) else {
                    fatalError("createLiveRoom, ResponseObject decode failed")
                }
                if 0 != result.errorCode {
                    print("createLiveRoom failed, result:\(result.errorCode), \(result.errorMessage)")
                }
            } else {
                print("createLiveRoom failed, resp data is empty")
            }
        }
        
        roomUserMap.removeAllObjects()
    }
    
    /**
     * 销毁直播房间
     */
    func destroyLiveRoom(roomId: String?) {
        guard nil != roomId && !(roomId!.isEmpty) else {
            return
        }
        let params = ["method" : "destroyRoom",
                      "appId"  : "\(SDKAppID)",
                      "roomId" : roomId!,
                      "type"   : TRTC_LIVE_ROOM_TYPE]
        Alamofire.request(TRTC_LIVE_ROOM_HOST, method: .post, parameters: params).responseJSON { [] (data) in
            if let respData = data.data, respData.count > 0 {
                guard let result = try? JSONDecoder().decode(ResponseObject.self, from: respData) else {
                    fatalError("destroyLiveRoom, ResponseObject decode failed")
                }
                if 0 != result.errorCode {
                    print("destroyLiveRoom failed, result:\(result.errorCode), \(result.errorMessage)")
                }
            } else {
                print("destroyLiveRoom failed, resp data is empty")
            }
        }
        
        roomUserMap.removeAllObjects()
    }
}
