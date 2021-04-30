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

public class TRTCTopView : UIView {
    
    private var isViewReady = false
    
    public var backButtonDidClick : (()->())?
    
    public var helpButtonDidClick : (()->())?
    
    public var title : String? {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    let backBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "ic_back_white"), for: .normal)
        return btn
    }()
    
    let helpBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "help_small"), for: .normal)
        return btn
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private func constructViewHierarchy() {
        addSubview(backBtn)
        addSubview(titleLabel)
        addSubview(helpBtn)
    }
    
    private func activateConstraints() {
        backBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(self.snp_bottom).offset(-22)
            make.size.equalTo(CGSize(width: 44, height: 40))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
        }
        helpBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func bindInteraction() {
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        helpBtn.addTarget(self, action: #selector(helpBtnClick), for: .touchUpInside)
    }
    
    @objc private func backBtnClick() {
        if let click = backButtonDidClick {
            click()
        }
    }
    @objc private func helpBtnClick() {
        if let click = helpButtonDidClick {
            click()
        }
    }
}

class TRTCVoiceRoomListRootView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCVoiceRoomListViewModel
    weak var rootViewController: UIViewController?
    var scrollviewBaseContentOffsetY:CGFloat = 0.0
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomListViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "F4F5F9")
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let topView : TRTCTopView = {
        let topV = TRTCTopView(frame: .zero)
        topV.title = .controllerTitle
        return topV
    }()
    
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
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        btn.titleLabel?.textColor = .white
        btn.setImage(UIImage.init(named: "add"), for: .normal)
        btn.setTitle(.createText, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.backgroundColor = UIColor(hex: "006EFF")
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return btn
    }()
    
    let roomListCollection: UICollectionView = {
        let margin = 20
        let layout = UICollectionViewFlowLayout.init()
        let itemWidth = floor((ScreenWidth - CGFloat(3*margin)) * 0.5)
        layout.itemSize = CGSize.init(width: itemWidth, height: convertPixel(h: 180))
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 137+90, right: 0)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TRTCVoiceRoomListCell.self, forCellWithReuseIdentifier: "TRTCVoiceRoomListCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createButton.layer.cornerRadius = createButton.frame.height * 0.5
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(roomListCollection)
        addSubview(createButton)
        addSubview(loading)
        addSubview(topView)
    }

    func activateConstraints() {
        roomListCollection.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalTo(topView.snp_bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        createButton.sizeToFit()
        let createBtnWidth = createButton.frame.width
        createButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-90 - kDeviceSafeBottomHeight)
            make.centerX.equalToSuperview()
            make.width.equalTo(createBtnWidth+40)
            make.height.equalTo(52)
        }
        loading.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.snp_top).offset(kDeviceSafeTopHeight + 44)
        }
    }

    func bindInteraction() {
        createButton.addTarget(self, action: #selector(createButtonAction(_:)), for: .touchUpInside)
        roomListCollection.delegate = self
        roomListCollection.dataSource = self
        let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(refreshListAction))
        header.setTitle(.pullrefreshText, for: .pulling)
        header.setTitle(.refreshingText, for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        roomListCollection.mj_header = header
        topView.backButtonDidClick = { [weak self] in
            guard let `self` = self else { return }
            self.back()
        }
        topView.helpButtonDidClick = { [weak self] in
            guard let `self` = self else { return }
            self.connectWeb()
        }
    }
    /// 取消
    func back() {
        self.rootViewController?.navigationController?.popViewController(animated: true)
    }
    
    /// 连接官方文档
    func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/35428") {
            UIApplication.shared.openURL(url)
        }
    }
    @objc
    func createButtonAction(_ sender: UIButton) {
        let viewController = viewModel.makeCreateViewController()
        if viewController is TRTCCreateVoiceRoomViewController {
            let vc = viewController as! TRTCCreateVoiceRoomViewController
            vc.screenShot = self.snapshotView(afterScreenUpdates: false)
        }
        rootViewController?.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @objc
    func refreshListAction() {
        viewModel.getRoomList()
    }
}

extension TRTCVoiceRoomListRootView: UICollectionViewDelegate {
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

extension TRTCVoiceRoomListRootView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCVoiceRoomListCell", for: indexPath)
        if let roomCell = cell as? TRTCVoiceRoomListCell {
            let roomInfo = viewModel.roomList[indexPath.item]
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
    static let pullrefreshText = TRTCLocalize("Demo.TRTC.LiveRoom.pullrefresh")
    static let refreshingText = TRTCLocalize("Demo.TRTC.LiveRoom.refreshing")
    static let controllerTitle = TRTCLocalize("Demo.TRTC.VoiceRoom.voicechatroom")
    static let createText = TRTCLocalize("Demo.TRTC.VoiceRoom.createroom")
}



