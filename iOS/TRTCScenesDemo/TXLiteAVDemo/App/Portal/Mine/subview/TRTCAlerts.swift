//
//  TRTCAlerts.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class TRTCAvatarListAlertView: TRTCAlertContentView {
    
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(.confirmText, for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        btn.isEnabled = false
        return btn
    }()
    
    lazy var collectionView: UICollectionView = {
        let itemWH = (ScreenWidth - 20 * 5) / 4
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect = .zero, viewModel: TRTCAlertViewModel) {
        super.init(frame: frame, viewModel: viewModel)
        titleLabel.font = UIFont(name: "PingFangSC-Medium", size: 20)
        titleLabel.text = .setAvatarText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(collectionView)
        contentView.addSubview(confirmBtn)
    }
    override func activateConstraints() {
        super.activateConstraints()
        collectionView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp_bottom)
            make.height.equalTo(convertPixel(h: 440))
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
    }
    override func bindInteraction() {
        super.bindInteraction()
        
        confirmBtn.addTarget(self, action: #selector(confirmBtnClick), for: .touchUpInside)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TRTCAvatarListCell.self, forCellWithReuseIdentifier: "TRTCAvatarListCell")
    }
    
    public var didClickConfirmBtn: (()->())?
    
    @objc func confirmBtnClick() {
        guard let model = viewModel.currentSelectAvatarModel else {
            return
        }
        viewModel.setUserAvatar(model.url)
        if let action = didClickConfirmBtn {
            action()
        }
        dismiss()
    }
    
    override func dismiss() {
        super.dismiss()
        viewModel.currentSelectAvatarModel = nil
    }
}
extension TRTCAvatarListAlertView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.avatarListDataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCAvatarListCell", for: indexPath)
        if let scell = cell as? TRTCAvatarListCell {
            let model = viewModel.avatarListDataSource[indexPath.item]
            scell.model = model
        }
        return cell
    }
}
extension TRTCAvatarListAlertView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.currentSelectAvatarModel = viewModel.avatarListDataSource[indexPath.item]
        confirmBtn.isEnabled = true
    }
}

class TRTCAvatarListCell: UICollectionViewCell {
    
    var model: AvatarModel? {
        didSet {
            guard let model = model else {
                return
            }
            headImageView.sd_setImage(with: URL(string: model.url), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectView.isHidden = !isSelected
        }
    }
    
    lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        return imageV
    }()
    
    lazy var selectView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        headImageView.layer.cornerRadius = frame.height * 0.5
        selectView.layer.cornerRadius = selectView.frame.height * 0.5
        selectView.layer.borderWidth = 3
        selectView.layer.borderColor = UIColor(hex: "006EFF")?.cgColor
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
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(headImageView)
        headImageView.addSubview(selectView)
    }
    
    func activateConstraints() {
        headImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        selectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

class TRTCAlertContentView: UIView {
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
    
    public var willDismiss: (()->())?
    public var didDismiss: (()->())?
    
    let viewModel: TRTCAlertViewModel
    
    public init(frame: CGRect = .zero, viewModel: TRTCAlertViewModel) {
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
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
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

/// MARK: - internationalization string
fileprivate extension String {
    static let confirmText = TRTCLocalize("Demo.TRTC.Login.done")
    static let setAvatarText = TRTCLocalize("Demo.TRTC.Login.setavatar")
}
