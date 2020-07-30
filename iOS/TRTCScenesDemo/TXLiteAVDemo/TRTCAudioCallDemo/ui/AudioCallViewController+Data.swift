//
//  AudioCallViewController+Data.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/14/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

extension AudioCallViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [AudioCallUserModel], isInit: Bool = false) {
        resetUserList()
        if isInit && curSponsor != nil {
            inviteeList.append(contentsOf: users)
        } else {
            userList.append(contentsOf: users)
        }
        
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            userList = [sponsor]
        } else {
            var curUser = AudioCallUserModel()
            if let name = ProfileManager.shared.curUserModel?.name,
                let avatar = ProfileManager.shared.curUserModel?.avatar,
                let userId = ProfileManager.shared.curUserModel?.userId {
                curUser.name = name
                curUser.avatarUrl = avatar
                curUser.userId = userId
                curUser.isEnter = true
            }
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCallUserCell", for: indexPath) as! AudioCallUserCell
        if (indexPath.row < userList.count) {
            let user = userList[indexPath.row]
            cell.UserModel = user
        } else {
            cell.UserModel = AudioCallUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        if (collectionCount <= 4) {
            let border = collectWidth / 2;
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                return CGSize(width:  collectWidth, height: border)
            } else {
                return CGSize(width: border, height: border)
            }
        } else {
            let border = collectWidth / 3;
            return CGSize(width: border, height: border)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func enterUser(user: AudioCallUserModel) {
        curState = .calling
        updateUser(user: user, animate: true)
    }
    
    func leaveUser(user: AudioCallUserModel) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
        }
        reloadData(animate: true)
    }
    
    func updateUser(user: AudioCallUserModel, animate: Bool = false) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
            userList.insert(user, at: index)
        } else {
            userList.append(user)
        }
        reloadData(animate: animate)
    }
    
    func reloadData(animate: Bool = false) {
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        if animate {
            userCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(self.view)
                    make.bottom.equalTo(self.view).offset(-132)
                    make.top.equalTo(self.collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                self.userCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation {
                userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(view)
                    make.bottom.equalTo(view).offset(-132)
                    make.top.equalTo(collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                userCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
}
