//
//  VideoCallViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift

let kSmallVideoWidth: CGFloat = 100.0

@objc public enum VideoCallState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class VideoRenderView: UIView {    
    var UserModel = VideoCallUserModel() {
        didSet {
            configModel(model: UserModel)
        }
    }
    
    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        addSubview(img)
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .center
        user.font = UIFont.systemFont(ofSize: 11)
        user.numberOfLines = 2
        addSubview(user)
        return user
    }()
    
    func configModel(model: VideoCallUserModel) {
        backgroundColor = .darkGray
        let noModel = model.userId.count == 0
        if !noModel {
            cellImgView.snp.remakeConstraints { (make) in
                make.width.height.equalTo(40)
                make.centerX.equalTo(self)
                make.centerY.equalTo(self).offset(-20)
            }
            cellImgView.sd_setImage(with: URL(string: UserModel.avatarUrl), completed: nil)
            
            cellUserLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(self)
                make.height.equalTo(22)
                make.top.equalTo(cellImgView.snp.bottom).offset(2)
            }
            cellUserLabel.text = UserModel.name
            
            cellImgView.isHidden = model.isVideoAvaliable
            cellUserLabel.isHidden = model.isVideoAvaliable
        }
    }
}

class VideoCallViewController: UIViewController {
    lazy var userList: [VideoCallUserModel] = []
    
    /// 需要展示的用户列表
    var avaliableList: [VideoCallUserModel] {
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
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
    let disposebag = DisposeBag()
    let curSponsor: VideoCallUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    let localPreView = UIView()
    static var renderViews: [VideoRenderView] = []
    
    var curState: VideoCallState {
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
        view.addSubview(panel)
        return panel
    }()
    
    init(sponsor: VideoCallUserModel? = nil) {
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
        TRTCVideoCall.shared.closeCamara()
        VideoCallViewController.renderViews = []
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
    
    func getUserById(userId: String) -> VideoCallUserModel? {
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
    
    static func getRenderView(userId: String) -> VideoRenderView? {
        for renderView in renderViews {
            if  renderView.UserModel.userId == userId {
                return renderView
            }
        }
        return nil
    }
}
