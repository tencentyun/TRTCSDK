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
    
    lazy var bgView: UIImageView = {
        let bg = UIImageView(frame: .zero)
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    
    let masterContainer: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    lazy var topView : TRTCVoiceRoomTopView = {
        var view = TRTCVoiceRoomTopView(viewModel: viewModel)
        return view
    }()
    
    let masterSeatView: TRTCVoiceRoomSeatView = {
        let view = TRTCVoiceRoomSeatView.init(state: .masterSeatEmpty)
        return view
    }()
    
    let seatCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: 64, height: 90)
        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 26
        layout.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
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
            IconTuple(normal: UIImage(named: "room_message")!, selected: UIImage(named: "room_message")!, type: .message),
            IconTuple(normal: UIImage(named: "room_leave_mic")!, selected: UIImage(named: "room_leave_mic")!, type: .micoff),
            IconTuple(normal: UIImage(named: "room_bgmusic")!, selected: UIImage(named: "room_bgmusic")!, type: .bgmusic),
            IconTuple(normal: UIImage(named: "room_voice_off")!, selected: UIImage(named: "room_voice_on")!, type: .mute),
            IconTuple(normal: UIImage(named: "room_more")!, selected: UIImage(named: "room_more")!, type: .more),
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
        bgView.sd_setImage(with: URL(string: viewModel.roomInfo.coverUrl), placeholderImage: nil, options: .continueInBackground, completed: nil)
    }
    
    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        backgroundLayer.frame = bounds;
        layer.insertSublayer(backgroundLayer, at: 0)
        addSubview(bgView)
        addSubview(topView)
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
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
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
    func menuView(menu: TRTCVoiceRoomMainMenuView, click item: IconTuple) -> Bool {
        switch item.type {
        case .message:
            // 消息框
            viewModel.openMessageTextInput()
            break
        case .bgmusic:
            // 音效
            showBgMusicAlert()
            break
        case .mute:
            // 麦克风
            if viewModel.isOwner {
                if let user = viewModel.masterAnchor?.seatUser {
                    viewModel.userMuteMap[user.userId] = item.isSelect
                    onAnchorMute(isMute: item.isSelect)
                }
            }
            else {
                if viewModel.mSelfSeatIndex > 0, let user = viewModel.anchorSeatList[viewModel.mSelfSeatIndex-1].seatUser, !(viewModel.anchorSeatList[viewModel.mSelfSeatIndex-1].seatInfo?.mute ?? true) {
                    viewModel.userMuteMap[user.userId] = item.isSelect
                    onAnchorMute(isMute: item.isSelect)
                }
            }
            return viewModel.muteAction(isMute: item.isSelect)
        case .more:
            viewModel.moreBtnClick()
            break
        case .micoff:
            let seatIndex = viewModel.mSelfSeatIndex
            if seatIndex > 0 && seatIndex <= viewModel.anchorSeatList.count {
                let model = viewModel.anchorSeatList[seatIndex - 1]
                viewModel.audienceClickMicoff(model: model)
            }
            break
        }
        return false
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
            seatCell.setCell(model: model, userMuteMap: viewModel.userMuteMap)
        }
        return cell
    }
}

extension TRTCVoiceRoomRootView {
    func activateConstraintsOfMasterArea() {
        masterContainer.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp_bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        masterSeatView.snp.makeConstraints { (make) in
            make.top.bottom.centerX.equalToSuperview()
            make.width.equalTo(convertPixel(w: 80))
        }
    }
    
    func activateConstraintsOfCustomSeatArea() {
        seatCollection.snp.makeConstraints { (make) in
            make.top.equalTo(masterContainer.snp.bottom).offset(20)
            make.height.equalTo(200)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
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
            make.height.equalTo(52)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-20)
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
        mainMenuView.audienceType()
    }
    
    func recoveryVoiceSetting() {
        audioEffectView.recoveryVoiceSetting()
    }
    
    func showAudioEffectView() {
        audioEffectView.show()
    }
    
    func audienceListRefresh() {
        audiceneListView.refreshList()
        topView.reloadAudienceList()
    }
    
    func onSeatMute(isMute: Bool) {
        if isMute {
            makeToast(.mutedText, duration: 0.3)
        } else {
            makeToast(.unmutedText, duration: 0.3)
            if viewModel.isSelfMute {
                return;
            }
        }
        mainMenuView.changeMixStatus(isMute: isMute)
    }
    
    func onAnchorMute(isMute: Bool) {
        if let master = viewModel.masterAnchor {
            masterSeatView.setSeatInfo(model: master, userMuteMap: viewModel.userMuteMap)
        }
        seatCollection.reloadData()
    }
    
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?) {
        let alertController = UIAlertController.init(title: info.title, message: info.message, preferredStyle: .alert)
        let sureAlertAction = UIAlertAction.init(title: .acceptText, style: .default) { (action) in
            sureAction()
        }
        let cancelAlertAction = UIAlertAction.init(title: .refuseText, style: .cancel) { (action) in
            cancelAction?()
        }
        alertController.addAction(sureAlertAction)
        alertController.addAction(cancelAlertAction)
        rootViewController?.present(alertController, animated: false, completion: {
            
        })
    }
    
    func showActionSheet(actionTitles: [String], actions: @escaping (Int) -> Void) {
        let actionSheet = UIAlertController.init(title: .selectText, message: "", preferredStyle: .actionSheet)
        actionTitles.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let action = UIAlertAction.init(title: title, style: UIAlertAction.Style.default) { (action) in
                actions(index)
                actionSheet.dismiss(animated: true, completion: nil)
            }
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction.init(title: .cancelText, style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
        rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func showMoreAlert() {
        let alert = TRTCVoiceRoomMoreAlert(viewModel: viewModel)
        addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
    }
    func showBgMusicAlert() {
        let alert = TRTCVoiceRoomSoundEffectAlert(viewModel: viewModel)
        addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
    }
    
    func showAudienceAlert(seat: SeatInfoModel) {
        let audienceList = viewModel.memberAudienceList
        let alert = TRTCVoiceRoomAudienceAlert(viewModel: viewModel, seatModel: seat, audienceList: audienceList)
        addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
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
            viewModel.userType = .audience
            mainMenuView.audienceType()
        case .anchor:
            if viewModel.isOwner {
                viewModel.userType = .owner
                mainMenuView.ownerType()
            }
            else {
                viewModel.userType = .anchor
                mainMenuView.anchorType()
            }
        }
    }
    
    func changeRoom(info: VoiceRoomInfo) {
        topView.reloadRoomInfo(info)
    }
    
    func refreshAnchorInfos() {
        if let masterAnchor = viewModel.masterAnchor {
            masterSeatView.setSeatInfo(model: masterAnchor, userMuteMap: viewModel.userMuteMap)
        }
        topView.reloadRoomAvatar()
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
    static let mutedText = TRTCLocalize("Demo.TRTC.Salon.seatmuted")
    static let unmutedText = TRTCLocalize("Demo.TRTC.Salon.seatunmuted")
    static let acceptText = TRTCLocalize("Demo.TRTC.LiveRoom.accept")
    static let refuseText = TRTCLocalize("Demo.TRTC.LiveRoom.refuse")
    static let selectText = TRTCLocalize("Demo.TRTC.Salon.pleaseselect")
    static let cancelText = TRTCLocalize("Demo.TRTC.LiveRoom.cancel")
}


