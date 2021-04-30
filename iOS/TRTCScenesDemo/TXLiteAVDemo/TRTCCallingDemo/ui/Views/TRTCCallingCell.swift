//
//  CallUserCell.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import SnapKit
import NVActivityIndicatorView

class CallingSelectUserTableViewCell: UITableViewCell {
    private var isViewReady = false
    private var buttonAction: (() -> Void)?
    lazy var userImageView: UIImageView = {
       let img = UIImageView()
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        return label
    }()
    
    let callButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.appTint
        button.setTitle(TRTCLocalize("Demo.TRTC.Streaming.call"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        contentView.addSubview(userImageView)
        userImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
            make.centerY.equalTo(self)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(userImageView.snp.trailing).offset(12)
            make.trailing.top.bottom.equalTo(self)
        }
        
        contentView.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-20)
        }
        
        callButton.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAction = nil
    }
    
    func config(model: UserModel, selected: Bool = false, action: (() -> Void)? = nil) {
        backgroundColor = .clear
        userImageView.sd_setImage(with: URL(string: model.avatar), completed: nil)
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = 25
        nameLabel.text = model.name
        buttonAction = action
    }
    
    @objc
    func callAction(_ sender: UIButton) {
        if let action = self.buttonAction {
            action()
        }
    }
}

class AudioCallUserCell: UICollectionViewCell {
    
    private var isViewReady: Bool = false
    
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
    
    lazy var cellVoiceImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.init(named: "calling_mic")
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
       let user = UILabel()
        user.textColor = .white
        user.backgroundColor = .clear
        user.textAlignment = .left
        return user
    }()
    
    lazy var dimBk: UIView = {
        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.isHidden = true
        return dim
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        addSubview(cellImgView)
        cellImgView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.snp.height)
            make.centerX.centerY.equalTo(self)
        }
        
        addSubview(cellUserLabel)
        cellUserLabel.snp.remakeConstraints { (make) in
            make.bottom.left.equalTo(cellImgView)
            make.height.equalTo(24)
            make.right.equalTo(cellImgView).offset(-24)
        }
        
        addSubview(cellVoiceImageView)
        cellVoiceImageView.snp.remakeConstraints { (make) in
            make.bottom.right.equalTo(cellImgView)
            make.height.width.equalTo(24)
        }
        
        addSubview(dimBk)
        dimBk.snp.remakeConstraints { (make) in
            make.edges.equalTo(cellImgView)
        }
        
        addSubview(loading)
        loading.snp.remakeConstraints { (make) in
            make.center.equalTo(cellImgView)
            make.width.equalTo(44)
            make.height.equalTo(30)
        }
    }
    
    var userModel = CallingUserModel(){
        didSet {
            configModel(model: userModel)
        }
    }
    
    func configModel(model: CallingUserModel) {
        cellImgView.sd_setImage(with: URL(string: model.avatarUrl), completed: nil)
        cellUserLabel.text = userModel.name
        let noModel = model.userId.count == 0
        dimBk.isHidden = userModel.isEnter || noModel
        loading.isHidden = userModel.isEnter || noModel
        if userModel.isEnter || noModel {
            loading.stopAnimating()
        } else {
            loading.startAnimating()
        }
        cellUserLabel.isHidden = noModel
        cellVoiceImageView.isHidden = model.volume < 0.05
    }
}

class VideoCallUserCell: UICollectionViewCell {
   
    var userModel = CallingUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    func configModel(model: CallingUserModel) {
        let noModel = model.userId.count == 0
        if !noModel {
            if userModel.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? "" {
                if let render = TRTCCallingVideoViewController.getRenderView(userId: userModel.userId) {
                    if render.superview != self {
                        render.removeFromSuperview()
                        DispatchQueue.main.async {
                            render.frame = self.bounds
                        }
                        addSubview(render)
                        render.userModel = userModel
                    }
                } else {
                    print("error")
                }
            }
        }
    }
}
