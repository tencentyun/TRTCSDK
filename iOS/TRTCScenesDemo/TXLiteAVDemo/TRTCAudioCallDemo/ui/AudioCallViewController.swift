//
//  AudioCallViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/13/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import RxSwift

@objc public enum audioCallState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class AudioCallViewController: UIViewController {
    lazy var userList: [AudioCallUserModel] = []
    lazy var inviteeList: [AudioCallUserModel] = []
    var dismissBlock: (()->Void)? = nil
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
    let disposebag = DisposeBag()
    let curSponsor: AudioCallUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    
    var curState: audioCallState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var OnInviteePanelList: [AudioCallUserModel] {
        get {
            return inviteeList.filter {
                let isCurrent = $0.userId == AudioCallUtils.shared.curUserId()
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
        view.addSubview(panel)
        let label = UILabel()
        label.textColor = UIColor(hex: "#a4a4a4")
        label.text = "他们也在"
        label.textAlignment = .center
        panel.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(panel)
            make.height.equalTo(36)
        }
        panel.addSubview(OninviteeStackView)
        OninviteeStackView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(panel)
            make.top.equalTo(label.snp.bottom)
        }
        return panel
    }()
    
    init(sponsor: AudioCallUserModel? = nil) {
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
    
    func getUserById(userId: String) -> AudioCallUserModel? {
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
