//
//  TRTCVoiceRoomTipsView.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/8.
//  Copyright © 2020 tencent. All rights reserved.
//

import UIKit

class TRTCVoiceRoomTipsView: UIView {
    private var isViewReady: Bool = false
    let viewModel: TRTCVoiceRoomViewModel
    
    init(frame: CGRect = .zero, viewModel: TRTCVoiceRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    let tipsTableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.register(TRTCVoiceRoomTipsTableCell.self, forCellReuseIdentifier: "TRTCVoiceRoomTipsTableCell")
        tableView.register(TRTCVoiceRoomTipsWelcomCell.self, forCellReuseIdentifier: "TRTCVoiceRoomTipsWelcomCell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    // MARK: - 视图生命周期函数
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
        addSubview(tipsTableView)
    }

    func activateConstraints() {
        /// 此方法内只给子视图做布局,使用:AutoLayout布局
        tipsTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
    }

    func bindInteraction() {
        tipsTableView.delegate = self
        tipsTableView.dataSource = self
    }
    
    func refreshList() {
        tipsTableView.reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tipsTableView.scrollToRow(at: IndexPath.init(row: self.viewModel.msgEntityList.count, section: 0),
                                           at: .bottom,
                                           animated: true)
        }
    }
}

extension TRTCVoiceRoomTipsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let url = URL(string: TRTCVoiceRoomTipsWelcomCell.urlText), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}

extension TRTCVoiceRoomTipsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.msgEntityList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCVoiceRoomTipsWelcomCell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCVoiceRoomTipsTableCell", for: indexPath)
        if let tipsCell = cell as? TRTCVoiceRoomTipsTableCell {
            let model = viewModel.msgEntityList[indexPath.row-1]
            tipsCell.setCell(model: model, action: { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.acceptTakeSeat(identifier: model.userId)
            }, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row != 0, let tipsCell = cell as? TRTCVoiceRoomTipsTableCell else {
            return
        }
        tipsCell.updateCell()
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}



