//
//  TRTCCallingVideoViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift
import Toast_Swift

private let kSmallVideoViewWidth: CGFloat = 100.0

@objc public enum VideoCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class VideoCallingRenderView: UIView {
    
    private var isViewReady: Bool = false
    
    var userModel = CallingUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .center
        user.font = UIFont.systemFont(ofSize: 11)
        user.numberOfLines = 2
        return user
    }()
    
    let volumeProgress: UIProgressView = {
        let progress = UIProgressView.init()
        progress.backgroundColor = .clear
        return progress
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        addSubview(cellImgView)
        cellImgView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-20)
        }
        addSubview(cellUserLabel)
        cellUserLabel.snp.remakeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(22)
            make.top.equalTo(cellImgView.snp.bottom).offset(2)
        }
        addSubview(volumeProgress)
        volumeProgress.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    func configModel(model: CallingUserModel) {
        backgroundColor = .darkGray
        let noModel = model.userId.count == 0
        if !noModel {
            cellUserLabel.text = model.name
            cellImgView.sd_setImage(with: URL(string: model.avatarUrl), completed: nil)
            cellImgView.isHidden = model.isVideoAvaliable
            cellUserLabel.isHidden = model.isVideoAvaliable
            volumeProgress.progress = model.volume
        }
        volumeProgress.isHidden = noModel
    }
}

class TRTCCallingVideoViewController: UIViewController, CallingViewControllerResponder {
    lazy var userList: [CallingUserModel] = []
    
    /// 需要展示的用户列表
    var avaliableList: [CallingUserModel] {
        get {
//            return userList.filter { //如果需要屏蔽视频不可获得的用户，就可以替换成这个返回值
//                $0.isVideoAvaliable == true
//            }
            return userList.filter {
                $0.isEnter == true
            }
        }
    }
    var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
    let disposebag = DisposeBag()
    var curSponsor: CallingUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    let localPreView = VideoCallingRenderView.init()
    static var renderViews: [VideoCallingRenderView] = []
    
    var curState: VideoCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var collectionCount: Int {
        get {
            var count = ((avaliableList.count <= 4) ? avaliableList.count : 9)
            if curState == .onInvitee || curState == .dailing {
                count = 0
            }
            return count
        }
    }
    
    lazy var sponsorPanel: UIView = {
       let panel = UIView()
        panel.backgroundColor = .clear
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
        TRTCCalling.shareInstance().closeCamara()
        TRTCCallingVideoViewController.renderViews = []
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
        user.register(VideoCallUserCell.classForCoder(), forCellWithReuseIdentifier: "VideoCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .appBackGround
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
    
    static func getRenderView(userId: String) -> VideoCallingRenderView? {
        for renderView in renderViews {
            if  renderView.userModel.userId == userId {
                return renderView
            }
        }
        return nil
    }
}

extension TRTCCallingVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [CallingUserModel], isInit: Bool = false) {
        resetUserList()
        let usersFilter = users.filter {
            $0.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        }
        userList.append(contentsOf: usersFilter)
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            var sp = sponsor
            sp.isVideoAvaliable = false
            userList = [sp]
        } else {
            var curUser = CallingUserModel()
            if let name = ProfileManager.shared.curUserModel?.name,
                let avatar = ProfileManager.shared.curUserModel?.avatar,
                let userId = ProfileManager.shared.curUserModel?.userId {
                curUser.name = name
                curUser.avatarUrl = avatar
                curUser.userId = userId
                curUser.isVideoAvaliable = true
                curUser.isEnter = true
            }
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionCount == 2 {
            return 0
        }
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCallUserCell", for: indexPath) as! VideoCallUserCell
        if (indexPath.row < avaliableList.count) {
            let user = avaliableList[indexPath.row]
            cell.userModel = user
            if user.userId == V2TIMManager.sharedInstance()?.getLoginUser() ?? ""{
                localPreView.removeFromSuperview()
                cell.addSubview(localPreView)
                cell.sendSubviewToBack(localPreView)
                localPreView.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            }
        } else {
            cell.userModel = CallingUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        let collectHight = collectionView.frame.size.height
        if (collectionCount <= 4) {
            let width = collectWidth / 2
            let height = collectHight / 2
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                if indexPath.row == 0 && collectionCount == 1 {
                    return CGSize(width: width, height: width)
                } else {
                    return CGSize(width: width, height: height)
                }
            } else {
                return CGSize(width: width, height: height)
            }
        } else {
            let width = collectWidth / 3
            let height = collectHight / 3
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// enterUser回调 每个用户进来只能调用一次
    /// - Parameter user: 用户信息
    func enterUser(user: CallingUserModel) {
        if user.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? "" {
            let renderView = VideoCallingRenderView()
            renderView.userModel = user
            TRTCCalling.shareInstance().startRemoteView(userId: user.userId, view: renderView)
            TRTCCallingVideoViewController.renderViews.append(renderView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
            renderView.addGestureRecognizer(tap)
            pan.require(toFail: tap)
            renderView.addGestureRecognizer(pan)
        }
        curState = .calling
        updateUser(user: user, animated: true)
    }
    
    func leaveUser(user: CallingUserModel) {
        TRTCCalling.shareInstance().stopRemoteView(userId: user.userId)
        TRTCCallingVideoViewController.renderViews = TRTCCallingVideoViewController.renderViews.filter {
            $0.userModel.userId != user.userId
        }
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            let dstUser = userList[index]
            let animate = dstUser.isVideoAvaliable
            userList.remove(at: index)
            reloadData(animate: animate)
        }
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
    
    func updateUserVolume(user: CallingUserModel) {
        if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
            firstRender.userModel = user
        } else {
            localPreView.userModel = user
        }
    }
    
    func reloadData(animate: Bool = false) {
        
        if curState == .calling && collectionCount > 2 {
            userCollectionView.isHidden = false
        } else {
            userCollectionView.isHidden = true
        }
        
        if collectionCount <= 2 {
            updateLayout()
            return
        }
        
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
    
    func updateLayout() {
        func setLocalViewInVCView(frame: CGRect, shouldTap: Bool = false) {
            if localPreView.frame == frame {
                return
            }
            localPreView.isUserInteractionEnabled = shouldTap
            localPreView.subviews.first?.isUserInteractionEnabled = !shouldTap
            if localPreView.superview != view {
                let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                if localPreView.superview == nil {
                    view.insertSubview(localPreView, aboveSubview: userCollectionView)
                }
                localPreView.frame = preFrame
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            }
        }
        
        if collectionCount == 2 {
            if localPreView.superview != view { // 从9宫格变回来
                setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                   y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
            } else { //进来了一个人
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.collectionCount == 2 {
                        if self.localPreView.bounds.size.width != kSmallVideoViewWidth {
                            setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                            y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
                        }
                    }
                }
            }
            
            let userFirst = avaliableList.filter {
                $0.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
            }.first
            
            if let user = userFirst {
                if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
                    firstRender.userModel = user
                    if firstRender.superview != view {
                        let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                        view.insertSubview(firstRender, belowSubview: localPreView)
                        firstRender.frame = preFrame
                        UIView.animate(withDuration: 0.1) {
                            firstRender.frame = self.view.bounds
                        }
                    } else {
                        firstRender.frame = self.view.bounds
                    }
                } else {
                    print("error")
                }
            }
            
        } else { //用户退出只剩下自己（userleave引起的）
            if collectionCount == 1 {
                setLocalViewInVCView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
            }
        }
    }
}

extension TRTCCallingVideoViewController {
    func setupUI() {
        TRTCCallingVideoViewController.renderViews = []
        ToastManager.shared.position = .bottom
        view.backgroundColor = .appBackGround
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view).offset(-132)
            make.top.equalTo(topPadding + 62)
        }
        view.addSubview(localPreView)
        localPreView.backgroundColor = .appBackGround
        localPreView.frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
        localPreView.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
        localPreView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        localPreView.addGestureRecognizer(pan)
        userCollectionView.isHidden = true
        
        setupSponsorPanel(topPadding: topPadding)
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
        AppUtils.shared.alertUserTips(self)
        TRTCCalling.shareInstance().openCamera(frontCamera: true, view: localPreView)
    }
    
    func setupSponsorPanel(topPadding: CGFloat) {
        // sponsor
        if let sponsor = curSponsor {
            view.addSubview(sponsorPanel)
            sponsorPanel.snp.makeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.top.equalTo(topPadding + 18)
                make.height.equalTo(60)
            }
            //发起者头像
            let userImage = UIImageView()
            sponsorPanel.addSubview(userImage)
            userImage.snp.makeConstraints { (make) in
                make.trailing.equalTo(sponsorPanel).offset(-18)
                make.top.equalTo(sponsorPanel)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            userImage.sd_setImage(with: URL(string: sponsor.avatarUrl), completed: nil)
            
            //发起者名字
            let userName = UILabel()
            userName.textAlignment = .right
            userName.font = UIFont.boldSystemFont(ofSize: 30)
            userName.textColor = .white
            userName.text = sponsor.name
            sponsorPanel.addSubview(userName)
            userName.snp.makeConstraints { (make) in
                make.trailing.equalTo(userImage.snp.leading).offset(-6)
                make.height.equalTo(32)
                make.top.equalTo(sponsorPanel)
                make.leading.equalTo(sponsorPanel)
            }
            
            //提醒文字
            let invite = UILabel()
            invite.textAlignment = .right
            invite.font = UIFont.systemFont(ofSize: 13)
            invite.textColor = .white
            invite.text = .inviteVideoCallText
            sponsorPanel.addSubview(invite)
            invite.snp.makeConstraints { (make) in
                make.trailing.equalTo(userImage.snp.leading).offset(-6)
                make.height.equalTo(32)
                make.top.equalTo(userName.snp.bottom).offset(2)
                make.leading.equalTo(sponsorPanel)
            }
        }
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage(named: "ic_hangup"), for: .normal)
            view.addSubview(hangup)
            hangup.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
                guard let self = self else {return}
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
                    curUser.isVideoAvaliable = true
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
                make.width.equalTo(60)
                make.height.equalTo(60)
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
                make.width.equalTo(60)
                make.height.equalTo(60)
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
        userCollectionView.isHidden = ((curState != .calling) || (collectionCount <= 2))
        if let _ = curSponsor {
            sponsorPanel.isHidden = curState == .calling
        }
        
        switch curState {
        case .dailing:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            break
        case .onInvitee:
            hangup.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
            }
            
            accept.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.bottom.equalTo(view).offset(-32)
                make.width.equalTo(60)
                make.height.equalTo(60)
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
    
    @objc func handleTapGesture(tap: UIPanGestureRecognizer) {
        if collectionCount != 2 {
            return
        }
        
        if tap.view == localPreView {
            if localPreView.frame.size.width == kSmallVideoViewWidth {
                let userFirst = avaliableList.filter {
                    $0.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
                }.first
                
                if let user = userFirst {
                    if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
                        UIView.animate(withDuration: 0.3, animations: { [weak firstRender, weak self] in
                            guard let `self` = self else { return }
                            self.localPreView.frame = self.view.frame
                            firstRender?.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                        y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                        }) { [weak self] (result) in
                            guard let `self` = self else { return }
                            firstRender.removeFromSuperview()
                            self.view.insertSubview(firstRender, aboveSubview: self.localPreView)
                        }
                    }
                }
                
            }
        } else {
            if let smallView = tap.view {
                if smallView.frame.size.width == kSmallVideoViewWidth {
                    UIView.animate(withDuration: 0.3, animations: { [weak smallView ,weak self] in
                        guard let self = self else {return}
                        smallView?.frame = self.view.frame
                        self.localPreView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                         y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                        
                    }) { [weak self] (result) in
                        guard let `self` = self else { return }
                        smallView.removeFromSuperview()
                        self.view.insertSubview(smallView, belowSubview: self.localPreView)
                    }
                }
            }
        }
    }
    
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        if let smallView = pan.view {
            if smallView.frame.size.width == kSmallVideoViewWidth {
                if (pan.state == .changed) {
                    let translation = pan.translation(in: view)
                    let newCenterX = translation.x + (smallView.center.x)
                    let newCenterY = translation.y + (smallView.center.y)
                    if ( newCenterX < (smallView.bounds.width) / 2) ||
                        ( newCenterX > view.bounds.size.width - (smallView.bounds.width) / 2)  {
                        return
                    }
                    if ( newCenterY < (smallView.bounds.height) / 2) ||
                        (newCenterY > view.bounds.size.height - (smallView.bounds.height) / 2)  {
                        return
                    }
                    
                    UIView.animate(withDuration: 0.1) {
                        smallView.center = CGPoint(x: newCenterX, y: newCenterY)
                    }
                    pan.setTranslation(.zero, in: view)
                }
            }
        }
    }
}

fileprivate extension String {
    static let inviteVideoCallText = TRTCLocalize("Demo.TRTC.calling.invitetovideocall")
    static let muteonText = TRTCLocalize("Demo.TRTC.calling.muteon")
    static let muteoffText = TRTCLocalize("Demo.TRTC.calling.muteoff")
    static let handsfreeonText = TRTCLocalize("Demo.TRTC.calling.handsfreeon")
    static let handsfreeoffText = TRTCLocalize("Demo.TRTC.calling.handsfreeoff")
}
