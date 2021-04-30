//
//  TRTCCSAudienceListView.swift
//  TRTCChatSalonDemo
//
//  Created by abyyxwang on 2020/6/14.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCCSAudienceListView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCChatSalonViewModel
    
    init(frame: CGRect = .zero, viewModel: TRTCChatSalonViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.3
        return view
    }()
    
    let container: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    let titleContainer: UIView = {
        let view = UIView.init(frame: .zero)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = String.listTitle
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle(String.close, for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero)
        tableView.register(TRTCCSAudienceTableViewCell.self, forCellReuseIdentifier: "TRTCCSAudienceTableViewCell")
        tableView.backgroundColor = .clear
        tableView.rowHeight = 64
        tableView.separatorStyle = .none
        return tableView
    }()
    
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
        
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(bgView)
        addSubview(container)
        container.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(closeButton)
        container.addSubview(tableView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(418)
        }
        titleContainer.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
        tableView.snp.makeConstraints { (make) in
            make.bottom.right.left.equalToSuperview()
            make.top.equalTo(titleContainer.snp.bottom)
        }
    }

    func bindInteraction() {
        /// 此方法负责做viewModel和视图的绑定操作
        closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func show() {
        isHidden = false
    }
    
    @objc
    func hide() {
        isHidden = true
    }
    
    func refreshList() {
        tableView.reloadData()
    }
}

extension TRTCCSAudienceListView: UITableViewDelegate {
    
}

extension TRTCCSAudienceListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.requestTakeSeatMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCCSAudienceTableViewCell", for: indexPath)
        let index = viewModel.requestTakeSeatMap.index(viewModel.requestTakeSeatMap.startIndex, offsetBy: indexPath.row)
        if let audienceCell = cell as? TRTCCSAudienceTableViewCell {
            let (_, model) = viewModel.requestTakeSeatMap[index]
            audienceCell.setCell(model: model)
        }
        return cell
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let listTitle = TRTCLocalize("Demo.TRTC.Salon.raisedhands")
    static let close = TRTCLocalize("Demo.TRTC.Salon.close")
}



