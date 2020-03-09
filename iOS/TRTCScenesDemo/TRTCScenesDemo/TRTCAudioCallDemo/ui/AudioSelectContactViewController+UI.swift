//
//  AudioSelectContactViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/8/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

extension AudioSelectContactViewController {
    func setupUI() {
        ToastManager.shared.position = .center
        title = "发起呼叫"
        view.backgroundColor = .appBackGround
        let back = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(cancel))
        back.tintColor = .white
        navigationItem.leftBarButtonItem = back
        
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
        let right = UIBarButtonItem(customView: doneBtn)
        
        navigationItem.rightBarButtonItem = right
        searchBar.placeholder = "输入手机号搜索已注册用户"
        view.addSubview(searchBar)
        
        var topPadding: CGFloat = 44
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        topPadding = max(26, topPadding)
        
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(topPadding + (navigationController?.navigationBar.bounds.height ?? 44))
            make.leading.trailing.equalTo(view)
            make.height.equalTo(28)
        }
        
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.white
            textfield.backgroundColor = .black
        }
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = .lightGray
            }
        }
        
        userPanel.snp.remakeConstraints { (make) in
            make.leading.equalTo(view).offset(kUserPanelLeftSpacing)
            make.trailing.equalTo(view)
            make.top.equalTo(searchBar.snp.bottom).offset(6)
            make.height.equalTo(userPanelHeight)
        }
        
        selectTable.snp.makeConstraints { (make) in
            make.top.equalTo(userPanel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.bottomMargin.equalTo(view)
        }
        
        getHistroy()
        selectTable.reloadData()
    }
    
    /// 取消
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 获取&更新历史列表
    func getHistroy() {
        var recent = recentContacts
        recent.reverse()
        historyList = recent
    }
}
