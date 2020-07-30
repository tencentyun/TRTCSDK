//
//  AudioSelectContactViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/8/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift

/// AudioCallMainViewController 会使用 AudioUserRemoveReason
enum AudioUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

class AudioSelectContactViewController: UIViewController, TRTCAudioCallDelegate {
    var selectedFinished: (([UserModel])->Void)? = nil
    
    let disposebag = DisposeBag()
    let searchBar = UISearchBar()
    var callVC: AudioCallViewController? = nil
    
    /// 是否展示搜索结果
    var shouldShowSearchResult: Bool = false {
        didSet {
            if oldValue != shouldShowSearchResult {
                if !shouldShowSearchResult {
                    getHistroy()
                }
                selectTable.reloadData()
            }
        }
    }
    
    /// 已选择的用户列表
    var selectedUsers: [UserModel] = [] {
        didSet {//更新UI
            userPanel.snp.remakeConstraints { (make) in
                make.leading.equalTo(view).offset(kUserPanelLeftSpacing)
                make.trailing.equalTo(view)
                make.top.equalTo(searchBar.snp.bottom).offset(6)
                make.height.equalTo(userPanelHeight)
            }
            userPanel.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userPanel.reloadSections(IndexSet(integer: 0))
            }){ _ in
                
            }
            selectTable.reloadData()
            doneBtn.alpha = selectedUsers.count == 0 ? 0.5 : 1
        }
    }
    
    /// 完成按钮
    lazy var doneBtn: UIButton = {
       let done = UIButton()
        done.backgroundColor = .buttonBackColor
        done.setTitle("开始", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.alpha = 0.5
        done.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        done.layer.cornerRadius = 9.0
        done.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
        guard let self = self else {return}
        if self.selectedUsers.count == 0 {
            return
        }
        var users:[UserModel] = []
        for user in self.selectedUsers {
            users.append(user.copy())
        }
        if let finish = self.selectedFinished {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [users] in
                finish(users)
            })
        }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        return done
    }()
    
     /// 搜索记录为空时，提示
     lazy var noSearchImage: UIImageView = {
         let image = UIImageView.init(image: UIImage.init(named: "noSearchMembers"))
         return image
     }()
     
     lazy var noMembersTip: UILabel = {
         let label = UILabel()
         label.text = "搜索添加已注册用户\n以发起语音通话"
         label.numberOfLines = 2
         label.textAlignment = NSTextAlignment.center
         label.textColor = .placeholderBackColor
         return label
     }()
    
    
    /// 搜索结果model
    var searchResult: UserModel? = nil
    
    /// 历史搜索列表
    var historyList: [UserModel] = []
    
    /// 选择列表
    lazy var selectTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = .clear
        table.register(AudioSelectUserTableViewCell.classForCoder(),
                       forCellReuseIdentifier: "AudioSelectUserTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let kUserBorder: CGFloat = 44.0
    let kUserSpacing: CGFloat = 2
    let kUserPanelLeftSpacing: CGFloat = 28
    
    /// 已选用户面板
    lazy var userPanel: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let panel = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                    collectionViewLayout: layout)
        panel.backgroundColor = .clear
        panel.register(AudioSelectUserCollectionViewCell.classForCoder(),
                       forCellWithReuseIdentifier: "AudioSelectUserCollectionViewCell")
        if #available(iOS 10.0, *) {
            panel.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        
        panel.showsVerticalScrollIndicator = false
        panel.showsHorizontalScrollIndicator = false
        panel.contentMode = .scaleToFill
        panel.isScrollEnabled = false
        panel.delegate = self
        panel.dataSource = self
        return panel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        showSelectVC()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        searchBar.text = ""
        shouldShowSearchResult = false
        selectedUsers = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func onError(code: Int32, msg: String?) {
        debugPrint("onError: code \(code), msg: \(String(describing: msg))")
    }
    
    func onInvited(sponsor: String, userIds: [String], isFromGroup: Bool) {
        debugPrint("log: onInvited sponsor:\(sponsor) userIds:\(userIds)")
        ProfileManager.shared.queryUserInfo(userID: sponsor, success: { [weak self] (user) in
            guard let self = self else {return}
            ProfileManager.shared.queryUserListInfo(userIDs: userIds, success: { (usermodels) in
                var list:[AudioCallUserModel] = []
                for UserModel in usermodels {
                    list.append(self.covertUser(user: UserModel))
                }
                self.showCallVC(invitedList: list, sponsor: self.covertUser(user: user, isEnter: true))
            }) { (error) in
                
            }
        }) { (error) in
            
        }
    }
    
    func onGroupCallInviteeListUpdate(userIds: [String]) {
        debugPrint("log: onGroupCallInviteeListUpdate userIds:\(userIds)")
    }
    
    func onUserEnter(uid: String) {
        debugPrint("log: onUserEnter: \(uid)")
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                vc?.enterUser(user: self.covertUser(user: UserModel, isEnter: true))
                vc?.view.makeToast("\(UserModel.name) 进入通话")
            }) { (error) in
                
            }
        }
    }
    
    func onUserLeave(uid: String) {
        debugPrint("log: onUserLeave: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .leave)
    }
    
    func onReject(uid: String) {
        debugPrint("log: onReject: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .reject)
    }
    
    func onNoResp(uid: String) {
        debugPrint("log: onNoResp: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .noresp)
    }
    
    func onLineBusy(uid: String) {
        debugPrint("log: onLineBusy: \(uid)")
        removeUserFromCallVC(uid: uid, reason: .busy)
    }
    
    func onCallingCancel() {
        debugPrint("log: onCallingCancel")
        if let vc = callVC {
            view.makeToast("\((vc.curSponsor?.name) ?? "")通话取消")
            vc.disMiss()
        }
    }
    
    func onCallingTimeOut() {
        debugPrint("log: onCallingTimeOut")
        if let vc = callVC {
            view.makeToast("通话超时")
            vc.disMiss()
        }
    }
    
    func onCallEnd() {
        debugPrint("log: onCallEnd")
        if let vc = callVC {
            vc.disMiss()
        }
    }
    
    func onUserAudioAvailable(uid: String, available: Bool) {
        debugPrint("log: onUserAudioAvailable , uid: \(uid), available: \(available)")
    }
    
    func onUserVoiceVolume(uid: String, volume: UInt32) {
        if let vc = callVC {
            if let user = vc.getUserById(userId: uid) {
                var newUser = user
                newUser.volume = Float(volume) / 100
                vc.updateUser(user: newUser)
            } else {
                ProfileManager.shared.queryUserInfo(userID: uid, success: { (UserModel) in
                    vc.enterUser(user: self.covertUser(user: UserModel, volume: volume, isEnter: true))
                }) { (error) in
                    
                }
            }
        }
    }
    
    func covertUser(user: UserModel, volume: UInt32 = 0, isEnter: Bool = false) -> AudioCallUserModel {
        var dstUser = AudioCallUserModel()
        dstUser.name = user.name
        dstUser.avatarUrl = user.avatar
        dstUser.userId = user.userId
        dstUser.isEnter = isEnter
        dstUser.volume = Float(volume) / 100
        return dstUser
    }
    
    func removeUserFromCallVC(uid: String, reason: AudioUserRemoveReason = .noresp) {
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                let userInfo = self.covertUser(user: UserModel)
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
