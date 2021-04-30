//
//  TRTCChatSalonListRootView.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/12.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift
import NVActivityIndicatorView

class TRTCChatSalonListRootView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCChatSalonListViewModel
    weak var rootViewController: UIViewController?
    var scrollviewBaseContentOffsetY:CGFloat = 0.0
    
    init(frame: CGRect = .zero, viewModel: TRTCChatSalonListViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 60),
                                          type: .ballRotate,
                                          color: .searchBarBackColor)
    
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
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TRTCChatSalonListCell.self, forCellWithReuseIdentifier: "TRTCChatSalonListCell")
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 40, right: 20)
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
        header.setTitle(String.pullRefresh, for: .pulling)
        header.setTitle(String.refreshing, for: .refreshing)
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

extension TRTCChatSalonListRootView: UICollectionViewDelegate {
    public func updateBaseCollectionOffsetY() -> Void {
        scrollviewBaseContentOffsetY = roomListCollection.contentOffset.y
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 检查是否是自己的房间
        viewModel.clickRoomItem(index: indexPath.row)
        collectionView.panGestureRecognizer.isEnabled = true
    }
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if fabsf(Float(collectionView.contentOffset.y - scrollviewBaseContentOffsetY)) <= 0.001 &&
            !collectionView.isDragging &&
            !collectionView.isDecelerating {
            //bugfix 7P下拉刷新后，collectionCell无法选中
            collectionView.panGestureRecognizer.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                collectionView.panGestureRecognizer.isEnabled = true
            }
        }
    }
}

extension TRTCChatSalonListRootView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCChatSalonListCell", for: indexPath)
        if let roomCell = cell as? TRTCChatSalonListCell {
            let roomInfo = viewModel.roomList[indexPath.row]
            roomCell.setCell(model: roomInfo)
        }
        return cell
    }
}

extension TRTCChatSalonListRootView: TRTCChatSalonListViewResponder {
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
    static let pullRefresh = TRTCLocalize("Demo.TRTC.LiveRoom.pullrefresh")
    static let refreshing = TRTCLocalize("Demo.TRTC.LiveRoom.refreshing")
}



