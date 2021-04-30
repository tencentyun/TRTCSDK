//
//  TRTCMeetingMemberViewController.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/5/7.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift

protocol TRTCMeetingMemberVCDelegate: class {
    // 设置单个静音
    func onMuteAudio(userId: String, mute: Bool)
    
    // 设置单个禁画
    func onMuteVideo(userId: String, mute: Bool)
    
    // mute - true: 设置全体静音  false: 解除全体静音
    func onMuteAllAudio(mute: Bool)
    
    // mute - true: 设置全体静画  false: 解除全体静画
    func onMuteAllVideo(mute: Bool)
}

class TRTCMeetingMemberViewController: UIViewController {
    weak var delegate: TRTCMeetingMemberVCDelegate?

    let disposeBag = DisposeBag()
    
    // 缓存用户列表
    var attendeeList: [MeetingAttendeeModel]
    
    let muteAllAudioButton = UIButton()
    let muteAllVideoButton = UIButton()
    let unmuteAllAudioButton = UIButton()

    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.top
        }
        return 0
    }()
    
    lazy var memberCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width), collectionViewLayout: layout)
        collection.register(MeetingMemberCell.classForCoder(), forCellWithReuseIdentifier: "MeetingMemberCell")
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.delegate = self
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        collection.clipsToBounds = true
        collection.layer.cornerRadius = 20
        return collection
    }()
    
    
    init(attendeeList: [MeetingAttendeeModel]) {
        self.attendeeList = attendeeList;
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
