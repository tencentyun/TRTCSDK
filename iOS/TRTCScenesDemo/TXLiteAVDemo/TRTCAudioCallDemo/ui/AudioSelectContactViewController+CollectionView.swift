//
//  AudioSelectContactViewController+CollectionView.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/15/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

class AudioSelectUserCollectionViewCell: UICollectionViewCell {
    lazy var userImg: UIImageView = {
       let img = UIImageView()
        addSubview(img)
        return img
    }()
    
    func config(model: UserModel) {
        userImg.snp.remakeConstraints { (make) in
            make.edges.equalTo(self)
        }
        userImg.sd_setImage(with: URL(string: model.avatar), completed: nil)
    }
}

extension AudioSelectContactViewController: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var userPanelColumnCount: Int {
        get {
            let userCount = selectedUsers.count
            if userCount == 0 {
                return 0
            }
            let totalWidth = view.frame.size.width - kUserPanelLeftSpacing
            let columnCount = Int(totalWidth / (kUserBorder + kUserSpacing))
            return columnCount
        }
    }
    
    var realSpacing: CGFloat {
        get {
            let totalWidth = view.frame.size.width - kUserPanelLeftSpacing
            if userPanelColumnCount == 0 || userPanelColumnCount == 1 {
                return 0
            }
            return (totalWidth - CGFloat(userPanelColumnCount) * kUserBorder) / (CGFloat(userPanelColumnCount) - 1)
        }
    }
    
    var userPanelRowCount: Int {
        get {
            let userCount = selectedUsers.count
            let columnCount = max(userPanelColumnCount, 1)
            var rowCount:Int = (userCount / columnCount)
            if userCount % columnCount != 0 {
                rowCount += 1
            }
            return rowCount
        }
    }
    
    var userPanelWidth: CGFloat {
        get {
            return CGFloat(userPanelColumnCount) * kUserBorder + (CGFloat(userPanelColumnCount) - 1) * realSpacing
        }
    }
    
    var userPanelHeight: CGFloat {
        get {
            return CGFloat(userPanelRowCount) * kUserBorder + (CGFloat(userPanelRowCount) - 1) * realSpacing
        }
    }
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioSelectUserCollectionViewCell", for: indexPath) as! AudioSelectUserCollectionViewCell
        if (indexPath.row < selectedUsers.count) {
            let user = selectedUsers[indexPath.row]
            cell.config(model: user)
        } else {
            cell.config(model: UserModel(userID: ""))
        }
        return cell
    }
    
    //MARK: - collectionview layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kUserBorder, height: kUserBorder)
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if (indexPath.row < selectedUsers.count) {
            let user = selectedUsers[indexPath.row]
            selectedUsers = selectedUsers.filter {
                $0.userId != user.userId
            }
        }
    }
}
