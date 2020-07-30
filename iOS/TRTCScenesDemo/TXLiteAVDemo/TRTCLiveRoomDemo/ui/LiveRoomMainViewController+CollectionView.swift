//
//  LiveRoomMainViewController+Collection.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 2020/2/21.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

class LiveRoomCollectionViewCell: UICollectionViewCell {
    lazy var coverImg: UIImageView = {
       let img = UIImageView()
        img.layer.cornerRadius = 6
        img.layer.masksToBounds = true
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    lazy var memberCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .right
        return label
    }()
    
    lazy var memberImage: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(named: "")
        return image
    }()
    
    func config(model: TRTCLiveRoomInfo) {
        backgroundColor = .clear
        
        self.addSubview(memberImage)
        
        self.addSubview(coverImg)
        coverImg.snp.remakeConstraints { (make) in
            make.top.leading.equalTo(5)
            make.bottom.trailing.equalTo(-5)
        }

        coverImg.sd_setImage(with: URL(string: model.coverUrl.count > 0
            ? model.coverUrl : sdWebImgPlaceHolderStr()), completed: nil)
        
        self.addSubview(nameLabel)
        nameLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(coverImg).offset(2)
            make.bottom.equalTo(coverImg).offset(-8)
            make.trailing.equalTo(coverImg)
            make.height.equalTo(14)
        }
        nameLabel.text = model.roomName
        
        self.addSubview(ownerLabel)
        ownerLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(coverImg).offset(2)
            make.bottom.equalTo(nameLabel.snp.top).offset(-4)
            make.trailing.equalTo(coverImg)
            make.height.equalTo(14)
        }
        ownerLabel.text = model.ownerName
        
        self.addSubview(memberCountLabel)
        memberCountLabel.snp.remakeConstraints { (make) in
            make.trailing.equalTo(-6)
            make.bottom.equalTo(coverImg).offset(-9)
            make.leading.equalTo(coverImg).offset(-11)
            make.height.equalTo(11)
        }
        memberCountLabel.text = "\(model.memberCount)人"
    }
}


extension LiveRoomMainViewController: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveRoomCollectionViewCell", for: indexPath) as! LiveRoomCollectionViewCell
        if (indexPath.row < roomInfos.count) {
            let room = roomInfos[indexPath.row]
            cell.config(model: room)
        } else {
            cell.config(model: TRTCLiveRoomInfo(roomId: "", roomName: "",
                                                     coverUrl: "", ownerId: "",
                                                     ownerName: "", streamUrl: "",
                                                     memberCount: 0, roomStatus: .none))
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if (indexPath.row < roomInfos.count) {
            let room = roomInfos[indexPath.row]
            if room.ownerId != ProfileManager.shared.curUserID() {
                if let vc = TCAudienceViewController(play: room, videoIsReady: {
                    
                }) {
                    vc.liveRoom = liveRoom
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                createRoom()
            }
        }
    }
    
    //MARK: - collectionview layout
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 2 , height: view.bounds.width / 2)
    }
    
}
