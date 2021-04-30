//
//  TRTCVoiceRoomAlertContentView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

// MARK: - Base View
class TRTCVoiceRoomAlertContentView: UIView {
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    let viewModel: TRTCVoiceRoomViewModel
    
    public var willDismiss: (()->())?
    public var didDismiss: (()->())?
    
    public init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    public func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    func bindInteraction() {
        
    }
}

// MARK: - More View
class TRTCVoiceRoomMoreAlert: TRTCVoiceRoomAlertContentView {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 76)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    override init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        super.init(viewModel: viewModel)
        titleLabel.text = .toolText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(collectionView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
            make.height.equalTo(76)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TRTCVoiceRoomMoreAlertCell.self, forCellWithReuseIdentifier: "TRTCVoiceRoomMoreAlertCell")
    }
}
extension TRTCVoiceRoomMoreAlert : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            if let cell = cell as? TRTCVoiceRoomMoreAlertCell {
                viewModel.voiceEarMonitor = !viewModel.voiceEarMonitor
                cell.enable = viewModel.voiceEarMonitor
            }
        }
    }
}
extension TRTCVoiceRoomMoreAlert : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCVoiceRoomMoreAlertCell", for: indexPath)
        if let cell = cell as? TRTCVoiceRoomMoreAlertCell {
            cell.model = (UIImage(named: "eraback_off"), UIImage(named: "eraback_on"))
            cell.titleLabel.text = .earMonitorText
            cell.enable = viewModel.voiceEarMonitor
        }
        return cell
    }
}
class TRTCVoiceRoomMoreAlertCell: UICollectionViewCell {
    
    public var model : (normal : UIImage?, selected : UIImage?)?
    
    public var enable: Bool = false {
        willSet {
            if newValue {
                imageView.image = model?.selected
            }
            else {
                imageView.image = model?.normal
            }
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    private func constructViewHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    private func activateConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp_bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - BGM View
class TRTCVoiceRoomBgmAlert: TRTCVoiceRoomAlertContentView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(.backText, for: .normal)
        return btn
    }()
    
    var dataSource : [TRTCMusicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let effectViewModel : TRTCVoiceRoomSoundEffectViewModel
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel, effectViewModel: TRTCVoiceRoomSoundEffectViewModel) {
        self.effectViewModel = effectViewModel
        super.init(viewModel: viewModel)
        titleLabel.text = .bgmText
        dataSource = effectViewModel.bgmDataSource
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(backBtn)
        contentView.addSubview(tableView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52*3)
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
        backBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func backBtnClick() {
        dismiss()
    }
}
extension TRTCVoiceRoomBgmAlert : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        let model = dataSource[indexPath.row]
        cell.textLabel?.text = model.musicName
        cell.textLabel?.textColor = .black
        return cell
    }
}
extension TRTCVoiceRoomBgmAlert : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        if let action = model.action {
            action(true, model)
        }
        dismiss()
    }
}

// MARK: - Audience View
class TRTCVoiceRoomAudienceAlert: TRTCVoiceRoomAlertContentView {
    
    public var unlockBtnDidClick : ((_ selected: Bool)->())?
    
    lazy var unlockBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "lock"), for: .normal)
        btn.setImage(UIImage(named: "unlock"), for: .selected)
        btn.setTitle(.lockText, for: .normal)
        btn.setTitle(.unlockText, for: .selected)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        btn.backgroundColor = UIColor(hex: "F4F5F9")
        btn.setTitleColor(UIColor(hex: "333333"), for: .normal)
        btn.setTitleColor(UIColor(hex: "333333"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        return btn
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        unlockBtn.layer.cornerRadius = unlockBtn.frame.height*0.5
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(unlockBtn)
        contentView.addSubview(tableView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        unlockBtn.sizeToFit()
        let width = unlockBtn.frame.width
        unlockBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(38)
            make.width.equalTo(width + 28)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(280)
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TRTCVoiceRoomAudienceCell.self, forCellReuseIdentifier: "TRTCVoiceRoomAudienceCell")
        unlockBtn.addTarget(self, action: #selector(unlockBtnClick), for: .touchUpInside)
        unlockBtn.isSelected = seatModel.isClosed
    }
    
    
    public let seatModel : SeatInfoModel
    private let audienceList : [AudienceInfoModel]
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel, seatModel: SeatInfoModel, audienceList: [AudienceInfoModel]) {
        self.seatModel = seatModel
        self.audienceList = audienceList
        super.init(viewModel: viewModel)
        titleLabel.text = .audienceText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func unlockBtnClick() {
        unlockBtn.isSelected = !unlockBtn.isSelected
        unlockBtn.sizeToFit()
        let width = unlockBtn.frame.width
        unlockBtn.snp.updateConstraints { (make) in
            make.width.equalTo(width+28)
        }
        unlockBtn.superview?.layoutIfNeeded()
        viewModel.clickSeatLock(isLock: unlockBtn.isSelected, model: seatModel)
        dismiss()
    }
}
class TRTCVoiceRoomAudienceCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var model : AudienceInfoModel? {
        didSet {
            guard let model = model  else {
                return
            }
            headImageView.sd_setImage(with: URL(string: model.userInfo.userAvatar), placeholderImage: nil, options: .continueInBackground, completed: nil)
            titleLabel.text = model.userInfo.userName
            switch model.type {
            case AudienceInfoModel.TYPE_IDEL:
                agreeBtn.isHidden = false
                agreeBtn.isSelected = false
            case AudienceInfoModel.TYPE_WAIT_AGREE:
                agreeBtn.isHidden = false
                agreeBtn.isSelected = true
            case AudienceInfoModel.TYPE_IN_SEAT:
                agreeBtn.isHidden = true
            default:
                agreeBtn.isHidden = true
            }
        }
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(headImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(agreeBtn)
    }
    
    private func activateConstraints() {
        headImageView.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(headImageView.snp_height)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(headImageView.snp_trailing).offset(20)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(agreeBtn.snp_leading).offset(-20)
        }
        agreeBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(38)
            make.centerY.equalToSuperview()
            make.width.equalTo(76)
        }
    }
    
    private func bindInteraction() {
        agreeBtn.addTarget(self, action: #selector(agreeBtnClick(sender:)), for: .touchUpInside)
    }
    weak var alertView : TRTCVoiceRoomAudienceAlert?
    @objc func agreeBtnClick(sender: UIButton) {
        model?.action(sender.isSelected ? 1 : 0)
        sender.isSelected = !sender.isSelected
        alertView?.dismiss()
    }
    
    lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.clipsToBounds = true
        imageV.layer.cornerRadius = 8
        return imageV
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(hex: "666666")
        return label
    }()
    
    lazy var agreeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(hex: "29CC85")
        btn.layer.cornerRadius = 38*0.5
        btn.setTitle(.inviteText, for: .normal)
        btn.setTitle(.agreeText, for: .selected)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        return btn
    }()
}
extension TRTCVoiceRoomAudienceAlert : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return audienceList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCVoiceRoomAudienceCell", for: indexPath)
        let model = audienceList[indexPath.section]
        if let cell = cell as? TRTCVoiceRoomAudienceCell {
            cell.model = model
            cell.alertView = self
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}
extension TRTCVoiceRoomAudienceAlert : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let audienceText = TRTCLocalize("Demo.TRTC.VoiceRoom.audience")
    static let unlockText = TRTCLocalize("Demo.TRTC.VoiceRoom.unlock")
    static let lockText = TRTCLocalize("Demo.TRTC.VoiceRoom.lock")
    static let agreeText = TRTCLocalize("Demo.TRTC.VoiceRoom.agree")
    static let inviteText = TRTCLocalize("Demo.TRTC.VoiceRoom.invite")
    static let earMonitorText = TRTCLocalize("Demo.TRTC.VoiceRoom.earmonitor")
    static let toolText = TRTCLocalize("Demo.TRTC.VoiceRoom.tools")
    static let backText = TRTCLocalize("Demo.TRTC.VoiceRoom.back")
    static let bgmText = TRTCLocalize("ASKit.MainMenu.BGM")
}
