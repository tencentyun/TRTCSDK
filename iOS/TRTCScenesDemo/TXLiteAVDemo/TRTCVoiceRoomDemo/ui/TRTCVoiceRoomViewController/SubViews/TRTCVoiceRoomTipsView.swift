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
//        tipsTableView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tipsTableView.scrollToRow(at: IndexPath.init(row: self.viewModel.msgEntityList.count - 1, section: 0),
                                           at: .bottom,
                                           animated: true)
        }
    }
}

extension TRTCVoiceRoomTipsView: UITableViewDelegate {
    
}

extension TRTCVoiceRoomTipsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.msgEntityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCVoiceRoomTipsTableCell", for: indexPath)
        if let tipsCell = cell as? TRTCVoiceRoomTipsTableCell {
            let model = viewModel.msgEntityList[indexPath.row]
            if model.type == MsgEntity.TYPE_NORMAL {
                var textInfo = "\(model.content)"
                if model.userName.count > 0 {
                    textInfo = "\(model.userName):\(model.content)"
                }
                tipsCell.setCell(info: textInfo, action: nil)
            } else if model.type == MsgEntity.TYPE_AGREED {
                tipsCell.setCell(info: "\(model.userName)\(model.content)", action: nil)
            } else {
                tipsCell.setCell(info: "\(model.userName)\(model.content)") { [weak self] in
                    guard let `self` = self else { return }
                    self.viewModel.acceptTakeSeat(identifier: model.userId)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tipsCell = cell as? TRTCVoiceRoomTipsTableCell {
            tipsCell.updateCell()
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
}



