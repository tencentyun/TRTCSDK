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
    func changeRoom(info: VoiceRoomInfo)
    func refreshAnchorInfos()
    func onSeatMute(isMute: Bool)
    func onAnchorMute(isMute: Bool)
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?)
    func showActionSheet(actionTitles:[String], actions: @escaping (Int) -> Void)
    func refreshMsgView()
    func msgInput(show: Bool)
    func audiceneList(show: Bool)
    func audienceListRefresh()
    func showAudioEffectView()
    func stopPlayBGM() // 停止播放音乐
    func recoveryVoiceSetting() // 恢复音效设置
    func showBgMusicAlert()
    func showMoreAlert()
    func showAudienceAlert(seat: SeatInfoModel)
}

class TRTCVoiceRoomViewModel: NSObject {
    private let dependencyContainer: TRTCVoiceRoomEnteryControl
    private(set) var roomType: VoiceRoomViewType {
        didSet {
            roleChange(viewType: roomType)
        }
    }
    public weak var viewResponder: TRTCVoiceRoomViewResponder?
    var isOwner: Bool {
        return dependencyContainer.userId == roomInfo.ownerId
    }
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
    private(set) var memberAudienceDic: [String: AudienceInfoModel] = [:]
    public func getRealMemberAudienceList() -> [AudienceInfoModel] {
        var res : [AudienceInfoModel] = []
        for audience in memberAudienceList {
            if memberAudienceDic.keys.contains(audience.userInfo.userId) {
                res.append(audience)
            }
        }
        return res
    }
    
    public enum RoomUserType {
        case owner
        case anchor
        case audience
    }
    
    public var userType : RoomUserType = .audience
    
    private(set) var msgEntityList: [MsgEntity] = []
    /// 当前邀请操作的座位号记录
    private var currentInvitateSeatIndex: Int = -1 // -1 表示没有操作
    /// 上麦信息记录(观众端)
    private var mInvitationSeatDic: [String: Int] = [:]
    /// 上麦信息记录(主播端)
    private var mTakeSeatInvitationDic: [String: String] = [:]
    /// 抱麦信息记录
    private var mPickSeatInvitationDic: [String: SeatInvitation] = [:]
    
    public var userMuteMap : [String : Bool] = [:]
    
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
    
    public var voiceRoom: TRTCVoiceRoom {
        return dependencyContainer.getVoiceRoom()
    }
    
    lazy var effectViewModel: TRTCVoiceRoomSoundEffectViewModel = {
        return TRTCVoiceRoomSoundEffectViewModel(self)
    }()
    
    func exitRoom() {
        guard !isExitingRoom else { return }
        viewResponder?.popToPrevious()
        isExitingRoom = true
        if dependencyContainer.userId == roomInfo.ownerId && roomType == .anchor {
            voiceRoomManager.destroyRoom(sdkAppID: dependencyContainer.mSDKAppID, roomID: "\(roomInfo.roomID)", success: {
                TRTCLog.out("---deinit room success")
            }) { (code, message) in
                TRTCLog.out("---deinit room failed")
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
    
    public var voiceEarMonitor: Bool = false {
        willSet {
            self.voiceRoom.setVoiceEarMonitor(enable: newValue)
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
            viewResponder?.showToast(message: .seatmutedText)
            return false
        }
        isSelfMute = isMute
        voiceRoom.muteLocalAudio(mute: isMute)
        if isMute {
            viewResponder?.showToast(message: .micmutedText)
        } else {
            viewResponder?.recoveryVoiceSetting()
            viewResponder?.showToast(message: .micunmutedText)
        }
        return true
    }
    
    public func moreBtnClick() {
        viewResponder?.showMoreAlert()
    }
    
    public func spechAction(isMute: Bool) {
        voiceRoom.muteAllRemoteAudio(isMute: isMute)
        if isMute {
            viewResponder?.showToast(message: .mutedText)
        } else {
            viewResponder?.showToast(message: .unmutedText)
        }
    }
    
    public func clickSeat(model: SeatInfoModel) {
        guard isSeatInitSuccess else {
            viewResponder?.showToast(message: .seatuninitText)
            return
        }
        if roomType == .audience || dependencyContainer.userId != roomInfo.ownerId {
            audienceClickItem(model: model)
        } else {
            anchorClickItem(model: model)
        }
    }
    
    public func clickAudienceAgree(model: AudienceInfoModel) {
        
    }
    
    public func clickSeatLock(isLock: Bool, model: SeatInfoModel) {
        self.voiceRoom.closeSeat(seatIndex: model.seatIndex, isClose: isLock, callback: nil)
    }
    
    public func enterRoom(toneQuality: Int = VoiceRoomToneQuality.defaultQuality.rawValue) {
        voiceRoom.enterRoom(roomID: roomInfo.roomID) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: .enterSuccessText)
                self.voiceRoom.setAuidoQuality(quality: toneQuality)
                self.getAudienceList()
            } else {
                self.viewResponder?.showToast(message: .enterFailedText)
                self.viewResponder?.popToPrevious()
            }
        }
    }
    public func createRoom(toneQuality: Int = 0) {
        let faceUrl = ProfileManager.shared.curUserModel?.avatar ?? ""
        voiceRoom.setAuidoQuality(quality: toneQuality)
        voiceRoom.setSelfProfile(userName: roomInfo.ownerName, avatarURL: faceUrl) { [weak self] (code, message) in
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
                    self.viewResponder?.showToast(message: .createRoomFailedText)
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
        let entity = MsgEntity.init(userId: dependencyContainer.userId, userName: .meText, content: message, invitedId: "", type: MsgEntity.TYPE_NORMAL)
        notifyMsg(entity: entity)
        voiceRoom.sendRoomTextMsg(message: message) { [weak self] (code, message) in
            guard let `self` = self else { return }
            self.viewResponder?.showToast(message: code == 0 ? .sendSuccessText : String.sendFailedText.replacingOccurrences(of: "xxx", with: message))
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
        param.seatCount = 9
        param.seatInfoList = []
        for _ in 0..<param.seatCount {
            let seatInfo = VoiceRoomSeatInfo.init()
            param.seatInfoList.append(seatInfo)
        }
        voiceRoom.createRoom(roomID: Int32(roomInfo.roomID), roomParam: param) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.changeRoom(info: self.roomInfo)
                self.takeMainSeat()
                self.getAudienceList()
            } else {
                self.viewResponder?.showToast(message: .enterFailedText)
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
                self.userMuteMap[self.roomInfo.ownerId] = false
                self.viewResponder?.showToast(message: .cupySeatSuccessText)
            } else {
                self.viewResponder?.showToast(message: .cupySeatFailedText)
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
            viewResponder?.showToast(message: .onlyAnchorOperationText)
            return false
        }
        return true
    }
    
    private func roleChange(viewType: VoiceRoomViewType) {
        viewResponder?.switchView(type: viewType)
    }
    
    private func initAnchorListData() {
        for _ in 0...7 {
            var model = SeatInfoModel.init { [weak self] (seatIndex) in
                guard let `self` = self else { return }
                if seatIndex > 0 && seatIndex <= self.anchorSeatList.count {
                    let model = self.anchorSeatList[seatIndex - 1]
                    print("=====\(model.seatIndex)")
                    self.clickSeat(model: model)
                }
            }
            model.isOwner = dependencyContainer.userId == roomInfo.ownerId
            model.isClosed = false
            model.isUsed = false
            anchorSeatList.append(model)
        }
    }
    
    public func audienceClickMicoff(model: SeatInfoModel) {
        leaveSeat()
    }
    
    private func audienceClickItem(model: SeatInfoModel) {
        guard !model.isClosed else {
            viewResponder?.showToast(message: .seatLockedText)
            return
        }
        if model.isUsed {
            if dependencyContainer.userId == model.seatUser?.userId ?? "" {
                
            } else {
                viewResponder?.showToast(message: "\(model.seatUser?.userName ?? .otherAnchorText)")
            }
        } else {
            if mSelfSeatIndex != -1 {
                viewResponder?.showToast(message: LocalizeReplaceXX(.isInxxSeatText, String(mSelfSeatIndex)))
                return
            }
            guard model.seatIndex != -1 else {
                viewResponder?.showToast(message: .notInitText)
                return
            }
            // 没人:申请上麦
            viewResponder?.showActionSheet(actionTitles: [.handsupText], actions: { [weak self] (index) in
                guard let `self` = self else { return }
                self.startTakeSeat(seatIndex: model.seatIndex)
            })
        }
    }
    
    private func anchorClickItem(model: SeatInfoModel) {
        if model.isUsed {
            // 弹出禁言， 踢人
            let isMute = model.seatInfo?.mute ?? false
            viewResponder?.showActionSheet(actionTitles: [LocalizeReplaceXX(.totaxxText, (isMute ? String.unmuteOneText : String.muteOneText)), .makeAudienceText], actions: { [weak self] (index) in
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
        viewResponder?.showAudienceAlert(seat: model)
        currentInvitateSeatIndex = model.seatIndex
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
            viewResponder?.showToast(message: .seatBusyText)
            return
        }
        let seatInvitation = SeatInvitation.init(seatIndex: currentInvitateSeatIndex, inviteUserId: userInfo.userId)
        let inviteId = voiceRoom.sendInvitation(cmd: VoiceRoomConstants.CMD_PICK_UP_SEAT,
                                                userId: seatInvitation.inviteUserId,
                                                content: "\(seatInvitation.seatIndex)") { [weak self] (code, message) in
                                                    guard let `self` = self else { return }
                                                    if code == 0 {
                                                        self.viewResponder?.showToast(message: .sendInviteSuccessText)
                                                    }
        }
        mPickSeatInvitationDic[inviteId] = seatInvitation
        viewResponder?.audiceneList(show: false)
    }
    
    private func acceptTakeSeatInviattion(userInfo: VoiceRoomUserInfo) {
        // 接受
        guard let inviteID = mTakeSeatInvitationDic[userInfo.userId] else {
            viewResponder?.showToast(message: .reqExpiredText)
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
                self.viewResponder?.showToast(message: .acceptReqFailedText)
            }
        }
    }
    
    private func leaveSeat() {
        voiceRoom.leaveSeat { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: .audienceSuccessText)
            } else {
                self.viewResponder?.showToast(message: LocalizeReplaceXX(.audienceFailedxxText, message))
            }
        }
    }
    
    /// 观众开始上麦
    /// - Parameter seatIndex: 上的作为号
    private func startTakeSeat(seatIndex: Int) {
        if roomType == .anchor {
            viewResponder?.showToast(message: .beingArchonText)
            return
        }
        if roomInfo.needRequest {
            // 需要申请上麦
            guard roomInfo.ownerId != "" else {
                viewResponder?.showToast(message: .roomNotReadyText)
                return
            }
            let cmd = VoiceRoomConstants.CMD_REQUEST_TAKE_SEAT
            let targetUserId = roomInfo.ownerId
            let inviteId = voiceRoom.sendInvitation(cmd: cmd, userId: targetUserId, content: "\(seatIndex)") { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    self.viewResponder?.showToast(message: .reqSentText)
                } else {
                    self.viewResponder?.showToast(message: LocalizeReplaceXX(.reqSendFailedxxText, message))
                }
            }
            mInvitationSeatDic[inviteId] = seatIndex
        } else {
            // 不需要的情况下自动上麦
            voiceRoom.enterSeat(seatIndex: seatIndex) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    self.viewResponder?.showToast(message: .handsupSuccessText)
                } else {
                    self.viewResponder?.showToast(message: .handsupFailedText)
                }
            }
        }
    }
    
    private func recvPickSeat(identifier: String, cmd: String, content: String) {
        guard let seatIndex = Int.init(content) else { return }
        viewResponder?.showAlert(info: (title: .alertText, message: LocalizeReplaceXX(.invitexxSeatText, String(seatIndex))), sureAction: { [weak self] in
            guard let `self` = self else { return }
            self.voiceRoom.acceptInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code != 0 {
                    self.viewResponder?.showToast(message: .acceptReqFailedText)
                }
            }
        }, cancelAction: { [weak self] in
            guard let `self` = self else { return }
            self.voiceRoom.rejectInvitation(identifier: identifier) { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.viewResponder?.showToast(message: .refuseHandsupText)
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
        let content = LocalizeReplaceXX(.applyxxSeatText, String(seatIndex))
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
    
    private func showNotifyMsg(messsage: String, userName: String) {
        let msgEntity = MsgEntity.init(userId: "", userName: userName, content: messsage, invitedId: "", type: MsgEntity.TYPE_NORMAL)
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
            }
        }
        viewResponder?.audienceListRefresh()
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
        viewResponder?.showToast(message: .closeRoomText)
        voiceRoom.exitRoom(callback: nil)
        viewResponder?.popToPrevious()
    }
    
    func onRoomInfoChange(roomInfo: VoiceRoomInfo) {
        // 值为-1表示该接口没有返回数量信息
        if roomInfo.memberCount == -1 {
            roomInfo.memberCount = self.roomInfo.memberCount
        }
        self.roomInfo = roomInfo
        viewResponder?.changeRoom(info: self.roomInfo)
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
            if seatIndex == 0 {
                let mute = masterAnchor?.seatInfo?.mute ?? false
                anchorSeatInfo.seatInfo?.mute = mute
            }
            else {
                let mute = anchorSeatList[seatIndex-1].seatInfo?.mute ?? false
                anchorSeatInfo.seatInfo?.mute = mute
            }
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
                if self.masterAnchor?.seatUser == nil, !self.userMuteMap.keys.contains(seatInfoList[0].userId) {
                    self.userMuteMap[seatInfoList[0].userId] = true
                }
                self.masterAnchor?.seatUser = userdic[seatInfoList[0].userId]
            } else {
                return
            }
            if self.anchorSeatList.count != seatInfoList.count - 1 {
                TRTCLog.out(String.seatlistWrongText)
                return
            }
            // 修改座位列表的user信息
            for index in 0..<self.anchorSeatList.count {
                let seatInfo = seatInfoList[index + 1] // 从观众开始更新
                if self.anchorSeatList[index].seatUser == nil, let user = userdic[seatInfo.userId], !self.userMuteMap.keys.contains(user.userId) {
                    self.userMuteMap[user.userId] = true
                }
                self.anchorSeatList[index].seatUser = userdic[seatInfo.userId]
            }
            self.viewResponder?.refreshAnchorInfos()
            self.viewResponder?.onAnchorMute(isMute: false)
        }
    }
    
    func onAnchorEnterSeat(index: Int, user: VoiceRoomUserInfo) {
        if index == 0{
            // 房主上麦就不提醒了
            return;
        }
        showNotifyMsg(messsage: LocalizeReplace(.beyySeatText, "xxx", String(index)), userName: user.userName)
        if user.userId == dependencyContainer.userId {
            roomType = .anchor
            mSelfSeatIndex = index
            viewResponder?.recoveryVoiceSetting() // 自己上麦，恢复音效设置
        }
        userMuteMap[user.userId] = false
        changeAudience(status: AudienceInfoModel.TYPE_IN_SEAT, user: user)
    }
    
    func onAnchorLeaveSeat(index: Int, user: VoiceRoomUserInfo) {
        if index == 0{
            // 房主下麦就不提醒了
            return;
        }
        showNotifyMsg(messsage: LocalizeReplace(.audienceyySeatText, "xxx", String(index)), userName: user.userName)
        if user.userId == dependencyContainer.userId {
            roomType = .audience
            mSelfSeatIndex = -1
            // 自己下麦，停止音效播放
            viewResponder?.stopPlayBGM()
        }
        if !memberAudienceDic.keys.contains(user.userId) {
            for model in memberAudienceList {
                if model.userInfo.userId == user.userId {
                    memberAudienceDic[user.userId] = model
                    break
                }
            }
        }
        changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: user)
    }
    
    func onSeatMute(index: Int, isMute: Bool) {
        debugPrint("seat \(index) is mute : \(isMute ? "true" : "false")")
        if isMute {
            showNotifyMsg(messsage: LocalizeReplaceXX(.bemutedxxText, String(index)), userName: "")
        } else {
            showNotifyMsg(messsage: LocalizeReplaceXX(.beunmutedxxText, String(index)), userName: "")
        }
        if index > 0 && index <= anchorSeatList.count {
            anchorSeatList[index-1].seatInfo?.mute = isMute
        }
        if mSelfSeatIndex == index {
            isOwnerMute = isMute
            viewResponder?.onSeatMute(isMute: isMute)
        }
        viewResponder?.onAnchorMute(isMute: isMute)
    }
    
    func onUserMicrophoneMute(userId: String, mute: Bool) {
        userMuteMap[userId] = mute
        viewResponder?.onAnchorMute(isMute: mute)
    }
    
    func onSeatClose(index: Int, isClose: Bool) {
        showNotifyMsg(messsage: LocalizeReplace(.ownerxxSeatText, isClose ? .banSeatText : .unmuteOneText, String(index)), userName: "")
    }
    
    func onAudienceEnter(userInfo: VoiceRoomUserInfo) {
        showNotifyMsg(messsage: LocalizeReplaceXX(.inRoomText, "xxx"), userName: userInfo.userName)
        // 主播端(房主)
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
        }
        viewResponder?.audienceListRefresh()
        changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: userInfo)
    }
    
    func onAudienceExit(userInfo: VoiceRoomUserInfo) {
        showNotifyMsg(messsage: LocalizeReplaceXX(.exitRoomText, "xxx"), userName: userInfo.userName)
        memberAudienceList.removeAll { (model) -> Bool in
            return model.userInfo.userId == userInfo.userId
        }
        memberAudienceDic.removeValue(forKey: userInfo.userId)
        viewResponder?.refreshAnchorInfos()
        viewResponder?.audienceListRefresh()
        changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: userInfo)
    }
    
    func onUserVolumeUpdate(userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        var volumeDic: [String: UInt] = [:]
        userVolumes.forEach { (info) in
            if let userId = info.userId {
                volumeDic[userId] = info.volume
            } else {
                volumeDic[dependencyContainer.userId] = info.volume
            }
        }
        var needRefreshUI = false
        if let master = masterAnchor, let userId = master.seatUser?.userId {
            let newIsTalking = (volumeDic[userId] ?? 0) > 25
            if master.isTalking != newIsTalking {
                masterAnchor?.isTalking = newIsTalking
                needRefreshUI = true
            }
        }
        
        for (index, seat) in self.anchorSeatList.enumerated() {
            if let user = seat.seatUser {
                let isTalking = (volumeDic[user.userId] ?? 0) > 25
                if seat.isTalking != isTalking {
                    self.anchorSeatList[index].isTalking = isTalking
                    needRefreshUI = true
                }
            }
        }
        
        if needRefreshUI {
            viewResponder?.refreshAnchorInfos()
        }
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
                        self.viewResponder?.showToast(message: .handsupSuccessText)
                    } else {
                        self.viewResponder?.showToast(message: .handsupFailedText)
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
                        self.viewResponder?.showToast(message: LocalizeReplaceXX(.hugHandsupSuccessText, invitee))
                    }
                }
            }
        }
    }
    
    func onInviteeRejected(identifier: String, invitee: String) {
        if let seatInvitation = mPickSeatInvitationDic.removeValue(forKey: identifier) {
            guard let audience = memberAudienceDic[seatInvitation.inviteUserId] else { return }
            viewResponder?.showToast(message: LocalizeReplaceXX(.refuseBespeakerText, audience.userInfo.userName))
            changeAudience(status: AudienceInfoModel.TYPE_IDEL, user: audience.userInfo)
        }
        
    }
    
    func onInvitationCancelled(identifier: String, invitee: String) {
        
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let seatmutedText = TRTCLocalize("Demo.TRTC.VoiceRoom.onseatmuted")
    static let micmutedText = TRTCLocalize("Demo.TRTC.Salon.micmuted")
    static let micunmutedText = TRTCLocalize("Demo.TRTC.Salon.micunmuted")
    static let mutedText = TRTCLocalize("Demo.TRTC.VoiceRoom.ismuted")
    static let unmutedText = TRTCLocalize("Demo.TRTC.VoiceRoom.isunmuted")
    static let seatuninitText = TRTCLocalize("Demo.TRTC.Salon.seatlistnotinit")
    static let enterSuccessText = TRTCLocalize("Demo.TRTC.Salon.enterroomsuccess")
    static let enterFailedText = TRTCLocalize("Demo.TRTC.Salon.enterroomfailed")
    static let createRoomFailedText = TRTCLocalize("Demo.TRTC.LiveRoom.createroomfailed")
    static let meText = TRTCLocalize("Demo.TRTC.LiveRoom.me")
    static let sendSuccessText = TRTCLocalize("Demo.TRTC.VoiceRoom.sendsuccess")
    static let sendFailedText = TRTCLocalize("Demo.TRTC.VoiceRoom.sendfailedxx")
    static let cupySeatSuccessText = TRTCLocalize("Demo.TRTC.Salon.hostoccupyseatsuccess")
    static let cupySeatFailedText = TRTCLocalize("Demo.TRTC.Salon.hostoccupyseatfailed")
    static let onlyAnchorOperationText = TRTCLocalize("Demo.TRTC.VoiceRoom.onlyanchorcanoperation")
    static let seatLockedText = TRTCLocalize("Demo.TRTC.VoiceRoom.seatislockedandcanthandup")
    static let audienceText = TRTCLocalize("Demo.TRTC.Salon.audience")
    static let otherAnchorText = TRTCLocalize("Demo.TRTC.VoiceRoom.otheranchor")
    static let isInxxSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.isinxxseat")
    static let notInitText = TRTCLocalize("Demo.TRTC.VoiceRoom.seatisnotinittocanthandsup")
    static let handsupText = TRTCLocalize("Demo.TRTC.Salon.handsup")
    static let totaxxText = TRTCLocalize("Demo.TRTC.VoiceRoom.totaxx")
    static let unmuteOneText = TRTCLocalize("Demo.TRTC.VoiceRoom.unmuteone")
    static let muteOneText = TRTCLocalize("Demo.TRTC.VoiceRoom.muteone")
    static let makeAudienceText = TRTCLocalize("Demo.TRTC.VoiceRoom.makeoneaudience")
    static let inviteHandsupText = TRTCLocalize("Demo.TRTC.VoiceRoom.invitehandsup")
    static let banSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.banseat")
    static let liftbanSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.liftbanseat")
    static let seatBusyText = TRTCLocalize("Demo.TRTC.VoiceRoom.seatisbusy")
    static let sendInviteSuccessText = TRTCLocalize("Demo.TRTC.VoiceRoom.sendinvitesuccess")
    static let reqExpiredText = TRTCLocalize("Demo.TRTC.Salon.reqisexpired")
    static let acceptReqFailedText = TRTCLocalize("Demo.TRTC.Salon.acceptreqfailed")
    static let audienceSuccessText = TRTCLocalize("Demo.TRTC.Salon.audiencesuccess")
    static let audienceFailedxxText = TRTCLocalize("Demo.TRTC.Salon.audiencefailedxx")
    static let beingArchonText = TRTCLocalize("Demo.TRTC.Salon.isbeingarchon")
    static let roomNotReadyText = TRTCLocalize("Demo.TRTC.Salon.roomnotready")
    static let reqSentText = TRTCLocalize("Demo.TRTC.VoiceRoom.reqsentandwaitforarchondeal")
    static let reqSendFailedxxText = TRTCLocalize("Demo.TRTC.VoiceRoom.reqsendfailedxx")
    static let handsupSuccessText = TRTCLocalize("Demo.TRTC.Salon.successbecomespaker")
    static let handsupFailedText = TRTCLocalize("Demo.TRTC.Salon.failedbecomespaker")
    
    static let alertText = TRTCLocalize("Demo.TRTC.LiveRoom.prompt")
    static let invitexxSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.anchorinvitexxseat")
    static let refuseHandsupText = TRTCLocalize("Demo.TRTC.VoiceRoom.refusehandsupreq")
    static let applyxxSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.applyforxxseat")
    static let closeRoomText = TRTCLocalize("Demo.TRTC.Salon.archonclosedroom")
    static let seatlistWrongText = TRTCLocalize("Demo.TRTC.VoiceRoom.seatlistwentwrong")
    static let beyySeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxbeyyseat")
    static let audienceyySeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxaudienceyyseat")
    static let bemutedxxText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxisbemuted")
    static let beunmutedxxText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxisbeunmuted")
    static let ownerxxSeatText = TRTCLocalize("Demo.TRTC.VoiceRoom.ownerxxyyseat")
    static let banText = TRTCLocalize("Demo.TRTC.VoiceRoom.ban")
    static let inRoomText = TRTCLocalize("Demo.TRTC.LiveRoom.xxinroom")
    static let exitRoomText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxexitroom")
    static let hugHandsupSuccessText = TRTCLocalize("Demo.TRTC.VoiceRoom.hugxxhandsupsuccess")
    static let refuseBespeakerText = TRTCLocalize("Demo.TRTC.VoiceRoom.refusebespeaker")
}
