//
//  TRTCChatSalonRootView.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

class TRTCChatSalonRootView: UIView {
    enum TopTipsType {
        case requestTakeSeat(CSMemberRequestEntity)
        case handsUpSuccess
    }
    
    private class HeaderView: UICollectionReusableView {
        private var isViewReady = false
        let marginView: UIView = {
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor(hex: "999999")
            view.layer.cornerRadius = 1.5
            return view
        }()
        
        let titleLabel: UILabel = {
            let label = UILabel.init(frame: .zero)
            label.textColor = .textColor
            label.fontSize = 18.0
            return label
        }()
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard !isViewReady else { return }
            addSubview(marginView)
            addSubview(titleLabel)
            marginView.snp.makeConstraints { (make) in
                make.width.equalTo(3)
                make.height.equalTo(12)
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(marginView.snp.right).offset(10)
                make.centerY.equalTo(marginView.snp.centerY)
            }
        }
    }
    
    private var isViewReady: Bool = false
    let viewModel: TRTCChatSalonViewModel
    public weak var rootViewController: UIViewController?
    public var alertController: UIAlertController?
    
    init(frame: CGRect = .zero, viewModel: TRTCChatSalonViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .white
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    lazy var topTipsView: UIView = {
        let view = UIView.init()
        view.isHidden = true
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor(hex: "9E9E9E")?.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 2
        return view
    }()
    
    let seatCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TRTCChatSalonSeatCell.self, forCellWithReuseIdentifier: "TRTCChatSalonSeatCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ChatSalon.HeaderView")
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    lazy var requestTakeSeatListView: TRTCCSAudienceListView = {
        let view = TRTCCSAudienceListView.init(viewModel: viewModel)
        view.hide()
        return view
    }()
    
    let mainMenuView: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    // 退房按钮
    let leaveButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setTitle(.leaveText, for: .normal)
        button.setBackgroundImage(UIColor(hex: "F4F5F9")!.trans2Image(), for: .normal)
        button.setTitleColor(UIColor(hex: "FA585E"), for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    lazy var tipsView: TRTCChatSalonTakeSeatTipsView = {
        return TRTCChatSalonTakeSeatTipsView.init(frame: .zero, viewModel: viewModel)
    }()
    
    // 静音按钮
    let muteButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setImage(.micOn, for: .normal)
        button.setImage(.micOff, for: .selected)
        return button
    }()
    
    // 下麦按钮
    let leaveSeatButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setImage(.leaveMic, for: .normal)
        button.isHidden = true
        return button
    }()
    
    // 举手按钮
    let handUpButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setImage(.handsup, for: .selected)
        button.setImage(.handsupCancel, for: .normal)
        button.isHidden = true
        return button
    }()
    
    // 举手列表按钮
    let handUpListButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setImage(.handsupList, for: .normal)
        return button
    }()
    
    let handUpListDot: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 7)
        label.textColor = .white
        label.backgroundColor = UIColor.init(0xE35454)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        
        return label
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
        addSubview(topTipsView)
        addSubview(seatCollection)
        addSubview(mainMenuView)
        mainMenuView.addSubview(leaveSeatButton)
        mainMenuView.addSubview(muteButton)
        mainMenuView.addSubview(leaveButton)
        mainMenuView.addSubview(handUpButton)
        mainMenuView.addSubview(handUpListButton)
        mainMenuView.addSubview(handUpListDot)
        addSubview(requestTakeSeatListView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        activateConstraintsOfCustomSeatArea()
        activateConstraintsOfMainMenu()
        activateConstraintsOfAudiceneList()
    }

    func bindInteraction() {
        seatCollection.delegate = self
        seatCollection.dataSource = self
        /// 此方法负责做viewModel和视图的绑定操作
        muteButton.addTarget(self, action: #selector(mainMenuButtonAction(sender:)), for: .touchUpInside)
        handUpButton.addTarget(self, action: #selector(mainMenuButtonAction(sender:)), for: .touchUpInside)
        leaveSeatButton.addTarget(self, action: #selector(mainMenuButtonAction(sender:)), for: .touchUpInside)
        handUpListButton.addTarget(self, action: #selector(mainMenuButtonAction(sender:)), for: .touchUpInside)
        leaveButton.addTarget(self, action: #selector(mainMenuButtonAction(sender:)), for: .touchUpInside)
    }
}


// MARK: - collection view delegate
extension TRTCChatSalonRootView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.section == 0) {
            return CGSize(width: 80, height: 112)
        } else {
            return CGSize(width: 60, height: 92)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (section == 0) {
            return (UIScreen.main.bounds.width - 40 - 80 * 3) / 2.0
        } else {
            return (UIScreen.main.bounds.width - 40 - 60 * 4) / 3.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != 0 || !viewModel.isOwner {
            return
        }
        if indexPath.row > 0 {
            if indexPath.row > 0 && indexPath.row <= viewModel.anchorUserIDs.count {
                let userID = viewModel.anchorUserIDs[indexPath.row - 1]
                guard let model = viewModel.anchorSeatList[userID] else { return }
                model.action?(model) // 转换座位号输入
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: "ChatSalon.HeaderView",
                                                                         for: indexPath)
            if let header = view as? HeaderView {
                header.titleLabel.text = indexPath.section == 0 ? .anchorHeaderText : .audienceHeaderText
            }
            return view
        } else {
            return UICollectionReusableView.init()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width, height: 30)
    }
}

extension TRTCChatSalonRootView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.anchorUserIDs.count + 1
        } else {
            return viewModel.audienceUserIDs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCChatSalonSeatCell", for: indexPath)
        if let seatCell = cell as? TRTCChatSalonSeatCell {
            // 配置 seatCell 信息
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    guard let masterAnchor = viewModel.masterAnchor else { return seatCell }
                    seatCell.setCell(model: masterAnchor)
                } else {
                    let anchorID = viewModel.anchorUserIDs[indexPath.row - 1]
                    guard let model = viewModel.anchorSeatList[anchorID] else { return cell }
                    seatCell.setCell(model: model)
                }
                
            } else {
                let userID = viewModel.audienceUserIDs[indexPath.row]
                if let audience = viewModel.memberAudienceDic[userID] {
                    seatCell.setCell(audience: audience)
                }
            }
        }
        return cell
    }
    
    
}

extension TRTCChatSalonRootView {
    func activateConstraintsOfCustomSeatArea() {
        topTipsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            } else {
                // Fallback on earlier versions
                make.top.equalToSuperview().offset(64)
            }
            make.height.equalTo(0)
        }
        seatCollection.snp.makeConstraints { (make) in
            make.top.equalTo(topTipsView.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(mainMenuView.snp.top)
        }
    }
    
    func activateConstraintsOfMainMenu() {
        mainMenuView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                // Fallback on earlier versions
                make.bottom.equalToSuperview().offset(-20)
            }
        }
        leaveButton.sizeToFit()
        let width = leaveButton.frame.width
        leaveButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(36)
            make.width.equalTo(width+40)
        }
        // 主播观众公有
        muteButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(48)
        }
        // 主播端
        handUpListButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(muteButton.snp.left).offset(-20)
            make.height.width.equalTo(48)
        }
        handUpListDot.snp.makeConstraints { (make) in
            make.right.top.equalTo(handUpListButton)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(16)
        }
        // 观众端
        handUpButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(48)
        }
        leaveSeatButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(muteButton.snp.left).offset(-20)
            make.height.width.equalTo(48)
        }
    
    }
    
    func activateConstraintsOfAudiceneList() {
        requestTakeSeatListView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
}

extension TRTCChatSalonRootView {
    @objc
    private func mainMenuButtonAction(sender: UIButton) {
        switch sender {
        case handUpButton:
            
            viewModel.startTakeSeat(seatIndex: 0)
        case muteButton:
            muteButton.isSelected = !muteButton.isSelected
            let _ = viewModel.muteAction(isMute: muteButton.isSelected) // 返回值为false说明无法调整麦克风
        case leaveButton:
            if viewModel.roomType == .anchor && viewModel.isOwner {
                showAlert(info: (title: "", message: .ownerExitMsg), actionTitle: (sure: .sureActionTitle, cancel: .cancelActionTitle)) { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.exitRoom() // 主播销毁房间
                } cancelAction: {
                   
                }
            } else {
                showAlert(info: (title: "", message: .alertAudienceTitle), actionTitle: (sure: .alertAudienceConfirm, cancel: .alertAudienceCancel)) { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.exitRoom()
                } cancelAction: {
                   
                }
            }
        case handUpListButton:
            viewModel.openRequestTakeSeatList(isOpen: true)
            break
        case leaveSeatButton:
            viewModel.leaveSeatAction()
        default:
            break
        }
       
    }
    
    private func showAlert(info: (title: String, message: String),
                   actionTitle: (sure: String, cancel: String),
                   sureAction: @escaping () -> Void,
                   cancelAction: (() -> Void)?) {
        if let alert = alertController {
            alert.dismiss(animated: false) { [weak self] in
                guard let `self` = self else { return }
                self.alertController = nil
            }
        }
        let alertController = UIAlertController.init(title: info.title, message: info.message, preferredStyle: .alert)
        let sureAlertAction = UIAlertAction.init(title: actionTitle.sure, style: .default) { (action) in
            sureAction()
            alertController.dismiss(animated: false) { [weak self] in
                guard let `self` = self else { return }
                self.alertController = nil
            }
        }
        let cancelAlertAction = UIAlertAction.init(title: actionTitle.cancel, style: .cancel) { (action) in
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
    
    func showTopTips(type: TopTipsType) {
        guard requestTakeSeatListView.isHidden else {
            return
        }
        let innerView: UIView
        let height: CGFloat
        switch type {
        case .requestTakeSeat(let info):
            tipsView.currentTakeSeatInfo = info
            innerView = tipsView
            height = TRTCChatSalonTakeSeatTipsView.kHeight
        case .handsUpSuccess:
            innerView = TRTCChatSalonHandsUpTipsView()
            height = TRTCChatSalonHandsUpTipsView.kHeight
        }
        topTipsView.addSubview(innerView)
        innerView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        topTipsView.isHidden = false
        topTipsView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            self.hideTopTips()
        }
    }
    
    func hideTopTips() {
        guard !topTipsView.isHidden else {
            return
        }
        topTipsView.isHidden = true
        topTipsView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        for subview in topTipsView.subviews {
            subview.removeFromSuperview()
        }
        layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if requestTakeSeatListView.isHidden {
            super.touchesBegan(touches, with: event)
            return
        }
        guard let touch = touches.first else {
            return
        }
        let point = touch.location(in: self)
        if !requestTakeSeatListView.frame.contains(point) {
            viewModel.openRequestTakeSeatList(isOpen: false)
        }
    }
}

extension TRTCChatSalonRootView: TRTCChatSalonViewResponder {
    func showAlert(info: (title: String, message: String), sureAction: @escaping () -> Void, cancelAction: (() -> Void)?) {
        self.showAlert(info: info, actionTitle: (sure: .acceptTitle, cancel: .refuseTitle), sureAction: sureAction, cancelAction: cancelAction)
    }
    
    func refreshTakeSeatList() {
        requestTakeSeatListView.refreshList()
        updateHandUpListDot()
    }
    
    func showRequestTakeSeatTips(request: CSMemberRequestEntity?) {
        // 显示最新的上麦申请
        guard let requestMsg = request else {
            hideTopTips()
            return
        }
        showTopTips(type: .requestTakeSeat(requestMsg))
    }
    
    func showHandUpTips(isShow: Bool) {
        if isShow {
            showTopTips(type: .handsUpSuccess)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                guard let self = self else { return }
                self.viewModel.isHandUp = false
                self.hideTopTips()
            }
        } else {
            hideTopTips()
        }
    }
    
    func msgInput(show: Bool) {
    }
    
    func showAudioEffectView() {
    }
    
    func stopPlayBGM() {
    }
    
    func recoveryVoiceSetting() {
    }
    
    
    func audienceListRefresh() {
        seatCollection.reloadData()
    }
    
    func onSeatMute(isMute: Bool) {
        if isMute {
            makeToast(String.seatMute, duration: 0.3)
        } else {
            makeToast(String.seatUnmute, duration: 0.3)
            if viewModel.isSelfMute {
                return;
            }
        }
    }
    
    func showActionSheet(actionTitles: [String], actions: @escaping (Int) -> Void) {
        let actionSheet = UIAlertController.init(title: String.chooseTitle, message: "", preferredStyle: .actionSheet)
        actionTitles.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let action = UIAlertAction.init(title: title, style: UIAlertAction.Style.default) { (action) in
                actions(index)
                actionSheet.dismiss(animated: true, completion: nil)
            }
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction.init(title: String.cancelActionTitle, style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
        rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func showToast(message: String) {
        makeToast(message, duration: 1.0)
    }
    
    func popToPrevious() {
        rootViewController?.navigationController?.popViewController(animated: true)
    }
    
    func switchView(type: ChatSalonViewType) {
        switch type {
        case .audience:
            muteButton.isHidden = true
            handUpButton.isHidden = false
            leaveSeatButton.isHidden = true
            handUpListButton.isHidden = true
            handUpListDot.isHidden = true
            break
        case .anchor:
            muteButton.isHidden = false
            handUpButton.isHidden = true
            if viewModel.isOwner {
                leaveSeatButton.isHidden = true
                handUpListButton.isHidden = false
                updateHandUpListDot()
            } else {
                handUpListButton.isHidden = true
                handUpListDot.isHidden = true
                leaveSeatButton.isHidden = false
                // 这里需要在观众端上麦时，同步按钮状态
                muteButton.isSelected = false
                let _ = viewModel.muteAction(isMute: muteButton.isSelected, needShowToast: false) // 返回值为false说明无法调整麦克风权限
            }
            break
        }
    }
    
    func changeRoom(title: String) {
        rootViewController?.title = title
    }
    
    func refreshAnchorInfos() {
        seatCollection.reloadData()
    }
    
    func reuqestTakeSeatList(show: Bool) {
        if show {
            hideTopTips()
            requestTakeSeatListView.show()
        } else {
            requestTakeSeatListView.hide()
        }
    }
    
    func updateHandUpListDot() {
        if viewModel.requestTakeSeatMap.count == 0 {
            handUpListDot.isHidden = true
        } else {
            handUpListDot.isHidden = false
            handUpListDot.text = String(viewModel.requestTakeSeatMap.count)
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let anchorHeaderText = TRTCLocalize("Demo.TRTC.Salon.anchor")
    static let audienceHeaderText = TRTCLocalize("Demo.TRTC.Salon.audiences")
    static let leaveText = TRTCLocalize("Demo.TRTC.Salon.leavequietly")
    static let sureActionTitle = TRTCLocalize("Demo.TRTC.LiveRoom.confirm")
    static let cancelActionTitle = TRTCLocalize("Demo.TRTC.LiveRoom.cancel")
    static let acceptTitle = TRTCLocalize("Demo.TRTC.Salon.welcome")
    static let refuseTitle = TRTCLocalize("Demo.TRTC.Salon.dismiss")
    static let ownerExitMsg = TRTCLocalize("Demo.TRTC.Salon.wanttoendroom")
    static let seatMute = TRTCLocalize("Demo.TRTC.Salon.seatmuted")
    static let seatUnmute = TRTCLocalize("Demo.TRTC.Salon.seatunmuted")
    static let chooseTitle = TRTCLocalize("Demo.TRTC.Salon.pleaseselect")
    
    static let alertAudienceTitle = TRTCLocalize("Demo.TRTC.Salon.surewanttoleaveroom")
    static let alertAudienceConfirm = TRTCLocalize("Demo.TRTC.Salon.audienceconfirm")
    static let alertAudienceCancel = TRTCLocalize("Demo.TRTC.Salon.waitabit")
}

fileprivate extension UIColor {
    static let textColor = UIColor.black // 文本颜色
    static let buttonTintColor = UIColor.init(0x0062e3) // 按钮颜色
}

fileprivate extension UIImage {
    static let anchorHeaderIcon = UIImage.init(named: "chatsalon_anchor")
    static let audienceHeaderIcon = UIImage.init(named: "chatsalon_audience")
    static let micOff = UIImage.init(named: "chatsalon_mic_off")
    static let micOn = UIImage.init(named: "chatsalon_mic_on")
    static let leaveMic = UIImage.init(named: "chatsalon_leave_mic")
    static let handsup = UIImage.init(named: "chatsalon_handsup")
    static let handsupCancel = UIImage.init(named: "chatsalon_handsup_cancel")
    static let handsupList = UIImage.init(named: "chatsalon_handsup_list")
}
