//
//  TRTCVoiceRoomTopView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/23.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class TRTCVoiceRoomImageOnlyCell: UICollectionViewCell {
    
    public let headImageView : UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        return imageV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        contentView.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        headImageView.layer.cornerRadius = headImageView.frame.height*0.5
    }
}

class TRTCVoiceRoomTopView: UIView {
    
    public let viewModel: TRTCVoiceRoomViewModel
    
    public var memberAudienceDataSource : [AudienceInfoModel] = []
    public func reloadAudienceList() {
        memberAudienceDataSource = viewModel.getRealMemberAudienceList()
        audienceListCollectionView.reloadData()
    }
    public func reloadRoomAvatar() {
        roomImageView.sd_setImage(with: URL(string: viewModel.masterAnchor?.seatUser?.userAvatar ?? ""), placeholderImage: nil, options: .lowPriority) { (image, error, cacheType, url) in
            
        }
    }
    public func reloadRoomInfo(_ info: VoiceRoomInfo) {
        roomTitleLabel.text = info.roomName
        roomDescLabel.text = LocalizeReplaceXX(.roomIdDescText, String(info.roomID))
        setNeedsDisplay()
    }
    
    private let roomContainerView : UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
private let roomBgView : UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.alpha = 0.2
        return view
    }()
public let roomImageView : UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.clipsToBounds = true
        return imageV
    }()
private let roomTitleLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.text = .roomTitleText
        label.font = UIFont(name: "PingFangSC-Medium", size: 14)
        label.textColor = .white
        return label
    }()
private let roomDescLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 12)
        label.textColor = .white
        return label
    }()
    private let shareBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "share"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.isHidden = true
        return btn
    }()
    private let closeBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "exit"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
    private let audienceListCollectionView : UICollectionView = {
        let layout = TRTCVoiceRoomAudienceListLayout()
        layout.itemSize = CGSize(width: 24, height: 24)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    private let nextBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "room_scrollright"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    deinit {
        TRTCLog.out("top view deinit")
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roomContainerView.layer.cornerRadius = roomContainerView.frame.height*0.5
        roomImageView.layer.cornerRadius = roomImageView.frame.height * 0.5
    }
    
    private func constructViewHierarchy() {
        addSubview(roomContainerView)
        roomContainerView.addSubview(roomBgView)
        roomContainerView.addSubview(roomImageView)
        roomContainerView.addSubview(roomTitleLabel)
        roomContainerView.addSubview(roomDescLabel)
        
        addSubview(shareBtn)
        addSubview(closeBtn)
        addSubview(audienceListCollectionView)
        addSubview(nextBtn)
    }
    
    private func activateConstraints() {
        activateConstraintsRoomView() // 顶部房间信息区域
        closeBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(roomContainerView)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        shareBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(closeBtn.snp_leading).offset(-10)
            make.centerY.equalTo(closeBtn)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        audienceListCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(closeBtn.snp_bottom).offset(convertPixel(h: 16))
            make.trailing.equalToSuperview().offset(-52)
            make.height.equalTo(24)
            make.width.equalTo(24*2+8)
            make.bottom.equalToSuperview()
        }
        nextBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.centerY.equalTo(audienceListCollectionView)
        }
    }
    
    private func activateConstraintsRoomView() {
        roomContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kDeviceSafeTopHeight+6)
            make.leading.equalToSuperview().offset(20)
        }
        roomBgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roomImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.centerY.equalToSuperview()
        }
        roomTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(roomImageView.snp_trailing).offset(8)
            make.top.equalToSuperview().offset(9)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
        roomDescLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(roomTitleLabel)
            make.top.equalTo(roomTitleLabel.snp_bottom).offset(2)
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    private func bindInteraction() {
        audienceListCollectionView.dataSource = self
        audienceListCollectionView.delegate = self
        audienceListCollectionView.register(TRTCVoiceRoomImageOnlyCell.self, forCellWithReuseIdentifier: "audienceListCell")
        memberAudienceDataSource = viewModel.getRealMemberAudienceList()
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        shareBtn.addTarget(self, action: #selector(shareBtnClick), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextBtnClick), for: .touchUpInside)
    }
    
    @objc func closeBtnClick() {
        if viewModel.roomType == VoiceRoomViewType.anchor {
            viewModel.viewResponder?.showAlert(info: (String.exitText, String.sureToExitText), sureAction: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.exitRoom() // 主播销毁房间
            }, cancelAction: {
                
            })
        } else {
            viewModel.exitRoom()
        }
    }
    
    private var audienceIndex: Int = 0
    @objc func nextBtnClick() {
        audienceIndex += 1
        if audienceIndex >= memberAudienceDataSource.count {
            audienceIndex = 0
        }
        audienceListCollectionView.scrollToItem(at: IndexPath(item: audienceIndex, section: 0), at: .left, animated: true)
    }
    @objc func shareBtnClick() {
        
    }
}

class TRTCVoiceRoomAudienceListLayout : UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attrs = super.layoutAttributesForElements(in: rect)
        if attrs?.count == 1 {
            if var frame = attrs?.first!.frame {
                frame.origin.x = self.itemSize.width + self.minimumInteritemSpacing
                attrs?.first!.frame = frame
            }
        }
        return attrs
    }
}

extension TRTCVoiceRoomTopView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memberAudienceDataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "audienceListCell", for: indexPath) as! TRTCVoiceRoomImageOnlyCell
        let info = memberAudienceDataSource[indexPath.item]
        cell.headImageView.sd_setImage(with: URL(string: info.userInfo.userAvatar), placeholderImage: nil, options: .lowPriority) { (image, error, cacheType, url) in
            
        }
        return cell
    }
}

extension TRTCVoiceRoomTopView : UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let x = scrollView.contentOffset.x
            let page = roundf(Float(x / (24+8)))
            audienceIndex = Int(page)
            audienceListCollectionView.scrollToItem(at: IndexPath(item: audienceIndex, section: 0), at: .left, animated: true)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = roundf(Float(x / (24+8)))
        audienceIndex = Int(page)
        audienceListCollectionView.scrollToItem(at: IndexPath(item: audienceIndex, section: 0), at: .left, animated: true)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let roomTitleText = TRTCLocalize("Demo.TRTC.VoiceRoom.roomname")
    static let roomIdDescText = TRTCLocalize("Demo.TRTC.VoiceRoom.roomidxx")
    static let welcomeText = TRTCLocalize("Demo.TRTC.VoiceRoom.xxenterroom")
    static let exitText = TRTCLocalize("Demo.TRTC.VoiceRoom.exit")
    static let sureToExitText = TRTCLocalize("Demo.TRTC.VoiceRoom.isvoicingandsuretoexit")
}
