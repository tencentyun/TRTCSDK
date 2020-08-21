//
//  TRTCCallingContactViewController.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/6.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation

import RxSwift
import Toast_Swift
import Material

enum CallingUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

protocol CallingViewControllerResponder: UIViewController {
    var dismissBlock: (()->Void)? { get set }
    var curSponsor: CallingUserModel? { get }
    func enterUser(user: CallingUserModel)
    func leaveUser(user: CallingUserModel)
    func updateUser(user: CallingUserModel, animated: Bool)
    func updateUserVolume(user: CallingUserModel) // 更新用户音量
    func disMiss()
    func getUserById(userId: String) -> CallingUserModel?
    func resetWithUserList(users: [CallingUserModel], isInit: Bool)
    static func getRenderView(userId: String) -> VideoCallingRenderView?
}

extension CallingViewControllerResponder {
    static func getRenderView(userId: String) -> VideoCallingRenderView? {
        return nil
    }
    func updateUser(user: CallingUserModel, animated: Bool) {
        
    }
    func updateUserVolume(user: CallingUserModel) {
        
    }
}

class TRTCCallingContactViewController: UIViewController, TRTCCallingDelegate {
    var selectedFinished: (([UserModel])->Void)? = nil
    
    let disposebag = DisposeBag()
    
    var callVC: CallingViewControllerResponder? = nil
    @objc var callType: CallType = .audio
    /// 是否展示搜索结果
    var shouldShowSearchResult: Bool = false {
        didSet {
            if oldValue != shouldShowSearchResult {
                selectTable.reloadData()
            }
        }
    }
    
    /// 搜索结果model
    var searchResult: UserModel? = nil
    
    let searchContainerView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = .searchBarBackColor
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar.init()
        searchBar.backgroundImage = UIImage.init()
        searchBar.barTintColor = .searchBarBackColor
        searchBar.placeholder = "搜索手机号"
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.returnKeyType = .search
        searchBar.layer.cornerRadius = 2
        return searchBar
    }()
    
    /// 搜索按钮
    lazy var searchBtn: UIButton = {
       let done = UIButton()
        done.setTitle("搜索", for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.alpha = 0.5
        done.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return done
    }()
    
    let userInfoLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = "\(String.yourUserNameText):\(ProfileManager.shared.curUserModel?.phone ?? "")"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.init(0xEBF4FF)
        label.textAlignment = .left
        return label
    }()
    
    /// 选择列表
    lazy var selectTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = .clear
        table.register(CallingSelectUserTableViewCell.classForCoder(), forCellReuseIdentifier: "CallingSelectUserTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let kUserBorder: CGFloat = 44.0
    let kUserSpacing: CGFloat = 2
    let kUserPanelLeftSpacing: CGFloat = 28
    
    /// 搜索记录为空时，提示
    lazy var noSearchImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "noSearchMembers"))
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var noMembersTip: UILabel = {
        let label = UILabel()
        label.text = .backgroundTipsText
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.textColor = .placeholderBackColor
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        searchBar.text = ""
        shouldShowSearchResult = false
        // 每次进入页面的时候，刷新手机号
        userInfoLabel.text = "\(String.yourUserNameText)\(ProfileManager.shared.curUserModel?.phone ?? "")"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func onError(code: Int32, msg: String?) {
        debugPrint("onError: code \(code), msg: \(String(describing: msg))")
    }
    
    func onInvited(sponsor: String, userIds: [String], isFromGroup: Bool, callType: CallType) {
        debugPrint("log: onInvited sponsor:\(sponsor) userIds:\(userIds)")
        self.callType  = callType
        ProfileManager.shared.queryUserInfo(userID: sponsor, success: { [weak self] (user) in
            guard let self = self else {return}
            ProfileManager.shared.queryUserListInfo(userIDs: userIds, success: { (usermodels) in
                var list:[CallingUserModel] = []
                for UserModel in usermodels {
                    list.append(self.covertUser(user: UserModel))
                }
                self.showCallVC(invitedList: list, sponsor: self.covertUser(user: user, isEnter: true))
            }) { (error) in
                
            }
        }) { (error) in
            
        }
    }
    
    private func onGroupCallInviteeListUpdate(userIds: [String]) {
        debugPrint("log: onGroupCallInviteeListUpdate userIds:\(userIds)")
    }
    
    func onUserEnter(uid: String) {
        debugPrint("log: onUserEnter: \(uid)")
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                vc?.enterUser(user: self.covertUser(user: UserModel, isEnter: true))
                vc?.view.makeToast("\(UserModel.name) \(String.enterConvText)")
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
    
    func onCallingCancel(uid: String) {
        debugPrint("log: onCallingCancel")
        if let vc = callVC {
            view.makeToast("\((vc.curSponsor?.name) ?? "")\(String.cancelConvText)")
            vc.disMiss()
        }
    }
    
    func onCallingTimeOut() {
        debugPrint("log: onCallingTimeOut")
        if let vc = callVC {
            view.makeToast(.callTimeOutText)
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
                if callType == .audio {
                    vc.updateUser(user: newUser, animated: false)
                } else {
                    vc.updateUserVolume(user: newUser)
                }
                
            } else {
                ProfileManager.shared.queryUserInfo(userID: uid, success: { (UserModel) in
                    vc.enterUser(user: self.covertUser(user: UserModel, volume: volume, isEnter: true))
                }) { (error) in
                    
                }
            }
        }
    }
    
    func onUserVideoAvailable(uid: String, available: Bool) {
        debugPrint("log: onUserVideoAvailable , uid: \(uid), available: \(available)")
        if let vc = callVC {
            if let user = vc.getUserById(userId: uid) {
                var newUser = user
                newUser.isEnter = true
                newUser.isVideoAvaliable = available
                vc.updateUser(user: newUser, animated: false)
            } else {
                ProfileManager.shared.queryUserInfo(userID: uid, success: { (UserModel) in
                    var newUser = self.covertUser(user: UserModel, isEnter: true)
                    newUser.isVideoAvaliable = available
                    vc.enterUser(user: newUser)
                }) { (error) in
                    
                }
            }
        }
    }
    
    func covertUser(user: UserModel,
                    volume: UInt32 = 0,
                    isEnter: Bool = false) -> CallingUserModel {
        var dstUser = CallingUserModel()
        dstUser.name = user.name
        dstUser.avatarUrl = user.avatar
        dstUser.userId = user.userId
        dstUser.isEnter = isEnter
        dstUser.volume = Float(volume) / 100
        if let vc = callVC {
            if let oldUser = vc.getUserById(userId: user.userId) {
                dstUser.isVideoAvaliable = oldUser.isVideoAvaliable
            }
        }
        return dstUser
    }
    
    func removeUserFromCallVC(uid: String, reason: CallingUserRemoveReason = .noresp) {
        if let vc = callVC {
            ProfileManager.shared.queryUserInfo(userID: uid, success: { [weak self, weak vc] (UserModel) in
                guard let self = self else {return}
                let userInfo = self.covertUser(user: UserModel)
                vc?.leaveUser(user: userInfo)
                var toast = "\(userInfo.name)"
                switch reason {
                case .reject:
                    toast += .rejectToastText
                    break
                case .leave:
                    toast += .leaveToastText
                    break
                case .noresp:
                    toast += .norespToastText
                    break
                case .busy:
                    toast += .busyToastText
                    break
                }
                vc?.view.makeToast(toast)
                self.view.makeToast(toast)
            }) { (error) in
                
            }
        }
    }
}

extension TRTCCallingContactViewController {
    
    func setupUI() {
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        setupUIStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenNoMembersImg), name: NSNotification.Name("HiddenNoSearchVideoNotificationKey"), object: nil)
        selectTable.reloadData()
    }
    
    func constructViewHierarchy() {
        // 添加全局背景
        let colors = [UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0,
                              blue: 75.0 / 255.0, alpha: 1).cgColor,
                      UIColor(red: 5.0 / 255.0, green: 12.0 / 255.0,
                              blue: 23.0 / 255.0, alpha: 1).cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap { $0 }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        // 添加SearchBar
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(searchBtn)
        view.addSubview(userInfoLabel)
        view.addSubview(selectTable)
        selectTable.isHidden = true
        view.addSubview(noSearchImageView)
        view.addSubview(noMembersTip)
    }
    
    func activateConstraints() {
        var topPadding: CGFloat = 44
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        topPadding = max(26, topPadding)
        searchContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(topPadding + 60)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(40)
        }
        searchBar.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(searchBtn.snp.left).offset(5)
        }
        searchBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        userInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(20)
        }
        selectTable.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.bottomMargin.equalTo(view)
        }
        noSearchImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.bounds.size.height/3.0)
            make.leading.equalTo(view.bounds.size.width*154.0/375)
            make.trailing.equalTo(-view.bounds.size.width*154.0/375)
            make.height.equalTo(view.bounds.size.width*67.0/375)
        }
        noMembersTip.snp.makeConstraints { (make) in
            make.top.equalTo(noSearchImageView.snp.bottom)
            make.width.equalTo(view.bounds.size.width)
            make.height.equalTo(60)
        }
    }
    
    func setupUIStyle() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.cornerRadius = 10.0
            textfield.layer.masksToBounds = true
            textfield.textColor = UIColor.white
            textfield.backgroundColor = .clear
            textfield.leftViewMode = .always
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image =  UIImage.init(named: "cm_search_white")
            }
        }
        ToastManager.shared.position = .bottom
    }
    
    func bindInteraction() {
        searchBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self = self else {return}
            self.searchBar.resignFirstResponder()
            if let input = self.searchBar.text, input.count > 0 {
                self.searchUser(input: input)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        searchBar.delegate = self
        // 设置选择通话用户结束后的交互逻辑
        selectedFinished = { [weak self] users in
            guard let self = self else {return}
            var list:[CallingUserModel] = []
            var userIds: [String] = []
            for UserModel in users {
                list.append(self.covertUser(user: UserModel))
                userIds.append(UserModel.userId)
            }
            self.showCallVC(invitedList: list)
            TRTCCalling.shareInstance().groupCall(userIDs:userIds, type: self.callType, groupID: nil)
        }
    }
    
    @objc func hiddenNoMembersImg() {
        noSearchImageView.removeFromSuperview()
        noMembersTip.removeFromSuperview()
        selectTable.isHidden = false
    }
    
    /// show calling view
    /// - Parameters:
    ///   - invitedList: invitee userlist
    ///   - sponsor: passive call should not be nil,
    ///     otherwise sponsor call this mothed should ignore this parameter
    func showCallVC(invitedList: [CallingUserModel], sponsor: CallingUserModel? = nil) {
        if callType == .audio {
            callVC = TRTCCallingAuidoViewController.init(sponsor: sponsor)
        } else  {
            callVC = TRTCCallingVideoViewController.init(sponsor: sponsor)
        }
        
        callVC?.dismissBlock = {[weak self] in
            guard let self = self else {return}
            self.callVC = nil
        }
        if let vc = callVC {
            vc.modalPresentationStyle = .fullScreen
            vc.resetWithUserList(users: invitedList, isInit: true)
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let navigationVC = topController as? UINavigationController {
                    if navigationVC.viewControllers.contains(self) {
                        present(vc, animated: false, completion: nil)
                    } else {
                        navigationVC.popToRootViewController(animated: false)
                        navigationVC.pushViewController(self, animated: false)
                        navigationVC.present(vc, animated: false, completion: nil)
                    }
                } else {
                    topController.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
}

extension TRTCCallingContactViewController: UITextFieldDelegate, UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let input = searchBar.text, input.count > 0 {
            searchUser(input: input)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count ?? 0 == 0 {
            //show recent table
            shouldShowSearchResult = false
        }
        
        if (searchBar.text?.count ?? 0) > 11 {
            searchBar.text = (searchBar.text as NSString?)?.substring(to: 11)
        }
    }
    
    func searchUser(input: String)  {
        ProfileManager.shared.queryUserInfo(phone: input, success: { [weak self] (user) in
            guard let self = self else {return}
            self.searchResult = user
            self.shouldShowSearchResult = true
            self.selectTable.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name("HiddenNoSearchVideoNotificationKey"), object: nil)
        }) { [weak self] (error) in
            guard let self = self else {return}
            self.searchResult = nil
            self.view.makeToast("查询失败")
        }
    }
}

extension TRTCCallingContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResult {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallingSelectUserTableViewCell") as! CallingSelectUserTableViewCell
        cell.selectionStyle = .none
        if shouldShowSearchResult {
            if let user = searchResult {
                cell.config(model: user, selected: false) { [weak self] in
                    guard let self = self else { return }
                    if user.userId == AppUtils.shared.curUserId {
                        self.view.makeToast("不能邀请自己")
                        return
                    }
                    if let finish = self.selectedFinished {
                        finish([user])
                    }
                }
            } else {
                cell.config(model: UserModel(userID: ""))
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

private extension String {
    static let yourUserNameText = String.localized(of: "您的手机号")
    static let searchPhoneNumberText = String.localized(of: "搜索手机号")
    static let searchText = String.localized(of: "搜索")
    static let backgroundTipsText = String.localized(of: "搜索添加已注册用户\n以发起通话")
    static let enterConvText = String.localized(of: "进入通话")
    static let cancelConvText = String.localized(of: "通话取消")
    static let callTimeOutText = String.localized(of: "通话超时")
    static let rejectToastText = String.localized(of: "拒绝了通话")
    static let leaveToastText = String.localized(of: "离开了通话")
    static let norespToastText = String.localized(of: "未响应")
    static let busyToastText = String.localized(of: "忙线")
    
    static func localized(of key: String, comment: String = "") -> String {
        return NSLocalizedString(key,
                                 tableName: "Localizable",
                                 bundle: Bundle.main,
                                 comment: comment)
    }
}
