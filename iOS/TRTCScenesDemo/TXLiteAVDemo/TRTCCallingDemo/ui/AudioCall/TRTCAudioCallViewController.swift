//
//  TRTCCallingAudioContactViewController.swift
//  TXLiteAVDemo_Enterprise
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import RxSwift
import Toast_Swift

@objc public enum AudioiCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class TRTCCallingAuidoViewController: UIViewController, CallingViewControllerResponder {
    lazy var userList: [CallingUserModel] = []
    lazy var inviteeList: [CallingUserModel] = []
    var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
    let disposebag = DisposeBag()
    let curSponsor: CallingUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    
    var curState: AudioiCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var OnInviteePanelList: [CallingUserModel] {
        get {
            return inviteeList.filter {
                let isCurrent = $0.userId == V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
                var isSponor = false
                if let sponor = curSponsor {
                    isSponor = $0.userId == sponor.userId
                }
                return !isCurrent && !isSponor
            }
        }
    }
    
    var collectionCount: Int {
        get {
            var count = ((userList.count <= 4) ? userList.count : 9)
            if curState == .onInvitee {
                count = 1
            }
            return count
        }
    }
    
    lazy var OninviteeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()
    
    lazy var OnInviteePanel: UIView = {
        let panel = UIView()
        return panel
    }()
    
    init(sponsor: CallingUserModel? = nil) {
        curSponsor = sponsor
        if let _ = sponsor {
            curState = .onInvitee
        } else {
            curState = .dailing
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
    }
    
    lazy var userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let user = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                    collectionViewLayout: layout)
        user.register(AudioCallUserCell.classForCoder(), forCellWithReuseIdentifier: "AudioCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .clear
        user.dataSource = self
        user.delegate = self
        return user
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func getUserById(userId: String) -> CallingUserModel? {
        for user in userList {
            if user.userId == userId {
                return user
            }
        }
        return nil
    }
    
    func disMiss() {
        if self.curState != .calling {
           if !codeTimer.isCancelled {
                self.codeTimer.resume()
            }
        }
        self.codeTimer.cancel()
        dismiss(animated: false) {
            if let dis = self.dismissBlock {
                dis()
            }
        }
    }
}

extension TRTCCallingAuidoViewController {
    func setupUI() {
        
        view.backgroundColor = UIColor(hex: "F4F5F9")
        
        view.addSubview(OnInviteePanel)
        OnInviteePanel.addSubview(OninviteeStackView)
        OninviteeStackView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(OnInviteePanel)
            make.top.equalTo(OnInviteePanel.snp.bottom)
        }
        
        ToastManager.shared.position = .bottom
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.height.equalTo(view.snp.width)
            make.top.equalTo(topPadding + 62)
        }
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage(named: "ic_hangup"), for: .normal)
            view.addSubview(hangup)
            hangup.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                TRTCCalling.shareInstance()
                 TRTCCalling.shareInstance().hangup()
                self.disMiss()
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        }
        
        
        if accept.superview == nil {
            accept.setImage(UIImage(named: "ic_dialing"), for: .normal)
            view.addSubview(accept)
            accept.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                TRTCCalling.shareInstance().accept()
                var curUser = CallingUserModel()
                if let name = ProfileManager.shared.curUserModel?.name,
                    let avatar = ProfileManager.shared.curUserModel?.avatar,
                    let userId = ProfileManager.shared.curUserModel?.userId {
                    curUser.name = name
                    curUser.avatarUrl = avatar
                    curUser.userId = userId
                    curUser.isEnter = true
                }
                self.enterUser(user: curUser)
                self.curState = .calling
                self.accept.isHidden = true
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
        }
        
        if mute.superview == nil {
            mute.setImage(UIImage(named: "ic_mute"), for: .normal)
            view.addSubview(mute)
            mute.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                self.isMicMute = !self.isMicMute
                TRTCCalling.shareInstance().setMicMute(self.isMicMute)
                self.mute.setImage(UIImage(named: self.isMicMute ? "ic_mute_on" : "ic_mute"), for: .normal)
                self.view.makeToast(self.isMicMute ? .muteonText : .muteoffText)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
            mute.isHidden = true
            mute.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(50)
                make.height.equalTo(50)
            }
        }
        
        if handsfree.superview == nil {
            handsfree.setImage(UIImage(named: "ic_handsfree_on"), for: .normal)
            view.addSubview(handsfree)
            handsfree.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                self.isHandsFreeOn = !self.isHandsFreeOn
                TRTCCalling.shareInstance().setHandsFree(self.isHandsFreeOn)
                self.handsfree.setImage(UIImage(named: self.isHandsFreeOn ? "ic_handsfree_on" : "ic_handsfree"), for: .normal)
                self.view.makeToast(self.isHandsFreeOn ? .handsfreeonText : .handsfreeoffText)
                }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposebag)
            handsfree.isHidden = true
            handsfree.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(120)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(50)
                make.height.equalTo(50)
            }
        }
        
        if callTimeLabel.superview == nil {
            callTimeLabel.textColor = .black
            callTimeLabel.backgroundColor = .clear
            callTimeLabel.text = "00:00"
            callTimeLabel.textAlignment = .center
            view.addSubview(callTimeLabel)
            callTimeLabel.isHidden = true
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(hangup.snp.top).offset(-10)
                make.height.equalTo(30)
            }
        }
    }
    
    func autoSetUIByState() {
        switch curState {
        case .dailing:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            break
        case .onInvitee:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            
            accept.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(80)
                make.height.equalTo(80)
            }
            break
        case .calling:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            startGCDTimer()
            break
        }
        
        if curState == .calling {
            mute.isHidden = false
            handsfree.isHidden = false
            callTimeLabel.isHidden = false
            mute.alpha = 0.0
            handsfree.alpha = 0.0
            callTimeLabel.alpha = 0.0
        }
        
        let shouldHideOnInviteePanel = (OnInviteePanelList.count == 0 || (self.curState != .onInvitee))
        
        OnInviteePanel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.hangup.snp.top).offset(-100)
            make.width.equalTo(max(44, 44 * OnInviteePanelList.count + 2 * max(0, OnInviteePanelList.count - 1)))
            make.centerX.equalTo(view)
            make.height.equalTo(80)
        }
        
        OninviteeStackView.safelyRemoveArrangedSubviews()
        if OnInviteePanelList.count > 0,!shouldHideOnInviteePanel {
            for user in OnInviteePanelList {
                let userAvatar = UIImageView()
                userAvatar.sd_setImage(with: URL(string: user.avatarUrl), completed: nil)
                userAvatar.widthAnchor.constraint(equalToConstant: 44).isActive = true
                OninviteeStackView.addArrangedSubview(userAvatar)
            }
        }
        
        OnInviteePanel.isHidden = shouldHideOnInviteePanel
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            if self.curState == .calling {
                self.mute.alpha = 1.0
                self.handsfree.alpha = 1.0
                self.callTimeLabel.alpha = 1.0
            }
        }) { _ in
            
        }
    }
    
    // Dispatch Timer
     func startGCDTimer() {
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: { [weak self] in
            guard let self = self else {return}
            self.callingTime += 1
            // UI 更新
            DispatchQueue.main.async {
                var mins: UInt32 = 0
                var seconds: UInt32 = 0
                mins = self.callingTime / 60
                seconds = self.callingTime % 60
                self.callTimeLabel.text = String(format: "%02d:", mins) + String(format: "%02d", seconds)
            }
        })
        
        // 判断是否取消，如果已经取消了，调用resume()方法时就会崩溃！！！
        if codeTimer.isCancelled {
            return
        }
        // 启动时间源
        codeTimer.resume()
    }
}

extension TRTCCallingAuidoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [CallingUserModel], isInit: Bool = false) {
        resetUserList()
        if isInit && curSponsor != nil {
            inviteeList.append(contentsOf: users)
        } else {
            userList.append(contentsOf: users)
        }
        
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            userList = [sponsor]
        } else {
            var curUser = CallingUserModel()
            if let name = ProfileManager.shared.curUserModel?.name,
                let avatar = ProfileManager.shared.curUserModel?.avatar,
                let userId = ProfileManager.shared.curUserModel?.userId {
                curUser.name = name
                curUser.avatarUrl = avatar
                curUser.userId = userId
                curUser.isEnter = true
            }
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCallUserCell", for: indexPath) as! AudioCallUserCell
        if (indexPath.row < userList.count) {
            let user = userList[indexPath.row]
            cell.userModel = user
        } else {
            cell.userModel = CallingUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        if (collectionCount <= 4) {
            let border = collectWidth / 2;
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                return CGSize(width:  collectWidth, height: border)
            } else {
                return CGSize(width: border, height: border)
            }
        } else {
            let border = collectWidth / 3;
            return CGSize(width: border, height: border)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func enterUser(user: CallingUserModel) {
        curState = .calling
        updateUser(user: user, animated: true)
    }
    
    func leaveUser(user: CallingUserModel) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
        }
        reloadData(animate: true)
    }
    
    func updateUser(user: CallingUserModel, animated: Bool) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
            userList.insert(user, at: index)
        } else {
            userList.append(user)
        }
        reloadData(animate: animated)
    }
    
    func reloadData(animate: Bool = false) {
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        if animate {
            userCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(self.view)
                    make.bottom.equalTo(self.view).offset(-132)
                    make.top.equalTo(self.collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                self.userCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation {
                userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(view)
                    make.bottom.equalTo(view).offset(-132)
                    make.top.equalTo(collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                userCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
}

fileprivate extension String {
    static let muteonText = TRTCLocalize("Demo.TRTC.calling.muteon")
    static let muteoffText = TRTCLocalize("Demo.TRTC.calling.muteoff")
    static let handsfreeonText = TRTCLocalize("Demo.TRTC.calling.handsfreeon")
    static let handsfreeoffText = TRTCLocalize("Demo.TRTC.calling.handsfreeoff")
}
