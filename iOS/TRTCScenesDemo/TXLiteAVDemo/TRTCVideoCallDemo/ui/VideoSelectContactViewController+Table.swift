//
//  VideoSelectContactViewController+Table.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/15/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

class VideoSelectUserTableViewCell: UITableViewCell {
    
    lazy var selectedMark: UIImageView = {
        let img = UIImageView()
        addSubview(img)
        return img
    }()
    
    lazy var userImg: UIImageView = {
       let img = UIImageView()
        addSubview(img)
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .appBackGround
        addSubview(label)
        return label
    }()
    
    func config(model: UserModel, selected: Bool = false) {
        backgroundColor = .appBackGround
        selectedMark.snp.remakeConstraints { (make) in
            make.leading.equalTo(12)
            make.centerY.equalTo(self)
            make.width.height.equalTo(12)
        }
        userImg.snp.remakeConstraints { (make) in
            make.leading.equalTo(selectedMark.snp.trailing).offset(12)
            make.width.height.equalTo(32)
            make.centerY.equalTo(self)
        }
        nameLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(userImg.snp.trailing).offset(12)
            make.trailing.top.bottom.equalTo(self)
        }
        userImg.sd_setImage(with: URL(string: model.avatar), completed: nil)
        selectedMark.image = UIImage(named: selected ? "ic_selected" : "ic_unselect")
        nameLabel.text = model.name
    }
}

extension VideoSelectContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResult {
            return 1
        }
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSelectUserTableViewCell") as! VideoSelectUserTableViewCell
        cell.selectionStyle = .none
        if shouldShowSearchResult {
            if let user = searchResult {
                let isSelected = isUserSelected(user: user)
                cell.config(model:user, selected: isSelected )
            } else {
                cell.config(model: UserModel(userID: ""))
            }
        } else {
            if (indexPath.row < historyList.count) {
                let user = historyList[indexPath.row]
                let isSelected = isUserSelected(user: user)
                cell.config(model: user, selected: isSelected)
            } else {
                cell.config(model: UserModel(userID: ""))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .appBackGround
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if shouldShowSearchResult {
            return "搜索结果"
        }
        return "最近搜索"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var isSelected = false
        var userSelected = UserModel.init(userID: "")
        if shouldShowSearchResult {
            if let user = searchResult {
                isSelected = isUserSelected(user: user)
                userSelected = user.copy()
            }
        } else {
            if (indexPath.row < historyList.count) {
                let user = historyList[indexPath.row]
                isSelected = isUserSelected(user: user)
                userSelected = user.copy()
            }
        }
        
        if userSelected.userId.count == 0 {
            return
        }
        
        if isSelected {
            selectedUsers = selectedUsers.filter {
                $0.userId != userSelected.userId
            }
        } else {
            if userSelected.userId == AppUtils.shared.curUserId {
                view.makeToast("不能邀请自己")
                return
            }
            selectedUsers.append(userSelected)
            saveRecentContacts(users: [userSelected])
        }
    }
    
    //MARK: - internal func
    
    func isUserSelected(user: UserModel)->Bool {
        var isSelected = false
        for selectUser in selectedUsers {
            if selectUser.userId == user.userId && selectUser.userId != AppUtils.shared.curUserId{
                isSelected = true
                break
            }
        }
        return isSelected
    }
}
