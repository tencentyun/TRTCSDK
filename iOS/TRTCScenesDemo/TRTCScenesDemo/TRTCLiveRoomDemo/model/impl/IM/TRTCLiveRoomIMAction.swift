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
    
    private static let manager = TIMManager.sharedInstance()!.groupManager()!
    
    static func setupSdk(sdkAppId: Int32, userSig: String, messageLister: TIMMessageListener & TIMGroupEventListener) -> Bool {
        let config = TIMSdkConfig()
        config.sdkAppId = sdkAppId
        config.dbPath = NSHomeDirectory() + "/Documents/com_tencent_imsdk_data/"
        
        let result = TIMManager.sharedInstance()?.initSdk(config)
        if result != 0 {
            return false
        }
        TIMManager.sharedInstance()?.add(messageLister)
        
        let userConfig = TIMUserConfig()
        userConfig.groupEventListener = messageLister
        TIMManager.sharedInstance()?.setUserConfig(userConfig)
        return true
    }
    
    static func releaseSdk() {
        TIMManager.sharedInstance()?.unInit()
    }
    
    static func login(userID: String, userSig: String, callback: Callback?) {
        if TIMManager.sharedInstance()?.getLoginUser() == userID {
           callback?(0, "")
            return
        }
        
        let params = TIMLoginParam()
        params.identifier = userID
        params.userSig = userSig
        
        TIMManager.sharedInstance()?.login(params, succ: {
            callback?(0, "")
        }, fail: { (code, errorDes) in
            callback?(Int(code), errorDes)
        })
    }
    
    static func logout(callback: Callback?) {
        TIMManager.sharedInstance()?.logout({
            callback?(0, "")
        }, fail: { (code, errorDes) in
            callback?(Int(code), errorDes)
        })
    }
    
    static func setProfile(name: String, avatar: String?, callback: Callback?) {
        var params = [TIMProfileTypeKey_Nick: name]
        if let avatar = avatar {
            params[TIMProfileTypeKey_FaceUrl] = avatar
        }
        TIMManager.sharedInstance()?.friendshipManager()?.modifySelfProfile(params, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func createRoom(roomID: String,
                           roomParam: TRTCCreateRoomParam,
                           success: EnterRoomCallback?,
                           error: Callback?) {
        manager.createGroup("AVChatRoom", groupId: roomID, groupName: roomParam.roomName, succ: { (groupID) in
            success?([], [:], nil)
            manager.modifyGroupFaceUrl(roomID, url: roomParam.coverUrl, succ: {
                
            }) { (code, error) in
                
            }
        }, fail: { (code, message) in
            // 房间是自己已经创建的
            if (code == ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER.rawValue) {
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
                manager.modifyGroupFaceUrl(roomID, url: roomParam.coverUrl, succ: {
                    
                }) { (code, error) in
                    
                }
                manager.modifyGroupName(roomID, groupName: roomParam.roomName, succ: {
                    
                }) { (code, error) in
                    
                }
            } else {
                error?(Int(code), message)
            }
        })
    }
    
    static func destroyRoom(roomID: String, callback: Callback?) {
        manager.deleteGroup(roomID, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func enterRoom(roomID: String,
                          success: EnterRoomCallback?,
                          error: Callback?) {
        manager.joinGroup(roomID, msg: "", succ: {
            getAllMembers(roomID: roomID, success: { members in
                if let info = manager.queryGroupInfo(roomID),
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
                                                            type: TRTCLiveRoomLiveType(rawValue: type) ?? .single)
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
            }, error: error)
        }, fail: { (code, message) in
            error?(Int(code), message)
        })
    }
    
    static func exitRoom(roomID: String, callback: Callback?) {
        manager.quitGroup(roomID, succ: {
            callback?(0, "")
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
    
    static func getRoomInfo(roomIds: [String],
                            success: (([TRTCLiveRoomInfo]) -> Void)?,
                            error: Callback?) {
        manager.getGroupInfo(roomIds, succ: { infos in
            guard let infos = infos as? [TIMGroupInfoResult] else {
                error?(-1, "无法获取房间信息")
                return
            }
            let roomInfos = infos.compactMap({ info -> TRTCLiveRoomInfo? in
                if let roomInfo = info.introduction.toJson(),
                    let users = roomInfo["list"] as? [[String: Any]],
                    let owner = users.first,
                    let type = roomInfo["type"] as? Int
                {
                    return TRTCLiveRoomInfo(roomId: info.group,
                                            roomName: info.groupName,
                                            coverUrl: info.faceURL,
                                            ownerId: info.owner,
                                            ownerName: (owner["name"] as? String) ?? "",
                                            streamUrl: owner["streamId"] as? String,
                                            memberCount: Int(info.memberNum),
                                            type: TRTCLiveRoomLiveType(rawValue: type) ?? .single)
                }
                return nil
            })
            success?(roomInfos)
        }) { (code, message) in
            error?(Int(code), message)
        }
    }
    
    static func getAllMembers(roomID: String,
                              success: MemberCallback?,
                              error: Callback?) {
        manager.getGroupMembers(roomID, succ: { members in
            guard let members = members as? [TIMGroupMemberInfo] else {
                success?([])
                return
            }
            guard let owner = members.first(where: { $0.role == TIMGroupMemberRole.GROUP_MEMBER_ROLE_SUPER }) else {
                assert(false)
                return
            }
            getMembers(userIdList: members.map{ $0.member }, success: { users in
                if let user = users.first(where: { $0.userId == owner.member }) {
                    user.isOwner = true
                }
                success?(users)
            }, error: error)
        }, fail: { (code, message) in
            error?(Int(code), message)
        })
    }
    
    static func getMembers(userIdList: [String], success: (([TRTCLiveUserInfo]) -> Void)?, error: Callback?) {
        TIMManager.sharedInstance()?.friendshipManager()?.getUsersProfile(
            userIdList,
            forceUpdate: false,
            succ: { userProfiles in
                success?(userProfiles?.map { TRTCLiveUserInfo(profile: $0) } ?? [])
            },
            fail: { (code, message) in
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
        sendMessage(data: data, convType: .group(roomID, text: message, priority: .MSG_PRIORITY_LOWEST), callback: callback)
    }
    
    static func sendRoomCustomMsg(roomID: String, command: String, message: String, callback: Callback?) {
        let data: [String: Any] = [
            "action": TRTCLiveRoomIMActionType.roomCustomMsg.rawValue,
            "command": command,
            "message": message,
            "version": trtcLiveRoomProtocolVersion
        ]
        sendMessage(data: data, convType: .group(roomID, text: nil, priority: .MSG_PRIORITY_LOWEST), callback: callback)
    }
    
    static func updateGroupInfo(roomID: String, groupInfo: [String: Any], callback: Callback?) {
        var data = groupInfo
        data["version"] = trtcLiveRoomProtocolVersion
        let groupInfo = data.toJsonString()
        print("[TEST] - updateGroupInfo: \(groupInfo), size:\(groupInfo.count)")
        TIMManager.sharedInstance()?.groupManager()?.modifyGroupIntroduction(roomID, introduction: groupInfo, succ: {
            data["action"] = TRTCLiveRoomIMActionType.updateGroupInfo.rawValue
            sendMessage(data: data, convType: .group(roomID, text: nil, priority: .MSG_PRIORITY_HIGH), callback: callback)
        }, fail: { (code, message) in
            callback?(Int(code), message)
        })
    }
}

// MARK: - Private
private extension TRTCLiveRoomIMAction {
    enum ConvType {
        case user(_ userID: String)
        case group(_ groupID: String, text: String?, priority: TIMMessagePriority = .MSG_PRIORITY_NORMAL)
    }
    
    static func sendMessage(data: [String: Any], convType: ConvType, callback: Callback?) {
        guard let conv = conversation(of: convType) else {
            callback?(-1, "")
            return
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            callback?(-1, "")
            return
        }
        
        let message = TIMMessage()
        
        let customElement = TIMCustomElem()
        customElement.data = jsonData
        message.add(customElement)
        
        if case .group(_, let messageText, _) = convType, let text = messageText {
            let textElement = TIMTextElem()
            textElement.text = text
            message.add(textElement)
        }
        
        if case .group(_, _,let priority) = convType {
            message.setPriority(priority)
        }
        
        conv.send(message, succ: {
            callback?(0, "Send successfully")
        }) { (code, error) in
            debugPrint("send message error \(code) \(error ?? "")")
            callback?(-1, "")
        }
    }
    
    static func conversation(of convType: ConvType) -> TIMConversation? {
        switch convType {
        case .user(let userID):
            return TIMManager.sharedInstance()?.getConversation(.C2C, receiver: userID)
        case .group(let groupID, _, _):
            return TIMManager.sharedInstance()?.getConversation(.GROUP, receiver: groupID)
        }
    }
}
