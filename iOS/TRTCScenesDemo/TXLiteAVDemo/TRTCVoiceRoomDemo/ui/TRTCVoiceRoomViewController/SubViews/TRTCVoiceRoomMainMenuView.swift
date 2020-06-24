//
//  TRTCVoiceRoomRootView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//Copyright © 2020 tencent. All rights reserved.
//
import UIKit

public typealias IconTuple = (normal: UIImage, selected: UIImage)

protocol TRTCVoiceRoomMainMenuDelegate: class {
    func menuView(menu: TRTCVoiceRoomMainMenuView, click item: UIButton, index: Int)
}

class TRTCVoiceRoomMainMenuView: UIView {
    private var isViewReady: Bool = false
    private let icons: [IconTuple]
    private var buttons: [UIButton] = []
    weak var delegate: TRTCVoiceRoomMainMenuDelegate?
    /// 初始化方法
    /// - Parameters:
    ///   - frame: 视图frame
    ///   - icons: 视图菜单icons（最多5个，最少1个）
    init(frame: CGRect = .zero, icons: [IconTuple] ) {
        self.icons = icons
        super.init(frame: frame)
        buttons = createButtons(icons: icons)
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    lazy var menuStack: UIStackView = {
        let stack = UIStackView.init(frame: .zero)
        stack.axis = .horizontal // 布局方向
        stack.distribution = .equalSpacing // 主方向上的排布方式
        stack.alignment = .center // 子方向的对齐方式
        if self.icons.count > 1 {
            let totalWidth = UIScreen.main.bounds.width - 44.0 - 30.0 * CGFloat(self.icons.count)
            let spaceNumber = CGFloat(self.icons.count - 1)
            stack.spacing = totalWidth / spaceNumber
        }
        return stack
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
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(menuStack)
        buttons.forEach { (button) in
            menuStack.addArrangedSubview(button)
        }
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        menuStack.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        buttons.forEach { (button) in
            button.snp.makeConstraints { (make) in
                make.height.width.equalTo(30)
            }
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
        buttons.enumerated().forEach { (element) in
            let index = element.offset
            let button = element.element
            button.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
            button.tag = 100 + index
        }
    }
    
    @objc
    func selectAction(_ sender: UIButton) {
        self.delegate?.menuView(menu: self, click: sender, index: sender.tag - 100)
    }
    
    public func anchorType() {
        let disableIndex = Set<Int>.init([1, 3])
        buttons.enumerated().forEach { (item) in
            let offset = item.offset
            let button = item.element
            if disableIndex.contains(offset) {
                button.isSelected = true;
            }
        }
    }
    
    public func audienceType() {
        let disableIndex = Set<Int>.init([1, 3])
        buttons.enumerated().forEach { (item) in
            let offset = item.offset
            let button = item.element
            if disableIndex.contains(offset) {
                button.isSelected = false;
            }
        }
    }
    
    public func changeMixStatus(isMute: Bool) {
        if buttons.count > 2 {
            buttons[1].isSelected = !isMute
        }
    }
}

extension TRTCVoiceRoomMainMenuView {
    private func createButtons(icons: [IconTuple]) -> [UIButton] {
        return icons.map { (infoTuple) -> UIButton in
            let button = UIButton.init(type: .custom)
            button.setImage(infoTuple.normal, for: .normal)
            button.setImage(infoTuple.selected, for: .selected)
            button.isSelected = true
            return button
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}



