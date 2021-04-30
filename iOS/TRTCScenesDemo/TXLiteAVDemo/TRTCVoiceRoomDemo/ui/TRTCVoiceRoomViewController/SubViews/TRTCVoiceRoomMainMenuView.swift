//
//  TRTCVoiceRoomRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

public enum IconTupleType : Int {
    case message = 1
    case micoff
    case mute
    case more
    case bgmusic
}

class IconTuple: NSObject {
    let normal: UIImage
    let selected: UIImage
    let type: IconTupleType
    var isSelect = false
    init(normal: UIImage, selected: UIImage, type: IconTupleType) {
        self.normal = normal
        self.selected = selected
        self.type = type
        super.init()
    }
}

protocol TRTCVoiceRoomMainMenuDelegate: class {
    func menuView(menu: TRTCVoiceRoomMainMenuView, click item: IconTuple) -> Bool
}

class TRTCVoiceRoomMainMenuLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attrs = super.layoutAttributesForElements(in: rect)
        if let attrs = attrs {
            if attrs.count == 1 {
                var frame = attrs.first!.frame
                frame.origin.x = 0
                attrs.first!.frame = frame
            }
            else if attrs.count == 5 {
                minimumInteritemSpacing = (ScreenWidth - 5 * itemSize.width) / 6
                for (i, attr) in attrs.enumerated() {
                    var frame = attr.frame
                    frame.origin.x = minimumInteritemSpacing*CGFloat(i+1) + itemSize.width*CGFloat(i)
                    attr.frame = frame
                }
            }
            else {
                for (i, attr) in attrs.enumerated() {
                    if i == 0 {
                        var frame = attr.frame
                        frame.origin.x = 20
                        attr.frame = frame
                    }
                    else {
                        var frame = attr.frame
                        frame.origin.x = ScreenWidth-itemSize.width*CGFloat(attrs.count-i)-minimumInteritemSpacing*CGFloat(attrs.count-1-i)-20
                        attr.frame = frame
                    }
                }
            }
        }
        return attrs
    }
}

class TRTCVoiceRoomMainMenuView: UIView {
    private var isViewReady: Bool = false
    private let icons: [IconTuple]
    var dataSource: [IconTuple] = []
    weak var delegate: TRTCVoiceRoomMainMenuDelegate?
    /// 初始化方法
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - icons: 视图菜单icons（最多5个，最少1个）
    init(frame: CGRect = .zero, icons: [IconTuple] ) {
        icons.forEach { (tuple) in
            if tuple.type == .mute {
                tuple.isSelect = true
            }
        }
        self.icons = icons
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    lazy var menuStack: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = TRTCVoiceRoomMainMenuLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - 视图的生命周期
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
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(menuStack)
        menuStack.addSubview(collectionView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        menuStack.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
            make.centerY.equalToSuperview()
        }
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TRTCVoiceRoomMainMenuViewCell.self, forCellWithReuseIdentifier: "TRTCVoiceRoomMainMenuViewCell")
    }
    
    public func anchorType() {
        dataSource.removeAll()
        icons.forEach { (tuple) in
            tuple.isSelect = true
            dataSource.append(tuple)
        }
        collectionView.reloadData()
    }
    
    public func ownerType() {
        dataSource.removeAll()
        icons.forEach { (tuple) in
            if tuple.type != .micoff {
                tuple.isSelect = true
                dataSource.append(tuple)
            }
        }
        collectionView.reloadData()
    }
    
    public func audienceType() {
        dataSource.removeAll()
        icons.forEach { (tuple) in
            if tuple.type == .message || tuple.type == .more {
                tuple.isSelect = true
                dataSource.append(tuple)
            }
        }
        collectionView.reloadData()
    }
    
    public func changeMixStatus(isMute: Bool) {
        collectionView.reloadData()
    }
}
extension TRTCVoiceRoomMainMenuView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCVoiceRoomMainMenuViewCell", for: indexPath)
        if let scell = cell as? TRTCVoiceRoomMainMenuViewCell {
            scell.model = dataSource[indexPath.item]
        }
        return cell
    }
}
extension TRTCVoiceRoomMainMenuView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.item]
        if let delegate = delegate, delegate.menuView(menu: self, click: model) {
            model.isSelect = !model.isSelect
            let cell = collectionView.cellForItem(at: indexPath)
            if let scell = cell as? TRTCVoiceRoomMainMenuViewCell {
                scell.select = model.isSelect
            }
        }
    }
}

class TRTCVoiceRoomMainMenuViewCell: UICollectionViewCell {
    var model: IconTuple? {
        didSet {
            guard let model = model else {
                return
            }
            select = model.isSelect
        }
    }
    
    var select: Bool = false {
        didSet {
            guard let model = model else {
                return
            }
            headImageView.image = select ? model.selected : model.normal
        }
    }
    
    lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    
    var isViewReady = false
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
        contentView.addSubview(headImageView)
    }

    func activateConstraints() {
        headImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension UIButton {
    private struct AssociaKey{
        static var tupleTypeKey: String = "tupleTypeKey"
    }
    var tupleType : IconTupleType {
        set {
            objc_setAssociatedObject(self, &AssociaKey.tupleTypeKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociaKey.tupleTypeKey) else {
                return .message
            }
            return IconTupleType(rawValue: value as! Int) ?? IconTupleType.message
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}



