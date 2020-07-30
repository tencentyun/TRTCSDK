//
//  AudioCallUserCell.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/14/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

struct AudioCallUserModel: Equatable {
    var avatarUrl: String = ""
    var name: String = ""
    var volume: Float = 0
    var userId: String = ""
    var isEnter: Bool = false
    
    static func == (lhs: AudioCallUserModel, rhs: AudioCallUserModel) -> Bool {
        if lhs.userId == rhs.userId {
                return true
        }
        return false
    }
}

class AudioCallUserCell: UICollectionViewCell {
    
    lazy var loading: NVActivityIndicatorView  = {
        let load = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 60),
                                              type: .ballBeat,
                                              color: .white)
        return load
    }()

    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
       let user = UILabel()
        user.textColor = .white
        user.backgroundColor = .clear
        user.textAlignment = .center
        return user
    }()
    
    lazy var volumeProgress: UIProgressView = {
        let volume = UIProgressView()
        volume.backgroundColor = .clear
        return volume
    }()
    
    lazy var dimBk: UIView = {
        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.isHidden = true
        return dim
    }()
    
    var UserModel = AudioCallUserModel(){
        didSet {
            configModel(model: UserModel)
        }
    }
    
    func configModel(model: AudioCallUserModel) {
        
        self.addSubview(cellImgView)
        cellImgView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.snp.height)
            make.centerX.centerY.equalTo(self)
        }
        
        self.addSubview(cellUserLabel)
        cellUserLabel.snp.remakeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(cellImgView)
            make.height.equalTo(24)
        }
        
        self.addSubview(volumeProgress)
        volumeProgress.snp.remakeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(cellImgView)
            make.height.equalTo(4)
        }
        
        self.addSubview(dimBk)
        dimBk.snp.remakeConstraints { (make) in
            make.edges.equalTo(cellImgView)
        }
        
        self.addSubview(loading)
        loading.snp.remakeConstraints { (make) in
            make.center.equalTo(cellImgView)
            make.width.equalTo(44)
            make.height.equalTo(30)
        }
        cellImgView.sd_setImage(with: URL(string: model.avatarUrl), completed: nil)
        cellUserLabel.text = UserModel.name
        volumeProgress.progress = UserModel.volume
        let noModel = model.userId.count == 0
        dimBk.isHidden = UserModel.isEnter || noModel
        loading.isHidden = UserModel.isEnter || noModel
        if UserModel.isEnter || noModel {
            loading.stopAnimating()
        } else {
            loading.startAnimating()
        }
        cellUserLabel.isHidden = noModel
        volumeProgress.isHidden = noModel
    }
}
