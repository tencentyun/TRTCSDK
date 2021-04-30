//
//  TRTCChatSalonViewModel.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

protocol TRTCChatSalonViewResponder: class {
    func showToast(message: String)
    func popToPrevious()
    func switchView(type: ChatSalonViewType)
    func changeRoom(title: String)
    func refreshAnchorInfos()
    func onSeatMute(isMute: Bool)
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?)
    func showActionSheet(actionTitles:[String], actions: @escaping (Int) -> Void)
    func refreshTakeSeatList()
    func showRequestTakeSeatTips(request: CSMemberRequestEntity?)
    func showHandUpTips(isShow: Bool)
    func msgInput(show: Bool)
    func reuqestTakeSeatList(show: Bool)
    func audienceListRefresh()
    func showAudioEffectView()
    func stopPlayBGM() // 停止播放音乐
    func recoveryVoiceSetting() // 恢复音效设置
}

class TRTCChatSalonViewModel: NSObject {
    private let dependencyContainer: TRTCChatSalonEnteryControl
    private(set) var roomType: ChatSalonViewType {
        didSet {
            roleChange(viewType: roomType)
        }
    }
    public weak var viewResponder: TRTCChatSalonViewResponder?
    
    private(set) var isSelfMute: Bool = false
    // 防止多次退房
    private var isExitingRoom: Bool = false
    
    private(set) var roomInfo: ChatSalonInfo
//    private(set) var isSeatInitSuccess: Bool = false
    private(set) var mSelfSeatIndex: Int = -1
    private(set) var isOwnerMute: Bool = false
    /// 是否是房主
    public var isOwner: Bool {
        return dependencyContainer.userID == roomInfo.ownerId // 是否是房主
    }
    
    // UI相关属性
    private(set) var masterAnchor: ChatSalonSeatInfoModel?
    private(set) var anchorUserIDs: [String] = []
    private(set) var anchorSeatList: [String : ChatSalonSeatInfoModel] = [:]
    /// 观众信息记录
    private(set) var memberAudienceDic: [String: CSAudienceInfoModel] = [:]
    private(set) var audienceUserIDs: [String] = []
    /// 上麦申请记录
    var requestTakeSeatMap: [String: CSMemberRequestEntity] = [:]
    /// 是否举手
    public var isHandUp: Bool = false
    
    private(set) var msgEntityList: [CSMsgEntity] = []
    /// 当前邀请操作的座位号记录
    private var currentInvitateSeatIndex: Int = -1 // -1 表示没有操作
    private var currentRequestTipsEntity: CSMemberRequestEntity? // 当前tips
    /// 上麦信息记录(观众端)
    private var mInvitationSeatDic: [String: Int] = [:]
    /// 上麦信息记录(主播端)
    private var mTakeCSSeatInvitationDic: [String: String] = [:]
    /// 抱麦信息记录
    private var mPickCSSeatInvitationDic: [String: CSSeatInvitation] = [:]
    
    
    /// 房间管理对象
    private var chatSalonManager: TRTCChatSalonManager {
        return TRTCChatSalonManager.shared
    }
    
    /// 初始化方法
    /// - Parameter container: 依赖管理容器，负责ChatSalon模块的依赖管理
    init(container: TRTCChatSalonEnteryControl, roomInfo: ChatSalonInfo, roomType: ChatSalonViewType) {
        self.dependencyContainer = container
        self.roomType = roomType
        self.roomInfo = roomInfo
        super.init()
        chatSalon.setDelegate(delegate: self)
        roleChange(viewType: self.roomType)
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    private var chatSalon: TRTCChatSalon {
        return dependencyContainer.getChatSalon()
    }
    
    func exitRoom() {
        guard !isExitingRoom else { return }
        viewResponder?.popToPrevious()
        isExitingRoom = true
        if dependencyContainer.userID == roomInfo.ownerId && roomType == .anchor {
            chatSalonManager.destroyRoom(sdkAppID: dependencyContainer.mSDKAppID, roomID: "\(roomInfo.roomID)", success: {
                TRTCLog.out("---destroy room success.")
            }) { (code, message) in
                TRTCLog.out("---destroy room failed.")
            }
            chatSalon.destroyRoom { [weak self] (code, message) in
                guard let `self` = self else { return }
                self.isExitingRoom = false
            }
            return
        }
        chatSalon.exitRoom { [weak self] (code, message) in
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
    
    public func openRequestTakeSeatList(isOpen: Bool) {
        viewResponder?.reuqestTakeSeatList(show:isOpen)
    }
    
    public func muteAction(isMute: Bool, needShowToast: Bool = true) -> Bool {
        guard checkButtonPermission() else { return false }
        isSelfMute = isMute
        chatSalon.muteLocalAudio(mute: isMute)
        if isMute {
            viewResponder?.stopPlayBGM()
            if needShowToast {
                viewResponder?.showToast(message: .closedMicText)
            }
        } else {
            viewResponder?.recoveryVoiceSetting()
            if needShowToast {
                viewResponder?.showToast(message: .openedMicText)
            }
        }
        return true
    }
    
    public func spechAction(isMute: Bool) {

    }
    
    public func clickSeat(model: ChatSalonSeatInfoModel) {
        if roomType == .audience || !isOwner {
            audienceClickItem(model: model)
        } else {
            anchorClickItem(model: model)
        }
    }
    
    public func leaveSeatAction() {
        guard !isOwner else { return }
        leaveSeat() // 下麦
    }
    
    public func enterRoom(toneQuality: Int = ChatSalonToneQuality.music.rawValue) {
        chatSalon.enterRoom(roomID: roomInfo.roomID) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: .enterRoomSuccText)
                self.getAudienceList()
                self.chatSalon.setAuidoQuality(quality: toneQuality)
            } else {
                self.viewResponder?.showToast(message: .enterRoomFailText)
                self.viewResponder?.popToPrevious()
            }
        }
    }
    
    public func createRoom(toneQuality: Int = 0) {
        var coverUrl = roomInfo.coverUrl
        if !coverUrl.hasPrefix("http") {
            coverUrl = ProfileManager.shared.curUserModel?.avatar ?? ""
        }
        chatSalon.setAuidoQuality(quality: toneQuality)
        chatSalon.setSelfProfile(userName: roomInfo.ownerName, avatarURL: coverUrl) { [weak self] (code, message) in
            guard let `self` = self else { return }
            TRTCLog.out("setSelfProfile\(code)\(message)")
            TRTCChatSalonManager.shared.createRoom(sdkAppID: SDKAPPID, roomID: "\(self.roomInfo.roomID)", success: { [weak self] in
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
    
    public func onTextMsgSend(message: String) { }
    
    /// 同意上麦
    /// - Parameter identifier: 上麦的id
    public func acceptTakeSeat(identifier: String) {
        if let audience = memberAudienceDic[identifier] {
            acceptTakeSeatInviattion(userInfo: audience.userInfo)
        }
    }
    
    public func hideRequestTakeSeatTipsView() {
        currentRequestTipsEntity = nil
        viewResponder?.showRequestTakeSeatTips(request: nil)
    }
    
    /// 观众开始上麦
    public func startTakeSeat(seatIndex: Int) {
        if roomType == .anchor {
            viewResponder?.showToast(message: .alreadyIsAnchorText)
            return
        }
        
        // 需要申请上麦
        guard roomInfo.ownerId != "" else {
            viewResponder?.showToast(message: .roomNotReadyText)
            return
        }
        guard !isHandUp else {
            viewResponder?.showToast(message: .waitHostAcceptText)
            return
        }
        self.isHandUp = true
        let cmd = ChatSalonConstants.CMD_REQUEST_TAKE_SEAT
        let targetUserId = roomInfo.ownerId
        let inviteId = chatSalon.sendInvitation(cmd: cmd, userID: targetUserId, content: "\(seatIndex)") { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showHandUpTips(isShow: true)
            } else {
                if (code == ChatSalonErrorCode.inviteLimited.rawValue) {
                    self.viewResponder?.showToast(message: String.inviteLimitedText)
                } else {
                    self.viewResponder?.showToast(message: "\(String.takeSeatSendFailed)\(message)")
                }
                self.isHandUp = false
            }
        }
        mInvitationSeatDic[inviteId] = seatIndex
    }
}

// MARK: - private method
extension TRTCChatSalonViewModel {
    
    private func internalCreateRoom() {
        let param = ChatSalonParam.init()
        param.roomName = roomInfo.roomName
        param.needRequest = roomInfo.needRequest
        param.coverUrl = roomInfo.coverUrl
        param.seatInfoList = []
        chatSalon.createRoom(roomID: Int32(roomInfo.roomID), roomParam: param) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.changeRoom(title: "\(self.roomInfo.roomName)(\(self.roomInfo.roomID))")
                self.getAudienceList()
            } else {
                self.viewResponder?.showToast(message: .enterRoomFailText)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let `self` = self else { return }
                    self.viewResponder?.popToPrevious()
                }
            }
        }
    }
    
    private func getAudienceList() {
        chatSalon.getUserInfoList(userIDList: nil) { [weak self] (code, message, infos) in
            guard let `self` = self else { return }
            if code == 0 {
                self.memberAudienceDic.removeAll()
                let audienceInfoModels = infos.map { (userInfo) -> CSAudienceInfoModel in
                    return CSAudienceInfoModel.init(userInfo: userInfo) { [weak self] (index) in
                        // 点击邀请上麦事件，以及接受邀请事件
                        guard let `self` = self else { return }
                        if index == 0 {
                            self.sendInvitation(userInfo: userInfo)
                        } else {
                            self.acceptTakeSeatInviattion(userInfo: userInfo)
                        }
                    }
                }.filter { (model) -> Bool in
                    return !self.anchorUserIDs.contains(model.userInfo.userID)
                }
                audienceInfoModels.forEach { (info) in
                    self.memberAudienceDic[info.userInfo.userID] = info
                }
                self.handleAudienceListChanged()
            }
        }
    }
    
    func checkButtonPermission() -> Bool {
        if roomType == .audience {
            viewResponder?.showToast(message: .onlyAnchorUse)
            return false
        }
        return true
    }
    
    private func roleChange(viewType: ChatSalonViewType) {
        viewResponder?.switchView(type: viewType)
    }
    
    private func audienceClickItem(model: ChatSalonSeatInfoModel) {
       // TODO: audience click item action.
    }
    
    private func anchorClickItem(model: ChatSalonSeatInfoModel) {
        guard !model.isOwner else { return }
        if model.isUsed {
            viewResponder?.showActionSheet(actionTitles: [.kickOutMicText], actions: { [weak self] (index) in
                guard let `self` = self,let userID = model.seatUser?.userID else { return }
                if index == 0 {
                    // 下麦
                    self.chatSalon.kickSeat(userID: userID, callback: nil)
                }
            })
            return
        }
    }
    
    private func onAnchorSeatSelected(seatIndex: Int) {
        viewResponder?.reuqestTakeSeatList(show: true)
        currentInvitateSeatIndex = seatIndex
    }
    
    private func sendInvitation(userInfo: ChatSalonUserInfo) {
        // TODO: - invitation someone on mic.
    }
    
    private func acceptTakeSeatInviattion(userInfo: ChatSalonUserInfo) {
        // 接受
        guard let inviteID = mTakeCSSeatInvitationDic[userInfo.userID] else {
            viewResponder?.showToast(message: .inviatttionTimeoutText)
            return
        }
        chatSalon.acceptInvitation(identifier: inviteID) { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                // 接受请求成功，刷新外部对话列表
                self.requestTakeSeatMap.removeValue(forKey: userInfo.userID)
                self.viewResponder?.refreshTakeSeatList()
            } else {
                self.viewResponder?.showToast(message: .acceptInvitationFailed)
            }
        }
    }
    
    private func leaveSeat() {
        chatSalon.leaveSeat { [weak self] (code, message) in
            guard let `self` = self else { return }
            if code == 0 {
                self.viewResponder?.showToast(message: .leaveSeatSuccText)
            } else {
                self.viewResponder?.showToast(message: "\(String.leaveSeatFailedText)\(message)")
            }
        }
    }
    
    private func recvPickSeat(identifier: String, cmd: String, content: String) {
        // TODO: recvice pick seat.
    }
    
    private func recvTakeSeat(identifier: String, inviter: String, content: String) {
        let audinece = memberAudienceDic[inviter]
        // 收到新的邀请后，更新列表,其他的信息
        if let memberEntity = requestTakeSeatMap[inviter] {
            // 已经在申请上麦了, 更新请求ID
            var newEntity = memberEntity
            newEntity.invitedId = identifier
            requestTakeSeatMap[inviter] = newEntity
        } else {
            if let userInfo = audinece?.userInfo {
                let msgEntity = CSMemberRequestEntity.init(userID: inviter, userInfo: userInfo, content: "", invitedId: identifier, type: CSMemberRequestEntity.TYPE_WAIT_AGREE) { [weak self] (index) in
                    guard let `self` = self else { return }
                    guard index == 0 else { return }
                    if let currentTips = self.currentRequestTipsEntity {
                        if currentTips.userID == userInfo.userID {
                            self.hideRequestTakeSeatTipsView()
                        }
                    }
                    self.acceptTakeSeat(identifier: userInfo.userID)
                    self.openRequestTakeSeatList(isOpen: false)
                }
                requestTakeSeatMap[inviter] = msgEntity
                currentRequestTipsEntity = msgEntity
                viewResponder?.showRequestTakeSeatTips(request: msgEntity)
            }
        }
        viewResponder?.refreshTakeSeatList()
        if var audienceModel = audinece {
            audienceModel.type = CSAudienceInfoModel.TYPE_WAIT_AGREE
            memberAudienceDic[audienceModel.userInfo.userID] = audienceModel
            handleAudienceListChanged()
        }
        mTakeCSSeatInvitationDic[inviter] = identifier
    }
    
    private func notifyMsg(entity: CSMsgEntity) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.msgEntityList.count > 1000 {
                self.msgEntityList.removeSubrange(0...99)
            }
            self.msgEntityList.append(entity)
            self.viewResponder?.refreshTakeSeatList()
        }
    }
    
    private func showNotifyMsg(messsage: String) {
        let msgEntity = CSMsgEntity.init(userID: "", userName: "", content: messsage, invitedId: "", type: CSMsgEntity.TYPE_NORMAL)
        if msgEntityList.count > 1000 {
            msgEntityList.removeSubrange(0...99)
        }
        msgEntityList.append(msgEntity)
        viewResponder?.refreshTakeSeatList()
    }
    
    private func changeAudience(status: Int, user: ChatSalonUserInfo) {
        guard [CSAudienceInfoModel.TYPE_IDEL, CSAudienceInfoModel.TYPE_IN_SEAT, CSAudienceInfoModel.TYPE_WAIT_AGREE].contains(status) else { return }
        let audience = memberAudienceDic[user.userID]
        if status == CSAudienceInfoModel.TYPE_IN_SEAT {
            memberAudienceDic.removeValue(forKey: user.userID)
        } else {
            if var audienceModel = audience {
                if audienceModel.type == status { return }
                audienceModel.type = status
                memberAudienceDic[audienceModel.userInfo.userID] = audienceModel
            } else {
                if status != CSAudienceInfoModel.TYPE_IN_SEAT {
                    let audienceModel = CSAudienceInfoModel.init(type: status, userInfo: user) { (index) in
                        
                    }
                    memberAudienceDic[user.userID] = audienceModel
                }
            }
        }
        handleAudienceListChanged()
    }
    
    private func handleAudienceListChanged() {
        audienceUserIDs = memberAudienceDic.keys.sorted(by: <)
        viewResponder?.audienceListRefresh()
    }
}

// MARK:- room delegate
extension TRTCChatSalonViewModel: TRTCChatSalonDelegate {
    func onError(code: Int32, message: String) {
        
    }
    
    func onWarning(code: Int32, message: String) {
        
    }
    
    func onDebugLog(message: String) {
        
    }
    
    func onRoomDestroy(message: String) {
        viewResponder?.showToast(message: .hostDestroyRoomText)
        chatSalon.exitRoom(callback: nil)
        viewResponder?.popToPrevious()
    }
    
    func onRoomInfoChange(roomInfo: ChatSalonInfo) {
        // 值为-1表示该接口没有返回数量信息
        if roomInfo.memberCount == -1 {
            roomInfo.memberCount = self.roomInfo.memberCount
        }
        self.roomInfo = roomInfo
        viewResponder?.changeRoom(title: "\(roomInfo.roomName)(\(roomInfo.roomID))")
    }
    
    func onAnchorEnterSeat(user: ChatSalonUserInfo) {
        if user.userID == roomInfo.ownerId {
            // 房主上麦就不提醒了
            if self.masterAnchor == nil {
                self.masterAnchor = ChatSalonSeatInfoModel.init { [weak self] (model) in
                    guard let `self` = self else { return }
                    self.clickSeat(model: model)
                }
            }
            self.masterAnchor?.isUsed = true
            self.masterAnchor?.seatUser = user
            self.masterAnchor?.isOwner = true
            let anchorSeatInfo = ChatSalonSeatInfo.init()
            anchorSeatInfo.userID = user.userID
            self.masterAnchor?.seatInfo = anchorSeatInfo
            self.viewResponder?.refreshAnchorInfos()
            return;
        }
        showNotifyMsg(messsage: "\(user.userName)\(String.enterSeatText)")
        if user.userID == dependencyContainer.userID {
            roomType = .anchor
        }
        if anchorSeatList[user.userID] == nil {
            var anchorSeatInfo = ChatSalonSeatInfoModel.init { [weak self] (model) in
                guard let `self` = self else { return }
                self.clickSeat(model: model)
            }
            let seatInfo = ChatSalonSeatInfo.init()
            seatInfo.mute = true
            seatInfo.userID = user.userID
            anchorSeatInfo.seatInfo = seatInfo
            anchorSeatInfo.seatUser = user
            anchorSeatInfo.isUsed = true
            anchorSeatList[user.userID] = anchorSeatInfo
            anchorUserIDs.append(user.userID)
            self.viewResponder?.refreshAnchorInfos()
        }
        changeAudience(status: CSAudienceInfoModel.TYPE_IN_SEAT, user: user)
    }
    
    func onAnchorLeaveSeat(user: ChatSalonUserInfo) {
        if user.userID == roomInfo.ownerId {
            // 房主下麦就不提醒了
            return;
        }
        if anchorSeatList[user.userID] != nil {
            anchorSeatList.removeValue(forKey: user.userID)
            if let index = anchorUserIDs.firstIndex(of: user.userID) {
                anchorUserIDs.remove(at: index)
            }
            self.viewResponder?.refreshAnchorInfos()
        }
        showNotifyMsg(messsage: "\(user.userName)\(String.leaveSeatText)")
        if user.userID == dependencyContainer.userID {
            roomType = .audience
            // 自己下麦，停止音效播放
            viewResponder?.stopPlayBGM()
        }
        changeAudience(status: CSAudienceInfoModel.TYPE_IDEL, user: user)
    }
    
    func onSeatMute(userID: String, isMute: Bool) {
        // TODO: user mute UI action. in seatInfoChange recv.
        if userID == self.masterAnchor?.seatUser?.userID {
            self.masterAnchor?.seatInfo?.mute = isMute
            viewResponder?.refreshAnchorInfos()
            return
        }
        guard let seatInfo = anchorSeatList[userID] else {
            return
        }
        if seatInfo.seatInfo?.mute != isMute {
            seatInfo.seatInfo?.mute = isMute
            anchorSeatList[userID] = seatInfo
            viewResponder?.refreshAnchorInfos()
        }
    }
    
    func onAudienceEnter(userInfo: ChatSalonUserInfo) {
        if userInfo.userID == roomInfo.ownerId {
            return;
        }
        showNotifyMsg(messsage: "\(userInfo.userName)进房")
        let memberEntityModel = CSAudienceInfoModel.init(type: 0, userInfo: userInfo) { [weak self] (index) in
            guard let `self` = self else { return }
            if index == 0 {
                self.sendInvitation(userInfo: userInfo)
            } else {
                self.acceptTakeSeatInviattion(userInfo: userInfo)
                self.viewResponder?.reuqestTakeSeatList(show: false)
            }
        }
        if !memberAudienceDic.keys.contains(userInfo.userID) && !anchorUserIDs.contains(userInfo.userID) {
            memberAudienceDic[userInfo.userID] = memberEntityModel
            handleAudienceListChanged()
        }
        
    }
    
    func onAudienceExit(userInfo: ChatSalonUserInfo) {
        memberAudienceDic.removeValue(forKey: userInfo.userID)
        handleAudienceListChanged()
    }
    
    func onUserVolumeUpdate(userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        var volumeDic: [String: UInt] = [:]
        userVolumes.forEach { (info) in
            if let userId = info.userId {
                volumeDic[userId] = info.volume
            } else {
                volumeDic[dependencyContainer.userID] = info.volume
            }
        }
        var needRefreshUI = false
        if let master = masterAnchor, let userId = master.seatUser?.userID {
            let newIsTalking = (volumeDic[userId] ?? 0) > 25
            if master.isTalking != newIsTalking {
                masterAnchor?.isTalking = newIsTalking
                needRefreshUI = true
            }
        }
        for userId in self.anchorSeatList.keys {
            let isTalking = (volumeDic[userId] ?? 0) > 25
            if let orgIsTalking = self.anchorSeatList[userId]?.isTalking, orgIsTalking != isTalking {
                self.anchorSeatList[userId]?.isTalking = isTalking
                needRefreshUI = true
            }
        }
        if needRefreshUI {
            viewResponder?.refreshAnchorInfos()
        }
    }
    
    func onRecvRoomTextMsg(message: String, userInfo: ChatSalonUserInfo) {
        let msgEntity = CSMsgEntity.init(userID: userInfo.userID,
                                       userName: userInfo.userName,
                                       content: message,
                                       invitedId: "",
                                       type: CSMsgEntity.TYPE_NORMAL)
        notifyMsg(entity: msgEntity)
    }
    
    func onRecvRoomCustomMsg(cmd: String, message: String, userInfo: ChatSalonUserInfo) {
        
    }
    
    func onReceiveNewInvitation(identifier: String, inviter: String, cmd: String, content: String) {
        TRTCLog.out("receive message: \(cmd) : \(content)")
        if roomType == .audience {
            if cmd == ChatSalonConstants.CMD_PICK_UP_SEAT {
                recvPickSeat(identifier: identifier, cmd: cmd, content: content)
            }
        }
        if roomType == .anchor && roomInfo.ownerId == dependencyContainer.userID {
            if cmd == ChatSalonConstants.CMD_REQUEST_TAKE_SEAT {
                recvTakeSeat(identifier: identifier, inviter: inviter, content: content)
            }
        }
    }
    
    func onInviteeAccepted(identifier: String, invitee: String) {
        if roomType == .audience {
            guard let seatIndex = mInvitationSeatDic.removeValue(forKey: identifier) else {
                return
            }
            if anchorSeatList[dependencyContainer.userID] != nil {
                // 已经在麦上了
                return
            }
            viewResponder?.showHandUpTips(isShow: false)
            chatSalon.enterSeat { [weak self] (code, message) in
                guard let `self` = self else { return }
                if code == 0 {
                    self.viewResponder?.showToast(message: .enterRoomSuccText)
                } else {
                    self.viewResponder?.showToast(message: .enterSeatFailedText)
                }
            }
        }
    }
    
    func onInviteeRejected(identifier: String, invitee: String) {
        if let seatInvitation = mPickCSSeatInvitationDic.removeValue(forKey: identifier) {
            guard let audience = memberAudienceDic[seatInvitation.inviteUserId] else { return }
            changeAudience(status: CSAudienceInfoModel.TYPE_IDEL, user: audience.userInfo)
        }
    }
    
    func onInvitationCancelled(identifier: String, invitee: String) {
        if roomType == .anchor {
            if let userID = self.requestTakeSeatMap.first(where: { $1.invitedId == identifier })?.key {
                self.requestTakeSeatMap.removeValue(forKey: userID)
            }
            self.viewResponder?.refreshTakeSeatList()
        }
    }
    
    func onInvitationTimeout(identifier: String) {
        if roomType == .anchor {
            if let userID = self.requestTakeSeatMap.first(where: { $1.invitedId == identifier })?.key {
                self.requestTakeSeatMap.removeValue(forKey: userID)
            }
            self.viewResponder?.refreshTakeSeatList()
        }
    }
}

fileprivate extension String {
    static let closedMicText = TRTCLocalize("Demo.TRTC.Salon.micmuted")
    static let openedMicText = TRTCLocalize("Demo.TRTC.Salon.micunmuted")
    static let micInitNotReadyText = TRTCLocalize("Demo.TRTC.Salon.seatlistnotinit")
    static let enterRoomSuccText = TRTCLocalize("Demo.TRTC.Salon.enterroomsuccess")
    static let enterRoomFailText = TRTCLocalize("Demo.TRTC.Salon.enterroomfailed")
    static let createRoomFailedText = TRTCLocalize("Demo.TRTC.LiveRoom.createroomfailed")
    static let alreadyIsAnchorText = TRTCLocalize("Demo.TRTC.Salon.isbeingarchon")
    static let roomNotReadyText = TRTCLocalize("Demo.TRTC.Salon.roomnotready")
    static let waitHostAcceptText = TRTCLocalize("Demo.TRTC.Salon.waitinghostconsent")
    static let takeSeatSendFailed = TRTCLocalize("Demo.TRTC.Salon.failedsenthandupmessage")
    static let masterOnSeatSuccess = TRTCLocalize("Demo.TRTC.Salon.hostoccupyseatsuccess")
    static let masterOnSeatFailed = TRTCLocalize("Demo.TRTC.Salon.hostoccupyseatfailed")
    static let onlyAnchorUse = TRTCLocalize("Demo.TRTC.LiveRoom.onlyanchorcanoperation")
    static let kickOutMicText = TRTCLocalize("Demo.TRTC.Salon.movetotheaudience")
    static let inviatttionTimeoutText = TRTCLocalize("Demo.TRTC.Salon.reqisexpired")
    static let acceptInvitationFailed = TRTCLocalize("Demo.TRTC.Salon.acceptreqfailed")
    static let leaveSeatSuccText = TRTCLocalize("Demo.TRTC.Salon.audiencesuccess")
    static let leaveSeatFailedText = TRTCLocalize("Demo.TRTC.Salon.failedaudience")
    static let hostDestroyRoomText = TRTCLocalize("Demo.TRTC.Salon.archonclosedroom")
    static let enterSeatText = TRTCLocalize("Demo.TRTC.Salon.handsup")
    static let leaveSeatText = TRTCLocalize("Demo.TRTC.Salon.audience")
    static let enterSeatSuccessText = TRTCLocalize("Demo.TRTC.Salon.successbecomespaker")
    static let enterSeatFailedText = TRTCLocalize("Demo.TRTC.Salon.failedbecomespaker")
    static let inviteLimitedText = TRTCLocalize("Demo.TRTC.Salon.invitelimited")
}
