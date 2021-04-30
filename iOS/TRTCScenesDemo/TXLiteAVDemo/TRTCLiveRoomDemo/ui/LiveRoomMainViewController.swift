//
//  LiveRoomMainViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 2020/2/21.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

class LiveRoomMainViewController: UIViewController {
    weak var liveRoom: TRTCLiveRoom?
    var roomInfos: [TRTCLiveRoomInfo] = []
    
    @objc public init(liveRoom: TRTCLiveRoom) {
        self.liveRoom = liveRoom
        super.init(nibName: nil, bundle: nil)
    }
    
    let colors = [UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0,
                          blue: 75.0 / 255.0, alpha: 1).cgColor,
                  UIColor(red: 5.0 / 255.0, green: 12.0 / 255.0,
                          blue: 23.0 / 255.0, alpha: 1).cgColor]
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var roomsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                     collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.register(LiveRoomCollectionViewCell.classForCoder(),
                       forCellWithReuseIdentifier: "LiveRoomCollectionViewCell")
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        
        collection.showsVerticalScrollIndicator = true
        collection.showsHorizontalScrollIndicator = false
        collection.contentMode = .scaleToFill
        collection.isScrollEnabled = true
        collection.delegate = self
        collection.dataSource = self
        let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(loadRoomsInfo))
        header.setTitle(.pullRefreshText, for: .pulling)
        header.setTitle(.refreshingText, for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        collection.mj_header = header
        return collection
    }()
    
    lazy var createRoomBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "createLivingRoom"), for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItemTitleView()
        setupUI()
        liveRoom?.setSelfProfile(name: ProfileManager.shared.curUserModel?.name ?? "", avatarURL: ProfileManager.shared.curUserModel?.avatar ?? "", callback: { (code, error) in
        })
        loadRoomsInfo()
    }
    
    deinit {
        debugPrint("deinit\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRoomsInfo()
        TRTCCloud.sharedInstance()?.delegate = liveRoom
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func initNavigationItemTitleView() {
        let titleView = UILabel()
        titleView.text = .videoInteractionText
        titleView.textColor = .black
        titleView.textAlignment = .center
        titleView.font = UIFont.boldSystemFont(ofSize: 17)
        titleView.adjustsFontSizeToFitWidth = true
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressTitle(longPress:)))
        recognizer.minimumPressDuration = 2
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
        let rightCDN = UIBarButtonItem()
        if isCdnMode {
            rightCDN.title = "CDN模式"
        } else {
            rightCDN.title = ""
        }
        
        let helpBtn = UIButton(type: .custom)
        helpBtn.setImage(UIImage(named: "help_small"), for: .normal)
        helpBtn.addTarget(self, action: #selector(connectWeb), for: .touchUpInside)
        helpBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView: helpBtn)
        rightItem.tintColor = .black
        navigationItem.rightBarButtonItems = [rightItem, rightCDN]
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "liveroom_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        backItem.tintColor = .black
        navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/35428") {
            UIApplication.shared.openURL(url)
        }
    }

    @objc private func longPressTitle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
            let newMode = isCdnMode ? "TRTC" : "CDN"
            let alert = UIAlertController(title: LocalizeReplaceXX(.switchToText, newMode), message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: .cancelText, style: .cancel) { (ok) in
                
            }
            let okAction = UIAlertAction(title: .confirmText, style: .default) { (ok) in
                if isCdnMode { //cdn 切 trtc
                    UserDefaults.standard.set(false, forKey: "liveRoomConfig_useCDNFirst")
                    UserDefaults.standard.set(nil, forKey: "liveRoomConfig_cndPlayDomain")
                } else { //trtc 切 cdn
                    UserDefaults.standard.set(true, forKey: "liveRoomConfig_useCDNFirst")
                    //此处设置您的 CDN 推流地址
                    UserDefaults.standard.set("http://3891.liveplay.myqcloud.com/live", forKey: "liveRoomConfig_cndPlayDomain")
                }
                self.view.makeToast("\(newMode)mode \(String.restartText)")
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

private extension String {
    static let pullRefreshText = TRTCLocalize("Demo.TRTC.LiveRoom.pullrefresh")
    static let refreshingText = TRTCLocalize("Demo.TRTC.LiveRoom.refreshing")
    static let videoInteractionText = TRTCLocalize("Demo.TRTC.LiveRoom.videointeraction")
    static let switchToText = TRTCLocalize("Demo.TRTC.LiveRoom.switchto")
    static let cancelText = TRTCLocalize("Demo.TRTC.LiveRoom.cancel")
    static let confirmText = TRTCLocalize("Demo.TRTC.LiveRoom.confirm")
    static let restartText = TRTCLocalize("Demo.TRTC.LiveRoom.restarttotakeeffect")
}
