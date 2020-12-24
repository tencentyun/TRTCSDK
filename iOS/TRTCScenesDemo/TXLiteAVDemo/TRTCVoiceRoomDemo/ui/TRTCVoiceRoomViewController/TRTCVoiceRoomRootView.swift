//
//  TRTCVoiceRoomRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

class TRTCVoiceRoomRootView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCVoiceRoomViewModel
    public weak var rootViewController: UIViewController?
    public var alertController: UIAlertController?
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let backgroundLayer: CALayer = {
        // fillCode
        let layer = CAGradientLayer()
        layer.colors = [UIColor.init(0x13294b).cgColor, UIColor.init(0x000000).cgColor]
        layer.locations = [0.2, 1.0]
        layer.startPoint = CGPoint(x: 0.4, y: 0)
        layer.endPoint = CGPoint(x: 0.6, y: 1.0)
        return layer
    }()
    
    let masterContainer: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    let masterSeatView: TRTCVoiceRoomSeatView = {
        let view = TRTCVoiceRoomSeatView.init(state: .masterSeatEmpty)
        return view
    }()
    
    let seatCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 66, height: 95)
        layout.minimumLineSpacing = 30.0
        layout.minimumInteritemSpacing = (UIScreen.main.bounds.width - 60.0 - (66.0 * 3)) / 2.0
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TRTCVoiceRoomSeatCell.self, forCellWithReuseIdentifier: "TRTCVoiceRoomSeatCell")
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    lazy var tipsView: TRTCVoiceRoomTipsView = {
        let view = TRTCVoiceRoomTipsView.init(frame: .zero, viewModel: viewModel)
        return view
    }()
    
    let mainMenuView: TRTCVoiceRoomMainMenuView = {
        let icons: [IconTuple] = [
            (UIImage.init(named: "voiceroom_message_normal")!, UIImage.init(named: "voiceroom_message_select")!),
            (UIImage.init(named: "voiceroom_mic_close")!, UIImage.init(named: "voiceroom_mic_open")!),
            (UIImage.init(named: "voiceroom_voice_close")!, UIImage.init(named: "voiceroom_voice_open")!),
            (UIImage.init(named: "voiceroom_audioEffect_close")!, UIImage.init(named: "voiceroom_audioEffect_open")!)
        ]
        let view = TRTCVoiceRoomMainMenuView.init(icons: icons)
        return view
    }()
    
    lazy var msgInputView: TRTCVoiceRoomMsgInputView = {
        let view = TRTCVoiceRoomMsgInputView.init(frame: .zero, viewModel: viewModel)
        view.isHidden = true
        return view
    }()
    
    lazy var audiceneListView: TRTCAudienceListView = {
        let view = TRTCAudienceListView.init(viewModel: viewModel)
        view.hide()
        return view
    }()
    
    lazy var audioEffectView: AudioEffectSettingView = {
        let view = AudioEffectSettingView.init(type: .default)
        if let manager = TRTCCloud.sharedInstance()?.getAudioEffectManager() {
            view.setAudioEffectManager(manager)
        }
        return view
    }()
    
    deinit {
        TRTCLog.out("reset audio settings")
    }
    
    // MARK: - 视图生命周期
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
    }
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        backgroundLayer.frame = bounds;
        layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(masterContainer)
        masterContainer.addSubview(masterSeatView)
        addSubview(seatCollection)
        addSubview(tipsView)
        addSubview(mainMenuView)
        addSubview(msgInputView)
        addSubview(audiceneListView)
        addSubview(audioEffectView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        activateConstraintsOfMasterArea()
        activateConstraintsOfCustomSeatArea()
        activateConstraintsOfTipsView()
        activateConstraintsOfMainMenu()
        activateConstraintsOfTextView()
        activateConstraintsOfAudiceneList()
    }

    func bindInteraction() {
        seatCollection.delegate = self
        seatCollection.dataSource = self
        /// 此方法负责做viewModel和视图的绑定操作
        mainMenuView.delegate = self
    }
}

extension TRTCVoiceRoomRootView: TRTCVoiceRoomMainMenuDelegate {
    func menuView(menu: TRTCVoiceRoomMainMenuView, click item: UIButton, index: Int) {
        switch index {
        case 0:
            // 消息框
            viewModel.openMessageTextInput()
        case 1:
            // 麦克风
            if viewModel.muteAction(isMute: item.isSelected) {
                item.isSelected = !item.isSelected
            }
        case 2:
            // 外放
            viewModel.spechAction(isMute: item.isSelected)
            item.isSelected = !item.isSelected
        case 3:
            // 音效
            viewModel.openAudioEffectMenu()
        default:
            break
        }
    }
}

// MARK: - collection view delegate
extension TRTCVoiceRoomRootView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = viewModel.anchorSeatList[indexPath.row]
        model.action?(indexPath.row + 1) // 转换座位号输入
    }
}

extension TRTCVoiceRoomRootView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.anchorSeatList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCVoiceRoomSeatCell", for: indexPath)
        let model = viewModel.anchorSeatList[indexPath.row]
        if let seatCell = cell as? TRTCVoiceRoomSeatCell {
            // 配置 seatCell 信息
            seatCell.setCell(model: model)
        }
        return cell
    }
}

extension TRTCVoiceRoomRootView {
    func activateConstraintsOfMasterArea() {
        masterContainer.snp.makeConstraints { (make) in
            make.right.left.equalToSuperview()
            make.height.equalTo(186)
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            } else {
                // Fallback on earlier versions
                make.top.equalToSuperview().offset(64)
            }
        }
        masterSeatView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(88)
            make.height.equalTo(120)
        }
    }
    
    func activateConstraintsOfCustomSeatArea() {
        seatCollection.snp.makeConstraints { (make) in
            make.top.equalTo(masterContainer.snp.bottom)
            make.height.equalTo(220)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
    }
    
    func activateConstraintsOfTipsView() {
        tipsView.snp.makeConstraints { (make) in
            make.top.equalTo(seatCollection.snp.bottom).offset(25)
            make.bottom.equalTo(mainMenuView.snp.top).offset(-25)
            make.left.right.equalToSuperview()
        }
    }
    
    func activateConstraintsOfMainMenu() {
        mainMenuView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-10)
            }
        }
    }
    
    func activateConstraintsOfTextView() {
        msgInputView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func activateConstraintsOfAudiceneList() {
        audiceneListView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
    }
}

extension TRTCVoiceRoomRootView: TRTCVoiceRoomViewResponder {
    
    func stopPlayBGM() {
        audioEffectView.stopPlay()
    }
    
    func recoveryVoiceSetting() {
        audioEffectView.recoveryVoiceSetting()
    }
    
    func showAudioEffectView() {
        audioEffectView.show()
    }
    
    func audienceListRefresh() {
        audiceneListView.refreshList()
    }
    
    func onSeatMute(isMute: Bool) {
        if isMute {
            makeToast("被房主禁言", duration: 0.3)
        } else {
            makeToast("被房主解禁", duration: 0.3)
            if viewModel.isSelfMute {
                return;
            }
        }
        mainMenuView.changeMixStatus(isMute: isMute)
    }
    
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?) {
        if let alert = alertController {
            alert.dismiss(animated: false) { [weak self] in
                guard let `self` = self else { return }
                self.alertController = nil
            }
        }
        let alertController = UIAlertController.init(title: info.title, message: info.message, preferredStyle: .alert)
        let sureAlertAction = UIAlertAction.init(title: "接受", style: .default) { (action) in
            sureAction()
            alertController.dismiss(animated: false) { [weak self] in
                guard let `self` = self else { return }
                self.alertController = nil
            }
        }
        let cancelAlertAction = UIAlertAction.init(title: "拒绝", style: .cancel) { (action) in
            cancelAction?()
            alertController.dismiss(animated: false) { [weak self] in
                guard let `self` = self else { return }
                self.alertController = nil
            }
        }
        alertController.addAction(sureAlertAction)
        alertController.addAction(cancelAlertAction)
        rootViewController?.present(alertController, animated: false, completion: { [weak self] in
            guard let `self` = self else { return }
            self.alertController = alertController
        })
    }
    
    func showActionSheet(actionTitles: [String], actions: @escaping (Int) -> Void) {
        let actionSheet = UIAlertController.init(title: "请选择", message: "", preferredStyle: .actionSheet)
        actionTitles.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let action = UIAlertAction.init(title: title, style: UIAlertAction.Style.default) { (action) in
                actions(index)
                actionSheet.dismiss(animated: true, completion: nil)
            }
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
        rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func showToast(message: String) {
        makeToast(message)
    }
    
    func popToPrevious() {
        rootViewController?.navigationController?.popViewController(animated: true)
         audioEffectView.resetAudioSetting()
    }
    
    func switchView(type: VoiceRoomViewType) {
        switch type {
        case .audience:
            mainMenuView.audienceType()
        case .anchor:
            mainMenuView.anchorType()
        }
    }
    
    func changeRoom(title: String) {
        rootViewController?.title = title
    }
    
    func refreshAnchorInfos() {
        if let masterAnchor = viewModel.masterAnchor {
            masterSeatView.setSeatInfo(model: masterAnchor)
        }
        seatCollection.reloadData()
    }
    
    func refreshMsgView() {
        tipsView.refreshList()
    }
    
    func msgInput(show: Bool) {
        if show {
            msgInputView.showMsgInput()
        } else {
            msgInputView.hideTextInput()
        }
    }
    
    func audiceneList(show: Bool) {
        if show {
            audiceneListView.show()
        } else {
            audiceneListView.hide()
        }
    }
    
    
}

/// MARK: - internationalization string
fileprivate extension String {
    
}


