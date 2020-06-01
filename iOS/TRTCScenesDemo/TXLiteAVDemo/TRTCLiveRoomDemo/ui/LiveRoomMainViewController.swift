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
    weak var liveRoom: TRTCLiveRoomImpl?
    var roomInfos: [TRTCLiveRoomInfo] = []
    
    @objc public init(liveRoom: TRTCLiveRoomImpl) {
        self.liveRoom = liveRoom
        super.init(nibName: nil, bundle: nil)
    }
    
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
        collection.backgroundColor = .appBackGround
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
        collection.backgroundColor = .appBackGround
        collection.isScrollEnabled = true
        view.addSubview(collection)
        collection.delegate = self
        collection.dataSource = self
        let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(loadRoomsInfo))
        header.setTitle("下拉刷新", for: .pulling)
        header.setTitle("刷新中", for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        collection.mj_header = header
        return collection
    }()
    
    lazy var createRoomBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .appTint
        btn.setTitle("新建直播间", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 6
        view.addSubview(btn)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }

    private func initNavigationItemTitleView() {
        let titleView = UILabel()
        titleView.text = "视频互动直播"
        titleView.textColor = .white
        titleView.textAlignment = .center
        titleView.font = UIFont.boldSystemFont(ofSize: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressTitle(longPress:)))
        recognizer.minimumPressDuration = 2
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
        if isCdnMode {
            let rightItem = UIBarButtonItem(title: "CDN模式", style: .done, target: nil, action: nil)
            navigationItem.rightBarButtonItem = rightItem
        }
    }

    @objc private func longPressTitle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
            let newMode = isCdnMode ? "TRTC" : "CDN"
            let alert = UIAlertController(title: "是否需要切换到\(newMode)模式", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (ok) in
                
            }
            let okAction = UIAlertAction(title: "确定", style: .default) { (ok) in
                if isCdnMode { //cdn 切 trtc
                    UserDefaults.standard.set(false, forKey: "liveRoomConfig_useCDNFirst")
                    UserDefaults.standard.set(nil, forKey: "liveRoomConfig_cndPlayDomain")
                } else { //trtc 切 cdn
                    UserDefaults.standard.set(true, forKey: "liveRoomConfig_useCDNFirst")
                    //此处设置您的 CDN 推流地址
                    UserDefaults.standard.set("http://3891.liveplay.myqcloud.com/live", forKey: "liveRoomConfig_cndPlayDomain")
                }
                self.view.makeToast("重启app后\(newMode)模式生效")
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
