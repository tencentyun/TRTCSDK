//
//  VideoSelectContactViewController+UI.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/8/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift

extension VideoSelectContactViewController {
    func setupUI() {
        
        title = "视频通话"
        
        let colors = [UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0,
                              blue: 75.0 / 255.0, alpha: 1).cgColor,
                      UIColor(red: 5.0 / 255.0, green: 12.0 / 255.0,
                              blue: 23.0 / 255.0, alpha: 1).cgColor]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap { $0 }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        ToastManager.shared.position = .bottom
        
        doneBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 24)
        let right = UIBarButtonItem(customView: doneBtn)
        
        navigationItem.rightBarButtonItem = right
        searchBar.backgroundImage = UIImage.init()
        searchBar.barTintColor = .searchBarBackColor
        searchBar.placeholder = "搜索手机号"
        view.addSubview(searchBar)
        
        var topPadding: CGFloat = 44
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        topPadding = max(26, topPadding)
        
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(topPadding + 60)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(35)
        }
        
        searchBar.backgroundColor = .searchBarBackColor
        searchBar.barTintColor = .clear
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.cornerRadius = 10.0
            textfield.layer.masksToBounds = true
            textfield.textColor = UIColor.white
            textfield.backgroundColor = .clear
            textfield.leftViewMode = .always
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image =  UIImage.init(named: "cm_search_white")
            }
        }
        
        self.view.addSubview(userPanel)
        userPanel.snp.remakeConstraints { (make) in
            make.leading.equalTo(view).offset(kUserPanelLeftSpacing)
            make.trailing.equalTo(view)
            make.top.equalTo(searchBar.snp.bottom).offset(6)
            make.height.equalTo(userPanelHeight)
        }
        
        self.view.addSubview(selectTable)
        selectTable.isHidden = true
        selectTable.snp.makeConstraints { (make) in
            make.top.equalTo(userPanel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.bottomMargin.equalTo(view)
        }
        
        self.view.addSubview(noSearchImage)
        noSearchImage.isUserInteractionEnabled = false
        noSearchImage.snp.makeConstraints { (make) in
            make.top.equalTo(view.bounds.size.height/3.0)
            make.leading.equalTo(view.bounds.size.width*154.0/375)
            make.trailing.equalTo(-view.bounds.size.width*154.0/375)
            make.height.equalTo(view.bounds.size.width*67.0/375)
        }
        
        self.view.addSubview(noMembersTip)
        noMembersTip.snp.makeConstraints { (make) in
            make.top.equalTo(noSearchImage.snp.bottom)
            make.width.equalTo(view.bounds.size.width)
            make.height.equalTo(60)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenNoMembersImg), name: NSNotification.Name("HiddenNoSearchVideoNotificationKey"), object: nil)
        
        getHistroy()
        selectTable.reloadData()
    }
    
    @objc func hiddenNoMembersImg() {
        noSearchImage.removeFromSuperview()
        noMembersTip.removeFromSuperview()
        selectTable.isHidden = false
    }
    
    /// 获取&更新历史列表
    func getHistroy() {
        var recent = recentContacts
        recent.reverse()
        historyList = recent
    }
    
    func showSelectVC() {
        self.selectedFinished = { [weak self] users in
            guard let self = self else {return}
            var list:[VideoCallUserModel] = []
            var userIds: [String] = []
            for UserModel in users {
                list.append(self.covertUser(user: UserModel))
                userIds.append(UserModel.userId)
            }
            self.showCallVC(invitedList: list)
            TRTCVideoCall.shared.invite(userIds: userIds, type: .video)
        }
    }
    
    /// show calling view
    /// - Parameters:
    ///   - invitedList: invitee userlist
    ///   - sponsor: passive call should not be nil,
    ///     otherwise sponsor call this mothed should ignore this parameter
    func showCallVC(invitedList: [VideoCallUserModel], sponsor: VideoCallUserModel? = nil) {
        callVC = VideoCallViewController(sponsor: sponsor)
        callVC?.dismissBlock = {[weak self] in
            guard let self = self else {return}
            self.callVC = nil
        }
        if let vc = callVC {
            vc.modalPresentationStyle = .fullScreen
            vc.resetWithUserList(users: invitedList, isInit: true)
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let navigationVC = topController as? UINavigationController {
                    if navigationVC.viewControllers.contains(self) {
                        present(vc, animated: false, completion: nil)
                    } else {
                        navigationVC.popToRootViewController(animated: false)
                        navigationVC.pushViewController(self, animated: false)
                        navigationVC.present(vc, animated: false, completion: nil)
                    }
                } else {
                    topController.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
}
