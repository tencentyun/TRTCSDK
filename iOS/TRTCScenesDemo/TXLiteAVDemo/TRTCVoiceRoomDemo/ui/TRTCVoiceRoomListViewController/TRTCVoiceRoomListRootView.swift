//
//  TRTCVoiceRoomListRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift
import NVActivityIndicatorView

class TRTCVoiceRoomListRootView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCVoiceRoomListViewModel
    weak var rootViewController: UIViewController?
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomListViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 60),
                                          type: .ballRotate,
                                          color: .searchBarBackColor)
    
    let backgroundLayer: CALayer = {
        // fillCode
        let layer = CAGradientLayer()
        layer.colors = [UIColor.init(0x13294b).cgColor, UIColor.init(0x000000).cgColor]
        layer.locations = [0.2, 1.0]
        layer.startPoint = CGPoint(x: 0.4, y: 0)
        layer.endPoint = CGPoint(x: 0.6, y: 1.0)
        return layer
    }()
    
    let createButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "voiceroom_create_room"), for: .normal)
        return button
    }()
    
    let roomListCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let itemWidth = (UIScreen.main.bounds.width - 40 - 5) / 2.0
        layout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 40, right: 20)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TRTCVoiceRoomListCell.self, forCellWithReuseIdentifier: "TRTCVoiceRoomListCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        return collectionView
    }()
    
    // MARK: - 视图生命周期
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        backgroundLayer.frame = self.bounds;
        layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(roomListCollection)
        addSubview(createButton)
        addSubview(loading)
    }

    func activateConstraints() {
        roomListCollection.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        createButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(66)
            make.right.equalToSuperview().offset(-20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-30)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-30)
            }
        }
        loading.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(60)
        }
    }

    func bindInteraction() {
        createButton.addTarget(self, action: #selector(createButtonAction(_:)), for: .touchUpInside)
        roomListCollection.delegate = self
        roomListCollection.dataSource = self
        let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(refreshListAction))
        header.setTitle("下拉刷新", for: .pulling)
        header.setTitle("刷新中", for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        roomListCollection.mj_header = header
    }
    
    @objc
    func createButtonAction(_ sender: UIButton) {
        let viewController = viewModel.makeCreateViewController()
        rootViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func refreshListAction() {
        viewModel.getRoomList()
    }
}

extension TRTCVoiceRoomListRootView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 检查是否是自己的房间
        viewModel.clickRoomItem(index: indexPath.row)
    }
}

extension TRTCVoiceRoomListRootView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCVoiceRoomListCell", for: indexPath)
        if let roomCell = cell as? TRTCVoiceRoomListCell {
            let roomInfo = viewModel.roomList[indexPath.row]
            roomCell.setCell(model: roomInfo)
        }
        return cell
    }
}

extension TRTCVoiceRoomListRootView: TRTCVoiceRoomListViewResponder {
    func pushRoomView(viewController: UIViewController) {
        rootViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showToast(message: String) {
        self.makeToast(message)
    }
    
    func refreshList() {
        roomListCollection.reloadData()
    }
    
    func stopListRefreshing() {
        roomListCollection.mj_header?.endRefreshing()
    }
    
    func showLoading(message: String) {
        loading.startAnimating()
    }
    
    func hideLoading() {
        loading.stopAnimating()
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}



