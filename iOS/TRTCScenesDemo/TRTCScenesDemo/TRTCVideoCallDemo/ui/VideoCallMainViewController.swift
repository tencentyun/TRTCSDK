//
//  VideoCallMainViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift

enum VideoUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

class VideoCallMainViewController: UIViewController, TRTCVideoCallDelegate {
    let disposebag = DisposeBag()
    var callVC: VideoCallViewController? = nil
    
    lazy var noHistoryView: UIView = {
        let noHistory = UIView()
        noHistory.backgroundColor = .appBackGround
        return noHistory
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
    }
    
    func onError(code: Int32, msg: String?) {
        debugPrint("📳 onError: code \(code), msg: \(String(describing: msg))")
    }
    
    func onInvited(sponsor: String, userIds: [String], isFromGroup: Bool) {
        debugPrint("📳 onInvited sponsor:\(sponsor) userIds:\(userIds)")
        ProfileManager.shared.queryUserInfo(userID: sponsor, success: { [weak self] (user) in
            guard let self = self else {return}
            ProfileManager.shared.queryUserListInfo(userIDs: userIds, success: { (usermodels) in
                var list:[VideoCallUserModel] = []
                for userModel in usermodels {
                    list.append(self.covertUser(user: userModel))
                }
                self.showCallVC(invitedList: list, sponsor: self.covertUser(user: user, isEnter: true))
            }) { (error) in
                
            }
        }) { (error) in
            
        }
    }
    
    func onGroupCallInviteeListUpdate(userIds: [String]) {
        debugPrint("📳 onGroupCallInviteeListUpdate userIds:\(userIds)")
    }
    
    func onUserEnter(uid: String) {
        debugPrint("📳 onUserEnter: \(uid)")
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (userModel) in
                guard let self = self else {return}
                vc?.enterUser(user: self.covertUser(user: userModel, isEnter: true))
                vc?.view.makeToast("\(userModel.name) 进入通话")
            }) { (error) in
                
            }
        }
    }
    
    func onUserLeave(uid: String) {
        debugPrint("📳 onUserLeave: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .leave)
    }
    
    func onReject(uid: String) {
        debugPrint("📳 onReject: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .reject)
    }
    
    func onNoResp(uid: String) {
        debugPrint("📳 onNoResp: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .noresp)
    }
    
    func onLineBusy(uid: String) {
        debugPrint("📳 onLineBusy: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .busy)
    }
    
    func onCallingCancel() {
        debugPrint("📳 onCallingCancel")
        if let vc = callVC {
            view.makeToast("\((vc.curSponsor?.name) ?? "")通话取消")
            vc.disMiss()
        }
    }
    
    func onCallingTimeOut() {
        debugPrint("📳 onCallingTimeOut")
        if let vc = callVC {
            view.makeToast("通话超时")
            vc.disMiss()
        }
    }
    
    func onCallEnd() {
        debugPrint("📳 onCallEnd")
        if let vc = callVC {
            vc.disMiss()
        }
    }
    
    func onUserVideoAvailable(uid: String, available: Bool) {
        debugPrint("📳 onUserVideoAvailable , uid: \(uid), available: \(available)")
        if let vc = callVC {
            if let user = vc.getUserById(userId: uid) {
                var newUser = user
                newUser.isEnter = true
                newUser.isVideoAvaliable = available
                vc.updateUser(user: newUser)
            } else {
                ProfileManager.shared.queryUserInfo(userID: uid, success: { (userModel) in
                    var newUser = self.covertUser(user: userModel, isEnter: true)
                    newUser.isVideoAvaliable = available
                    vc.enterUser(user: newUser)
                }) { (error) in
                    
                }
            }
        }
    }
    
    func covertUser(user: UserModel,
                        isEnter: Bool = false) -> VideoCallUserModel {
        var dstUser = VideoCallUserModel()
        dstUser.name = user.name
        dstUser.avatarUrl = user.avatar
        dstUser.userId = user.userId
        dstUser.isEnter = isEnter
        if let vc = callVC {
            if let oldUser = vc.getUserById(userId: user.userId) {
                dstUser.isVideoAvaliable = oldUser.isVideoAvaliable
            }
        }
        return dstUser
    }
    
    func removeUserFromCallVC(uid: String, reason: VideoUserRemoveReason = .noresp) {
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (userModel) in
                guard let self = self else {return}
                let userInfo = self.covertUser(user: userModel)
                vc?.leaveUser(user: userInfo)
                var toast = "\(userInfo.name)"
                switch reason {
                case .reject:
                    toast += "拒绝了通话"
                    break
                case .leave:
                    toast += "离开了通话"
                    break
                case .noresp:
                    toast += "未响应"
                    break
                case .busy:
                    toast += "忙线"
                    break
                }
                vc?.view.makeToast(toast)
                self.view.makeToast(toast)
            }) { (error) in
                
            }
        }
    }
}
