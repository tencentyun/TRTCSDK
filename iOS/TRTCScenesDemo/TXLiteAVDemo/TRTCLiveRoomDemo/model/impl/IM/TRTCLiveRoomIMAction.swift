//
//  TRTCLiveRoomIMAction.swift
//  trtcScenesDemo
//
//  Created by Xiaoya Liu on 2020/2/8.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

class TRTCLiveRoomIMAction: NSObject {
    typealias Callback = (_ code: Int, _ message: String?) -> Void
    typealias EnterRoomCallback = (_ members: [TRTCLiveUserInfo], _ customInfo: [String: Any], _ roomInfo: TRTCLiveRoomInfo?) -> Void
    typealias MemberCallback = (_ members: [TRTCLiveUserInfo]) -> Void

    static func setupSdk(sdkAppId: Int32, userSig: String, messageLister: V2TIMAdvancedMsgListener & V2TIMGroupListener) -> Bool {
        let result = V2TIMManager.sharedInstance()?.initSDK(sdkAppId, config: nil, listener: nil)
        if result == false {
            return false
        }
        V2TIMManager.sharedInstance()?.add(messageLister)
        V2TIMManager.sharedInstance()?.setGroupListener(messageLister)
        return true
    }
    
    static func releaseSdk() {
        V2TIMManager.sharedInstance()?.unInitSDK()
    }
    
    static func login(userID: String, userSig: String, callback: Callback?) {
        if V2TIMManager.sharedInstance()?.getLoginUser() == userID {
           callback?(0, "")
            return
        }
        
        let params = TIMLoginParam()
        params.identifier = userID
        params.userSig = userSig
        V2TIMManager.sharedInstance()?.login(userID, userSig: userSig, succ: {
            callback?(0, "")
        }, fail: { (code, errorDes) in
            callback?(Int(code), errorDes)
        })
    }
    
    static func logout(callback: Callback?) {
        V2TIMManager.sharedInstance()?.logout({
            callback?(0, "")
        }, fail: { (code, errorDes) in
            callback?(Int(code), errorDes)
        })
    }
    
    static func setProfile(name: String, avatar: String?, callback: Callback?) {
        let info = V2TIMUserFullInfo()
        info.nickName = name
        info.faceURL = avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(info, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func createRoom(roomID: String,
                           roomParam: TRTCCreateRoomParam,
                           success: EnterRoomCallback?,
                           error: Callback?) {
        V2TIMManager.sharedInstance()?.createGroup("AVChatRoom", groupID: roomID, groupName: roomParam.roomName, succ: { (groupID) in
            success?([], [:], nil)
            let info = V2TIMGroupInfo()
            info.groupID = roomID
            info.faceURL = roomParam.coverUrl
            V2TIMManager.sharedInstance()?.setGroupInfo(info, succ: nil, fail: nil)
        }, fail: { (code, message) in
            // 房间是自己已经创建的
            if (code == ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER.rawValue) {
                V2TIMManager.sharedInstance()?.joinGroup(roomID, msg: nil, succ: {
                    getAllMembers(roomID: roomID, success: { members in
                            success?(members, [:], nil)
                                        // TODO: 这里获取房间状态一直失败
                    //                    if let info = manager.queryGroupInfo(roomID),
                    //                        let customInfo = info.introduction.toJson()
                    //                    {
                    //                        success?(members, customInfo)
                    //                    } else {
                    //                        print("[TEST] - error: failed to query group info")
                    //                    }
                        }, error: error)
                        let info = V2TIMGroupInfo()
                        info.groupID = roomID
                        info.faceURL = roomParam.coverUrl
                        info.groupName = roomParam.roomName
                        V2TIMManager.sharedInstance()?.setGroupInfo(info, succ: nil, fail: nil)
                }, fail: { (code, message) in
                    error?(Int(code), message)
                })
            } else {
                error?(Int(code), message)
            }
            
        })
    }
    
    static func destroyRoom(roomID: String, callback: Callback?) {
        V2TIMManager.sharedInstance()?.dismissGroup(roomID, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func enterRoom(roomID: String,
                          success: EnterRoomCallback?,
                          error: Callback?) {
        V2TIMManager.sharedInstance()?.joinGroup(roomID, msg: "", succ: {
            getAllMembers(roomID: roomID, success: { members in
                V2TIMManager.sharedInstance()?.getGroupsInfo([roomID], succ: { (infoList: [V2TIMGroupInfoResult]?) in
                    let infoResult = infoList?.first
                    if let info = infoResult?.info,
                        let customInfo = info.introduction.toJson()
                    {
                        var roomInfo: TRTCLiveRoomInfo? = nil
                        if let users = customInfo["list"] as? [[String: Any]],
                            let owner = users.first,
                            let type = customInfo["type"] as? Int
                        {
                            roomInfo = TRTCLiveRoomInfo(roomId: String(roomID),
                                                                roomName: "",
                                                                coverUrl: "",
                                                                ownerId: (owner["userId"] as? String) ?? "",
                                                                ownerName: (owner["name"] as? String) ?? "",
                                                                streamUrl: owner["streamId"] as? String,
                                                                memberCount: 0,
                                                                roomStatus: TRTCLiveRoomLiveStatus(rawValue: type) ?? .single)
                        }
                        TRTCLiveRoomIMAction.getRoomInfo(roomIds: [String(roomID)], success: { [roomInfo] (rooms) in //更新信息
                            roomInfo?.roomName = rooms.first?.roomName ?? ""
                            roomInfo?.coverUrl = rooms.first?.coverUrl ?? ""
                            success?(members, customInfo, roomInfo)
                        }) { [roomInfo] (code, error) in
                            success?(members, customInfo, roomInfo)
                        }
                        
                    } else {
                        print("[TEST] - error: failed to query group info")
                    }
                    
                }, fail: { (code, message) in
                    error?(Int(code), message)
                })
            }, error: error)
        }, fail: { (code, message) in
            error?(Int(code), message)
        })
    }
    
    static func exitRoom(roomID: String, callback: Callback?) {
        V2TIMManager.sharedInstance().quitGroup(roomID, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func getRoomInfo(roomIds: [String],
                            success: (([TRTCLiveRoomInfo]) -> Void)?,
                            error: Callback?) {
        V2TIMManager.sharedInstance()?.getGroupsInfo(roomIds, succ: { (infos) in
            guard let infos = infos else {
                error?(-1, "无法获取房间信息")
                return
            }
            let roomInfos = infos.compactMap({ infoResult -> TRTCLiveRoomInfo? in
                if  let info = infoResult.info,
                    let roomInfo = info.introduction.toJson(),
                    let users = roomInfo["list"] as? [[String: Any]],
                    let owner = users.first,
                    let type = roomInfo["type"] as? Int
                {
                    return TRTCLiveRoomInfo(roomId: info.groupID,
                                            roomName: info.groupName,
                                            coverUrl: info.faceURL,
                                            ownerId: info.owner,
                                            ownerName: (owner["name"] as? String) ?? "",
                                            streamUrl: owner["streamId"] as? String,
                                            memberCount: Int(info.memberCount),
                                            roomStatus: TRTCLiveRoomLiveStatus(rawValue: type) ?? .single)
                }
                return nil
            })
            success?(roomInfos)
        }, fail: { (code, message) in
            error?(Int(code), message)
        })
    }
    
    static func getAllMembers(roomID: String,
                              success: MemberCallback?,
                              error: Callback?) {
        V2TIMManager.sharedInstance()?.getGroupMemberList(roomID, filter: V2TIMGroupMemberFilter.GROUP_MEMBER_FILTER_ALL, nextSeq: 0, succ: { (nextSeq, infoList: [V2TIMGroupMemberFullInfo]?) in
            success?(infoList?.map { TRTCLiveUserInfo(profile: $0) } ?? [])
        }, fail: { (code, message) in
            error?(Int(code), message)
        })
    }
}

// MARK: - Action Message
extension TRTCLiveRoomIMAction {
    static func requestJoinAnchor(userID: String, reason: String?, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.requestJoinAnchor.rawValue,
            "reason": reason ?? "",
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func respondJoinAnchor(userID: String, agreed: Bool, reason: String?, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.respondJoinAnchor.rawValue,
            "accept": agreed ? 1 : 0,
            "reason": reason ?? "",
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func kickoutJoinAnchor(userID: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.kickoutJoinAnchor.rawValue,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func notifyStreamToAnchor(userID: String, streamId: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.notifyJoinAnchorStream.rawValue,
            "stream_id": streamId,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func requestRoomPK(userID: String, fromRoomID: String, fromStreamId: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.requestRoomPK.rawValue,
            "from_room_id": fromRoomID,
            "from_stream_id": fromStreamId,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func responseRoomPK(userID: String, agreed: Bool, reason: String?, streamId: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.respondRoomPK.rawValue,
            "accept": agreed ? 1 : 0,
            "reason": reason ?? "",
            "stream_id": streamId,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func quitRoomPK(userID: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.quitRoomPK.rawValue,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .user(userID), callback: callback)
    }
    
    static func sendRoomTextMsg(roomID: String, message: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.roomTextMsg.rawValue,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .group(roomID, text: message, priority: .PRIORITY_LOW), callback: callback)
    }
    
    static func sendRoomCustomMsg(roomID: String, command: String, message: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.roomCustomMsg.rawValue,
            "command": command,
            "message": message,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .group(roomID, text: nil, priority: .PRIORITY_LOW), callback: callback)
    }
    
    static func updateGroupInfo(roomID: String, groupInfo: [String: Any], callback: Callback?) {
        var data = groupInfo
        data["version"] = trtcLiveRoomProtocolVersion
        let groupInfo = data.toJsonString()
        print("[TEST] - updateGroupInfo: \(groupInfo), size:\(groupInfo.count)")
        let info = V2TIMGroupInfo()
        info.groupID = roomID
        info.introduction = groupInfo
        V2TIMManager.sharedInstance()?.setGroupInfo(info, succ: {
            data["action"] = TRTCLiveRoomIMActionType.updateGroupInfo.rawValue
            sendMessage(data: data, convType: .group(roomID, text: nil, priority: .PRIORITY_HIGH), callback: callback)
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
}

// MARK: - Private
private extension TRTCLiveRoomIMAction {
    enum ConvType {
        case user(_ userID: String)
        case group(_ groupID: String, text: String?, priority: V2TIMMessagePriority )
    }
    
    static func sendMessage(data: [String: Any], convType: ConvType, callback: Callback?) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            callback?(-1, "")
            return
        }
        print(data)
        var message = V2TIMMessage()
        if case .group(_, let messageText, _) = convType, let text = messageText {
            if let msg = V2TIMManager.sharedInstance()?.createTextMessage(text) {
                message = msg
            }
        } else {
            if let msg = V2TIMManager.sharedInstance()?.createCustomMessage(jsonData) {
                message = msg
            }
        }
        switch convType {
        case .user(let userID):
            V2TIMManager.sharedInstance()?.send(message, receiver:userID , groupID: nil, priority: .PRIORITY_NORMAL, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: {
                callback?(0, "Send successfully")
            }, fail: { (code, error) in
                debugPrint("send message error \(code) \(error ?? "")")
                callback?(-1, "")
            })
        case .group(let groupID, _, let priority):
            V2TIMManager.sharedInstance()?.send(message, receiver:nil , groupID: groupID, priority: priority, onlineUserOnly: false, offlinePushInfo: nil, progress: nil, succ: {
                callback?(0, "Send successfully")
            }, fail: { (code, error) in
                debugPrint("send message error \(code) \(error ?? "")")
                callback?(-1, "")
            })
        }
    }
}
