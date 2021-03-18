//
//  TRTCVoiceRoomViewModel.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

protocol TRTCVoiceRoomViewResponder: class {
    func showToast(message: String)
    func popToPrevious()
    func switchView(type: VoiceRoomViewType)
    func changeRoom(title: String)
    func refreshAnchorInfos()
    func onSeatMute(isMute: Bool)
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?)
    func showActionSheet(actionTitles:[String], actions: @escaping (Int) -> Void)
    func refreshMsgView()
    func msgInput(show: Bool)
    func audiceneList(show: Bool)
    func audienceListRefresh()
    func showAudioEffectView()
    func stopPlayBGM() // 停止播放音乐
    func recoveryVoiceSetting() // 恢复音效设置
}

class TRTCVoiceRoomViewModel: NSObject {
    private let dependencyContainer: TRTCVoiceRoomEnteryControl
    private(set) var roomType: VoiceRoomViewType {
        didSet {
            roleChange(viewType: roomType)
        }
    }
    public weak var viewResponder: TRTCVoiceRoomViewResponder?
    
    private(set) var isSelfMute: Bool = false
    // 防止多次退房
    private var isExitingRoom: Bool = false
    
    private(set) var roomInfo: VoiceRoomInfo
    private(set) var isSeatInitSuccess: Bool = false
    private(set) var mSelfSeatIndex: Int = -1
    private(set) var isOwnerMute: Bool = false
    
    // UI相关属性
    private(set) var masterAnchor: SeatInfoModel?
    private(set) var anchorSeatList: [SeatInfoModel] = []
    /// 观众信息记录
    private(set) var memberAudienceList: [AudienceInfoModel] = []
    private var memberAudienceDic: [String: AudienceInfoModel] = [:]
    
    private(set) var msgEntityList: [MsgEntity] = []
    /// 当前邀请操作的座位号记录
    private var currentInvitateSeatIndex: Int = -1 // -1 表示没有操作
    /// 上麦信息记录(观众端)
    private var mInvitationSeatDic: [String: Int] = [:]
    /// 上麦信息记录(主播端)
    private var mTakeSeatInvitationDic: [String: String] = [:]
    /// 抱麦信息记录
    private var mPickSeatInvitationDic: [String: SeatInvitation] = [:]
    
    
    /// 房间管理对象
    private var voiceRoomManager: TRTCVoiceRoomManager {
        return TRTCVoiceRoomManager.shared
    }
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责VoiceRoom模块的依赖管理
    init(container: TRTCVoiceRoomEnteryControl, roomInfo: VoiceRoomInfo, roomType: VoiceRoomViewType) {
        self.dependencyContainer = container
        self.roomType = roomType
        self.roomInfo = roomInfo
        super.init()
        voiceRoom.setDelegate(delegate: self)
        roleChange(viewType: self.roomType)
        initAnchorListData()
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    private var voiceRoom: TRTCVoiceRoom {
        return dependencyContainer.getVoiceRoom()
    }
    
    func exitRoom() {
        guard !isExitingRoom else { return }
        viewResponder?.popToPrevious()
        isExitingRoom = true
        if dependencyContainer.userId == roomInfo.ownerId && roomType == .anchor {
            voiceRoomManager.destroyRoom(sdkAppID: dependencyContainer.mSDKAppID, roomID: "\(roomInfo.roomID)", success: {
                TRTCLog.out("---销毁房间成功")
            }) { (code, message) in
                TRTCLog.out("---销毁房间失败")
            }
            voiceRoom.destroyRoom { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.isExitingRoom = false
            }
            return
        }
        voiceRoom.exitRoom { [weak self] (code, message) in
            guard let `self` = self else { return }
            self.isExitingRoom = false
        }
    }
    
    public func refreshView() {
        roleChange(viewType: roomType)
    }
    
    public func openMessageTextInput() {
        viewResponder?.msgInput(show: true)
    }
    
    public func openAudioEffectMenu() {
        guard checkButtonPermission() else { return }
        viewResponder?.showAudioEffectView()
    }
    
    public func muteAction(isMute: Bool) -> Bool {
        guard checkButtonPermission() else { return false }
        guard !isOwnerMute else {
            viewResponder?.showToast(message: "已被房主禁言")
            return false
        }
        isSelfMute = isMute
        voiceRoom.muteLocalAudio(mute: isMute)
        if isMute {
            viewResponder?.showToast(message: "已关闭麦克风")
        } else {
            viewResponder?.recoveryVoiceSetting()
            viewResponder?.showToast(message: "已打开麦克风")
        }
        return true
    }
    
    public func spechAction(isMute: Bool) {
        voiceRoom.muteAllRemoteAudio(isMute: isMute)
        if isMute {
            viewResponder?.showToast(message: "已静音")
        } else {
            viewResponder?.showToast(message: "已取消静音")
        }
    }
    
    public func clickSeat(model: SeatInfoModel) {
        guard isSeatInitSuccess else {
            viewResponder?.showToast(message: "麦位列表还未初始化哦！")
            return
        }
        if roomType == .audience || dependencyContainer.userId != roomInfo.ownerId {
            audienceClickItem(model: model)
        } else {
            anchorClickItem(model: model)
        }
    }
    
    public func enterRoom(toneQuality: Int = VoiceRoomToneQuality.music.rawValue) {
        voiceRoom.enterRoom(roomID: roomInfo.roomID) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: "进房成功")
                self.voiceRoom.setAuidoQuality(quality: toneQuality)
            } else {
                self.viewResponder?.showToast(message: "进房失败")
                self.viewResponder?.popToPrevious()
            }
        }
    }
    
    public func createRoom(toneQuality: Int = 0) {
        var coverUrl = roomInfo.coverUrl
        if !coverUrl.hasPrefix("http") {
            coverUrl = ProfileManager.shared.curUserModel?.avatar ?? ""
        }
        voiceRoom.setAuidoQuality(quality: toneQuality)
        voiceRoom.setSelfProfile(userName: roomInfo.ownerName, avatarURL: coverUrl) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("setSelfProfile\(code)\(message)")
            TRTCVoiceRoomManager.shared.createRoom(sdkAppID: SDKAPPID, roomID: "\(self.roomInfo.roomID)", success: { [weak self] in
                guard let `self` = self else { return }
                self.internalCreateRoom()
            }) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == -1301 {
                    self.internalCreateRoom()
                } else {
                    self.viewResponder?.showToast(message: "创建房间失败")
                    self.viewResponder?.popToPrevious()
                }
            }
        }
    }
    
    public func onTextMsgSend(message: String) {
        if message.count == 0 {
            return
        }
        // 消息回显示
        let entity = MsgEntity.init(userId: dependencyContainer.userId, userName: "我", content: message, invitedId: "", type: MsgEntity.TYPE_NORMAL)
        notifyMsg(entity: entity)
        voiceRoom.sendRoomTextMsg(message: message) { [weak self] (code, message) in
            guard let `self` = self else { return }
            self.viewResponder?.showToast(message: code == 0 ? "发送成功" : "发送失败:\(message)")
        }
    }
    
    public func acceptTakeSeat(identifier: String) {
        if let audience = memberAudienceDic[identifier] {
            acceptTakeSeatInviattion(userInfo: audience.userInfo)
        }
    }
}

// MARK: - private method
extension TRTCVoiceRoomViewModel {
    
    private func internalCreateRoom() {
        let param = VoiceRoomParam.init()
        param.roomName = roomInfo.roomName
        param.needRequest = roomInfo.needRequest
        param.seatCount = roomInfo.memberCount
        param.coverUrl = roomInfo.coverUrl
        param.seatCount = 7
        param.seatInfoList = []
        for _ in 0..<param.seatCount {
            let seatInfo = VoiceRoomSeatInfo.init()
            param.seatInfoList.append(seatInfo)
        }
        voiceRoom.createRoom(roomID: Int32(roomInfo.roomID), roomParam: param) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.changeRoom(title: "\(self.roomInfo.roomName)(\(self.roomInfo.roomID))")
                self.takeMainSeat()
                self.getAudienceList()
            } else {
                self.viewResponder?.showToast(message: "进入房间失败")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let `self` = self else { return }
                    self.viewResponder?.popToPrevious()
                }
            }
        }
    }
    
    private func takeMainSeat() {
        voiceRoom.enterSeat(seatIndex: 0) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: "房主占座成功")
            } else {
                self.viewResponder?.showToast(message: "房主占座失败")
            }
        }
    }
    
    private func getAudienceList() {
        voiceRoom.getUserInfoList(userIDList: nil) { [weak self] (code, message, infos) in
            guard let `self` = self else { return }
            if code == 0 {
                self.memberAudienceList.removeAll()
                let audienceInfoModels = infos.map { (userInfo) -> AudienceInfoModel in
                    return AudienceInfoModel.init(userInfo: userInfo) { [weak self] (index) in
                        // 点击邀请上麦事件，以及接受邀请事件
                        guard let `self` = self else { return }
                        if index == 0 {
                            self.sendInvitation(userInfo: userInfo)
                        } else {
                            self.acceptTakeSeatInviattion(userInfo: userInfo)
                        }
                    }
                }
                self.memberAudienceList.append(contentsOf: audienceInfoModels)
                audienceInfoModels.forEach { (info) in
                    self.memberAudienceDic[info.userInfo.userId] = info
                }
                self.viewResponder?.audienceListRefresh()
            }
        }
    }
    
    func checkButtonPermission() -> Bool {
        if roomType == .audience {
            viewResponder?.showToast(message: "只有主播才能操作哦")
            return false
        }
        return true
    }
    
    private func roleChange(viewType: VoiceRoomViewType) {
        viewResponder?.switchView(type: viewType)
    }
    
    private func initAnchorListData() {
        for _ in 0...5 {
            var model = SeatInfoModel.init { [weak self] (seatIndex) in
                guard let `self` = self else { return }
                if seatIndex > 0 && seatIndex <= self.anchorSeatList.count {
                    let model = self.anchorSeatList[seatIndex - 1]
                    self.clickSeat(model: model)
                }
            }
            model.isOwner = dependencyContainer.userId == roomInfo.ownerId
            model.isClosed = false
            model.isUsed = false
            anchorSeatList.append(model)
        }
    }
    
    private func audienceClickItem(model: SeatInfoModel) {
        guard !model.isClosed else {
            viewResponder?.showToast(message: "麦位已被锁定，无法申请上麦")
            return
        }
        if model.isUsed {
            if dependencyContainer.userId == model.seatUser?.userId ?? "" {
                // 点击自己的头像，弹出下麦对话框
                viewResponder?.showActionSheet(actionTitles: ["下麦"], actions: { [weak self] (index) in
                    guard let `self` = self else { return }
                    self.leaveSeat()
                })
            } else {
                viewResponder?.showToast(message: "\(model.seatUser?.userName ?? "其他主播")")
            }
        } else {
            if mSelfSeatIndex != -1 {
                viewResponder?.showToast(message: "您已经在\(mSelfSeatIndex)号麦位上了")
                return
            }
            guard model.seatIndex != -1 else {
                viewResponder?.showToast(message: "麦位信息没有初始化，暂时无法申请上麦")
                return
            }
            // 没人:申请上麦
            viewResponder?.showActionSheet(actionTitles: ["上麦"], actions: { [weak self] (index) in
                guard let `self` = self else { return }
                self.startTakeSeat(seatIndex: model.seatIndex)
            })
        }
    }
    
    private func anchorClickItem(model: SeatInfoModel) {
        if model.isUsed {
            // 弹出禁言， 踢人
            let isMute = model.seatInfo?.mute ?? false
            viewResponder?.showActionSheet(actionTitles: ["对Ta\(isMute ? "解禁" : "禁言")", "请Ta下麦"], actions: { [weak self] (index) in
                guard let `self` = self else { return }
                if index == 0 {
                    // 禁言
                    self.voiceRoom.muteSeat(seatIndex: model.seatIndex, isMute: !isMute, callback: nil)
                } else {
                    // 下麦
                    self.voiceRoom.kickSeat(seatIndex: model.seatIndex, callback: nil)
                }
            })
            return
        }
        if !model.isClosed {
            // 没人的话弹出封禁麦位和请人上麦
            viewResponder?.showActionSheet(actionTitles: ["邀人上麦", "封禁麦位"], actions: { [weak self] (index) in
                guard let `self` = self else { return }
                if index == 0 {
                    self.onAnchorSeatSelected(seatIndex: model.seatIndex)
                } else {
                    self.voiceRoom.closeSeat(seatIndex: model.seatIndex, isClose: true, callback: nil)
                }
            })
        } else {
            viewResponder?.showActionSheet(actionTitles: ["解禁麦位"], actions: { [weak self] (index) in
                guard let `self` = self else { return }
                self.voiceRoom.closeSeat(seatIndex: model.seatIndex, isClose: false, callback: nil)
            })
            
        }
    }
    
    private func onAnchorSeatSelected(seatIndex: Int) {
        viewResponder?.audiceneList(show: true)
        currentInvitateSeatIndex = seatIndex
    }
    
    private func sendInvitation(userInfo: VoiceRoomUserInfo) {
        guard currentInvitateSeatIndex != -1 else { return }
        // 邀请
        let seatEntity = anchorSeatList[currentInvitateSeatIndex - 1]
        if seatEntity.isUsed {
            viewResponder?.showToast(message: "这个座位已经有人了")
            return
        }
        let seatInvitation = SeatInvitation.init(seatIndex: currentInvitateSeatIndex, inviteUserId: userInfo.userId)
        let inviteId = voiceRoom.sendInvitation(cmd: VoiceRoomConstants.CMD_PICK_UP_SEAT,
                                                userId: seatInvitation.inviteUserId,
                                                content: "\(seatInvitation.seatIndex)") { [weak self] (code, message) in
                                                    guard let `self` = self else { return }
                                                    if code == 0 {
                                                        self.viewResponder?.showToast(message: "发送邀请成功")
                                                    }
        }
        mPickSeatInvitationDic[inviteId] = seatInvitation
        viewResponder?.audiceneList(show: false)
    }
    
    private func acceptTakeSeatInviattion(userInfo: VoiceRoomUserInfo) {
        // 接受
        guard let inviteID = mTakeSeatInvitationDic[userInfo.userId] else {
            viewResponder?.showToast(message: "该请求已过期")
            return
        }
        voiceRoom.acceptInvitation(identifier: inviteID) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                // 接受请求成功，刷新外部对话列表
                if let index = self.msgEntityList.firstIndex(where: { (msg) -> Bool in
                    return msg.invitedId == inviteID
                }) {
                    var msg = self.msgEntityList[index]
                    msg.type = MsgEntity.TYPE_AGREED
                    self.msgEntityList[index] = msg
                    self.viewResponder?.refreshMsgView()
                }
            } else {
                self.viewResponder?.showToast(message: "接受请求失败")
            }
        }
    }
    
    private func leaveSeat() {
        voiceRoom.leaveSeat { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: "下麦成功")
            } else {
                self.viewResponder?.showToast(message: "下麦失败：\(message)")
            }
        }
    }
    
    /// 观众开始上麦
    /// - Parameter seatIndex: 上的作为号
    private func startTakeSeat(seatIndex: Int) {
        if roomType == .anchor {
            viewResponder?.showToast(message: "已经是上麦主播了")
            return
        }
        if roomInfo.needRequest {
            // 需要申请上麦
            guard roomInfo.ownerId != "" else {
                viewResponder?.showToast(message: "房间还没有准备好")
                return
            }
            let cmd = VoiceRoomConstants.CMD_REQUEST_TAKE_SEAT
            let targetUserId = roomInfo.ownerId
            let inviteId = voiceRoom.sendInvitation(cmd: cmd, userId: targetUserId, content: "\(seatIndex)") { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    self.viewResponder?.showToast(message: "申请已发出，等待主播处理")
                } else {
                    self.viewResponder?.showToast(message: "申请发送失败：\(message)")
                }
            }
            mInvitationSeatDic[inviteId] = seatIndex
        } else {
            // 不需要的情况下自动上麦
            voiceRoom.enterSeat(seatIndex: seatIndex) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    self.viewResponder?.showToast(message: "上麦成功")
                } else {
                    self.viewResponder?.showToast(message: "上麦失败")
                }
            }
        }
    }
    
    private func recvPickSeat(identifier: String, cmd: String, content: String) {
        guard let seatIndex = Int.init(content) else { return }
        viewResponder?.showAlert(info: (title: "提示", message: "主播邀请你上\(seatIndex)号麦"), sureAction: { [weak self] in
            guard let `self` = self else { return }
            self.voiceRoom.acceptInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code != 0 {
                    self.viewResponder?.showToast(message: "接受请求失败")
                }
            }
        }, cancelAction: { [weak self] in
            guard let `self` = self else { return }
            self.voiceRoom.rejectInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.viewResponder?.showToast(message: "您已经拒绝上麦申请")
            }
        })
    }
    
    private func recvTakeSeat(identifier: String, inviter: String, content: String) {
        // 收到新的邀请后，更新列表,其他的信息
        if let index = msgEntityList.firstIndex(where: { (msg) -> Bool in
            return msg.userId == inviter && msg.type == MsgEntity.TYPE_WAIT_AGREE
        }) {
            var msg = msgEntityList[index]
            msg.type = MsgEntity.TYPE_AGREED
            msgEntityList[index] = msg
        }
        // 显示到通知栏
        let audinece = memberAudienceDic[inviter]
        let seatIndex = (Int.init(content) ?? 0)
        let content = "申请上\(seatIndex)号麦"
        let msgEntity = MsgEntity.init(userId: inviter, userName: audinece?.userInfo.userName ?? inviter, content: content, invitedId: identifier, type: MsgEntity.TYPE_WAIT_AGREE)
        msgEntityList.append(msgEntity)
        viewResponder?.refreshMsgView()
        if var audienceModel = audinece {
            audienceModel.type = AudienceInfoModel.TYPE_WAIT_AGREE
            memberAudienceDic[audienceModel.userInfo.userId] = audienceModel
            if let index = memberAudienceList.firstIndex(where: { (model) -> Bool in
                return model.userInfo.userId == audienceModel.userInfo.userId
            }) {
                memberAudienceList[index] = audienceModel
            }
            viewResponder?.audienceListRefresh()
        }
        mTakeSeatInvitationDic[inviter] = identifier
    }
    
    private func notifyMsg(entity: MsgEntity) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.msgEntityList.count > 1000 {
                self.msgEntityList.removeSubrange(0...99)
            }
            self.msgEntityList.append(entity)
            self.viewResponder?.refreshMsgView()
        }
    }
    
    private func showNotifyMsg(messsage: String) {
        let msgEntity = MsgEntity.init(userId: "", userName: "", content: messsage, invitedId: "", type: MsgEntity.TYPE_NORMAL)
        if msgEntityList.count > 1000 {
            msgEntityList.removeSubrange(0...99)
        }
        msgEntityList.append(msgEntity)
        viewResponder?.refreshMsgView()
    }
    
    private func changeAudience(status: Int, user: VoiceRoomUserInfo) {
        guard [AudienceInfoModel.TYPE_IDEL, AudienceInfoModel.TYPE_IN_SEAT, AudienceInfoModel.TYPE_WAIT_AGREE].contains(status) else { return }
        if dependencyContainer.userId == roomInfo.ownerId && roomType == .anchor {
            let audience = memberAudienceDic[user.userId]
            if var audienceModel = audience {
                if audienceModel.type == status { return }
                audienceModel.type = status
                memberAudienceDic[audienceModel.userInfo.userId] = audienceModel
                if let index = memberAudienceList.firstIndex(where: { (model) -> Bool in
                    return model.userInfo.userId == audienceModel.userInfo.userId
                }) {
                    memberAudienceList[index] = audienceModel
                }
                viewResponder?.audienceListRefresh()
            }
        }
    }
}

// MARK:- room delegate
extension TRTCVoiceRoomViewModel: TRTCVoiceRoomDelegate {
    func onError(code: Int32, message: String) {
        
    }
    
    func onWarning(code: Int32, message: String) {
        
    }
    
    func onDebugLog(message: String) {
        
    }
    
    func onRoomDestroy(message: String) {
        viewResponder?.showToast(message: "房主已解散房间")
        voiceRoom.exitRoom(callback: nil)
        viewResponder?.popToPrevious()
    }
    
    func onRoomInfoChange(roomInfo: VoiceRoomInfo) {
        // 值为-1表示该接口没有返回数量信息
        if roomInfo.memberCount == -1 {
            roomInfo.memberCount = self.roomInfo.memberCount
        }
        self.roomInfo = roomInfo
        viewResponder?.changeRoom(title: "\(roomInfo.roomName)(\(roomInfo.roomID))")
    }
    
    func onSeatListChange(seatInfoList: [VoiceRoomSeatInfo]) {
        TRTCLog.out("roomLog: onSeatListChange: \(seatInfoList)")
        isSeatInitSuccess = true
        seatInfoList.enumerated().forEach { (item) in
            let seatIndex = item.offset
            let seatInfo = item.element
            var anchorSeatInfo = SeatInfoModel.init { [weak self] (seatIndex) in
                guard let `self` = self else { return }
                if seatIndex > 0 && seatIndex <= self.anchorSeatList.count {
                    let model = self.anchorSeatList[seatIndex - 1]
                    self.clickSeat(model: model)
                }
            }
            anchorSeatInfo.seatInfo = seatInfo
            anchorSeatInfo.isUsed = seatInfo.status == 1
            anchorSeatInfo.isClosed = seatInfo.status == 2
            anchorSeatInfo.seatIndex = seatIndex
            anchorSeatInfo.isOwner = roomInfo.ownerId == dependencyContainer.userId
            if seatIndex == 0 {
                anchorSeatInfo.seatUser = masterAnchor?.seatUser
                masterAnchor = anchorSeatInfo
            } else {
                let listIndex = seatIndex - 1
                if anchorSeatList.count == seatInfoList.count - 1 {
                    // 说明有数据
                    let anchorSeatModel = anchorSeatList[listIndex]
                    anchorSeatInfo.seatUser = anchorSeatModel.seatUser
                    if !anchorSeatInfo.isUsed {
                        anchorSeatInfo.seatUser = nil
                    }
                    anchorSeatList[listIndex] = anchorSeatInfo
                } else {
                    // 说明没数据
                    anchorSeatList.append(anchorSeatInfo)
                }
            }
        }
        let seatUserIds = seatInfoList.filter({ (seat) -> Bool in
            return seat.userId != ""
        }).map { (seatInfo) -> String in
            return seatInfo.userId
        }
        voiceRoom.getUserInfoList(userIDList: seatUserIds) { [weak self] (code, message, userInfos) in
            guard let `self` = self else { return }
            guard code == 0 else { return }
            var userdic: [String : VoiceRoomUserInfo] = [:]
            userInfos.forEach { (info) in
                userdic[info.userId] = info
            }
            if seatInfoList.count > 0 {
                 self.masterAnchor?.seatUser = userdic[seatInfoList[0].userId]
            } else {
                return
            }
            if self.anchorSeatList.count != seatInfoList.count - 1 {
                TRTCLog.out("座位列表数据出问题了数据出问题了")
                return
            }
            // 修改座位列表的user信息
            for index in 0..<self.anchorSeatList.count {
                let seatInfo = seatInfoList[index + 1] // 从观众开始更新
                self.anchorSeatList[index].seatUser = userdic[seatInfo.userId]
            }
            self.viewResponder?.refreshAnchorInfos()
        }
    }
    
    func onAnchorEnterSeat(index: Int, user: VoiceRoomUserInfo) {
        if index == 0{
            // 房主上麦就不提醒了
            return;
        }
        showNotifyMsg(messsage: "\(user.userName)上\(index)号麦")
        if user.userId == dependencyContainer.userId {
            roomType = .anchor
            mSelfSeatIndex = index
            viewResponder?.recoveryVoiceSetting() // 自己上麦，恢复音效设置
        }
        changeAudience(status: AudienceInfoModel.TYPE_IN_SEAT, user: user)
    }
    
    func onAnchorLeaveSeat(index: Int, user: VoiceRoomUserInfo) {
        if index == 0{
            // 房主下麦就不提醒了
            return;
        }
        showNotifyMsg(messsage: "\(user.userName)下\(index)号麦")
        if user.userId == dependencyContainer.userId {
            roomType = .audience
            mSelfSeatIndex = -1
            // 自己下麦，停止音效播放
            viewResponder?.stopPlayBGM()
        }
        changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: user)
    }
    
    func onSeatMute(index: Int, isMute: Bool) {
        if isMute {
            showNotifyMsg(messsage: "\(index)号位被禁言")
        } else {
            showNotifyMsg(messsage: "\(index)号位解除禁言")
        }
        if mSelfSeatIndex == index {
            isOwnerMute = isMute
            viewResponder?.onSeatMute(isMute: isMute)
        }
    }
    
    func onSeatClose(index: Int, isClose: Bool) {
        showNotifyMsg(messsage: "房主\(isClose ? "封禁" : "解禁")\(index)号位")
    }
    
    func onAudienceEnter(userInfo: VoiceRoomUserInfo) {
        showNotifyMsg(messsage: "\(userInfo.userName)进房")
        // 主播端(房主)
        if roomType == .anchor && roomInfo.ownerId == dependencyContainer.userId {
            let memberEntityModel = AudienceInfoModel.init(type: 0, userInfo: userInfo) { [weak self] (index) in
                guard let `self` = self else { return }
                if index == 0 {
                    self.sendInvitation(userInfo: userInfo)
                } else {
                    self.acceptTakeSeatInviattion(userInfo: userInfo)
                    self.viewResponder?.audiceneList(show: false)
                }
            }
            if !memberAudienceDic.keys.contains(userInfo.userId) {
                memberAudienceDic[userInfo.userId] = memberEntityModel
                memberAudienceList.append(memberEntityModel)
                viewResponder?.audienceListRefresh()
            }
        }
    }
    
    func onAudienceExit(userInfo: VoiceRoomUserInfo) {
        showNotifyMsg(messsage: "\(userInfo.userName)退房")
        // 主播端(房主)
        if roomType == .anchor && roomInfo.ownerId == dependencyContainer.userId {
            memberAudienceList.removeAll { (model) -> Bool in
                return model.userInfo.userId == userInfo.userId
            }
            memberAudienceDic.removeValue(forKey: userInfo.userId)
            viewResponder?.refreshAnchorInfos()
        }
        
    }
    
    func onUserVolumeUpdate(userId: String, volume: Int) {
        
    }
    
    func onRecvRoomTextMsg(message: String, userInfo: VoiceRoomUserInfo) {
        let msgEntity = MsgEntity.init(userId: userInfo.userId,
                                       userName: userInfo.userName,
                                       content: message,
                                       invitedId: "",
                                       type: MsgEntity.TYPE_NORMAL)
        notifyMsg(entity: msgEntity)
    }
    
    func onRecvRoomCustomMsg(cmd: String, message: String, userInfo: VoiceRoomUserInfo) {
        
    }
    
    func onReceiveNewInvitation(identifier: String, inviter: String, cmd: String, content: String) {
        TRTCLog.out("receive message: \(cmd) : \(content)")
        if roomType == .audience {
            if cmd == VoiceRoomConstants.CMD_PICK_UP_SEAT {
                recvPickSeat(identifier: identifier, cmd: cmd, content: content)
            }
        }
        if roomType == .anchor && roomInfo.ownerId == dependencyContainer.userId {
            if cmd == VoiceRoomConstants.CMD_REQUEST_TAKE_SEAT {
                recvTakeSeat(identifier: identifier, inviter: inviter, content: content)
            }
        }
    }
    
    func onInviteeAccepted(identifier: String, invitee: String) {
        if roomType == .audience {
            guard let seatIndex = mInvitationSeatDic.removeValue(forKey: identifier) else {
                return
            }
            guard let seatModel = anchorSeatList.filter({ (seatInfo) -> Bool in
                return seatInfo.seatIndex == seatIndex
            }).first else {
                return
            }
            if !seatModel.isUsed {
                voiceRoom.enterSeat(seatIndex: seatIndex) { [weak self] (code, message) in
                    guard let `self` = self else { return }
                    if code == 0 {
                        self.viewResponder?.showToast(message: "上麦成功")
                    } else {
                        self.viewResponder?.showToast(message: "上麦失败")
                    }
                }
            }
        }
        if roomType == .anchor && roomInfo.ownerId == dependencyContainer.userId {
            guard let seatInvitation = mPickSeatInvitationDic.removeValue(forKey: identifier) else {
                return
            }
            guard let seatModel = anchorSeatList.filter({ (model) -> Bool in
                return model.seatIndex == seatInvitation.seatIndex
            }).first else {
                return
            }
            if !seatModel.isUsed {
                voiceRoom.pickSeat(seatIndex: seatInvitation.seatIndex, userId: seatInvitation.inviteUserId) { [weak self] (code, message) in
                    guard let `self` = self else { return }
                    if code == 0 {
                        self.viewResponder?.showToast(message: "抱\(invitee)上麦成功")
                    }
                }
            }
        }
        
    }
    
    func onInviteeRejected(identifier: String, invitee: String) {
        if let seatInvitation = mPickSeatInvitationDic.removeValue(forKey: identifier) {
            guard let audience = memberAudienceDic[seatInvitation.inviteUserId] else { return }
            viewResponder?.showToast(message: "\(audience.userInfo.userName)拒绝上麦")
            changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: audience.userInfo)
        }
        
    }
    
    func onInvitationCancelled(identifier: String, invitee: String) {
        
    }
}
