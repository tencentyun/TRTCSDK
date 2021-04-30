//
//  TRTCMeetingMainViewController+CollectionView.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/24/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

class MeetingRenderView: UIView {
    var attendeeModel = MeetingAttendeeModel() {
        didSet {
            configModel(model: attendeeModel)
        }
    }

    lazy var avatarImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var userLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .center
        user.font = UIFont.systemFont(ofSize: 15)
        user.numberOfLines = 2
        return user
    }()
    
    lazy var signalImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var volumeProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.backgroundColor = UIColor(hex: "#FFFFFF")
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.5)
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 1
        return progressView
    }()
    
    func configModel(model: MeetingAttendeeModel) {
        backgroundColor = UIColor(hex: "AAAAAA")

        if model.userId.count == 0 {
            return
        }
        
        // 头像
        self.addSubview(avatarImageView)
        avatarImageView.sd_setImage(with: URL(string: attendeeModel.avatarURL), placeholderImage: UIImage(named: "default_user"), options: [], completed: nil)
        avatarImageView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(50)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-25)
        }
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 25
        // 对方开了视频就隐藏头像
        refreshVideo(isVideoAvailable: model.isVideoAvailable)
        
        // 用户名
        self.addSubview(userLabel)
        userLabel.textAlignment = .left
        userLabel.text = attendeeModel.userName
        userLabel.snp.remakeConstraints { (make) in
            make.height.equalTo(20)
            make.leading.equalTo(20)
            make.bottom.equalTo(self).offset(-58)
        }
        
        // 网络信号
        self.addSubview(signalImageView)
        signalImageView.snp.remakeConstraints { (make) in
            make.height.equalTo(20)
            make.leading.equalTo(userLabel.snp.trailing).offset(10)
            make.bottom.equalTo(userLabel.snp.bottom).offset(-2)
        }
        refreshSignalView()
        
        // 音量进度条
        self.addSubview(volumeProgressView)
        volumeProgressView.snp.remakeConstraints { (make) in
            make.width.equalTo(self)
            make.height.equalTo(2)
            make.bottom.equalTo(self).offset(-2)
        }
        refreshVolumeProgress()
        
    }
    
    func getSignalImageView(networkQuality: Int) -> UIImage? {
        var image: UIImage?
        if networkQuality == 1 || networkQuality == 2 {  // 信号好
            image = UIImage(named: "meeting_signal3")
        } else if networkQuality == 3 || networkQuality == 4 { // 信号一般
            image = UIImage(named: "meeting_signal2")
        } else if networkQuality == 5 || networkQuality == 6 {  // 信号很差
            image = UIImage(named: "meeting_signal1")
        } else {
            image = UIImage(named: "metting_signal2")
        }
        return image
    }
    
    func refreshVolumeProgress() {
        let radio: Float = Float(attendeeModel.audioVolume) / 100.0
        volumeProgressView.progress = radio
    }
    
    func refreshSignalView() {
        signalImageView.image = getSignalImageView(networkQuality: attendeeModel.networkQuality)
    }
    
    func refreshVideo(isVideoAvailable: Bool) {
        attendeeModel.isVideoAvailable = isVideoAvailable
        avatarImageView.isHidden = isVideoAvailable
    }
    
    func isVideoAvailable() -> Bool {
        return attendeeModel.isVideoAvailable
    }
    
    func refreshAudio(isAudioAvailable: Bool) {
        attendeeModel.isAudioAvailable = isAudioAvailable
    }
    
    func isAudioAvailable() -> Bool {
        return attendeeModel.isAudioAvailable
    }
}

class MeetingAttendeeCell: UICollectionViewCell {
    weak var delegate: TRTCMeetingRenderViewDelegate?
    var isFirstPage: Bool = true
    
    var attendeeModels = [MeetingAttendeeModel]() {
        didSet {
            configModels(models: attendeeModels)
        }
    }
    
    func configModels(models: [MeetingAttendeeModel]) {
        // 删掉所有subview，不然刷新的时候会有残留画面
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if models.count == 0 {
            return
        }
        
        // 第一页：一个人全屏，两个人上下分布，其他为四宫格（一个ViewCell最多显示四个人）
        // 其余页：全部四宫格
        if isFirstPage && (models.count == 1) {
            configOneModel(model: models[0], rect: self.bounds)
            
        } else if isFirstPage && (models.count == 2) {
            let height = self.bounds.height / 2
            let rect1 = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height / 2)
            let rect2 = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + height, width: self.bounds.width, height: self.bounds.height / 2)
            configOneModel(model: models[0], rect: rect1)
            configOneModel(model: models[1], rect: rect2)
            
        } else {
            let width = self.bounds.width / 2
            let height = self.bounds.height / 2
            
            for index in 0..<models.count {
                let row = index / 2
                let col = index % 2
                let x = self.bounds.origin.x + width * CGFloat(col)
                let y = self.bounds.origin.y + height * CGFloat(row)
                
                let rect = CGRect(x: x, y: y, width: width, height: height)
                configOneModel(model: models[index], rect: rect)
            }
        }
    }
    
    func configOneModel(model: MeetingAttendeeModel, rect: CGRect) {
        if model.userId.count == 0 {
            return
        }
        
        let render = (self.delegate?.getRenderView(userId: model.userId))
        if render == nil {
            return
        }
        
        let renderView = render!
        if renderView.superview != self {
            renderView.removeFromSuperview()
            renderView.frame = rect
            addSubview(renderView)
            
            renderView.attendeeModel = model
            
            // 添加双击手势，双击view将其放大到全屏
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapTheRenderView(tap:)))
            tap.numberOfTapsRequired = 2 // 双击
            
            renderView.tag = 0
            renderView.isUserInteractionEnabled = true
            renderView.addGestureRecognizer(tap)
            
        } else {
            renderView.frame = rect
        }
    }

    @objc func tapTheRenderView(tap: UITapGestureRecognizer) {
        let view = tap.view
        let tag = view?.tag
        
        if tag == 0 {
            view?.tag = 1
            view?.frame = self.bounds
            self.bringSubviewToFront(view!)
            
        } else if tag == 1 {
            view?.tag = 0
            configModels(models: attendeeModels)
        }
    }
}

extension TRTCMeetingMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     func reloadData(animate: Bool = false) {
        if self.attendeeList.count % 4 == 0 {
            self.pageControl.numberOfPages = self.attendeeList.count / 4
        } else {
            self.pageControl.numberOfPages = self.attendeeList.count / 4 + 1
        }
        if self.pageControl.currentPage >= self.pageControl.numberOfPages {
            self.pageControl.currentPage = (self.pageControl.numberOfPages > 1 ? self.pageControl.numberOfPages - 1 : 0)
        }
        requestCurPageVideo(curPage: self.pageControl.currentPage)
        pageControl.isHidden = (pageControl.numberOfPages == 1)
        
        if animate {
            attendeeCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else {return}
                self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func requestCurPageVideo(curPage: Int) {
        // 不显示的画面则要停止拉流，不然浪费流量
        let startIndex = curPage * 4
        let endIndex = (startIndex + 4 < self.attendeeList.count ? startIndex + 4 : self.attendeeList.count)
        
        // 将其他页面的用户设置静画
        for index in 0..<startIndex {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: true)
            }
        }
        for index in endIndex..<self.attendeeList.count {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: true)
            }
        }
        // 当前页恢复播放
        for index in startIndex..<endIndex {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: self.attendeeList[index].isMuteVideo)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pageControl.numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeetingAttendeeCell", for: indexPath) as! MeetingAttendeeCell
        
        if (indexPath.row < self.pageControl.numberOfPages) {
            // 每个cell最多显示4个人的画面
            let startIndex = indexPath.row * 4
            let endIndex = (startIndex + 4 < attendeeList.count ? startIndex + 4 : attendeeList.count)
            
            var attendeeModels = [MeetingAttendeeModel]()
            for index in startIndex..<endIndex {
                if index < attendeeList.count {
                    attendeeModels.append(attendeeList[index])
                }
            }
            cell.delegate = self
            cell.isFirstPage = (indexPath.row == 0)
            cell.attendeeModels = attendeeModels
            
        } else {
            cell.attendeeModels = [MeetingAttendeeModel()]
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetYu = Int(scrollView.contentOffset.x) % Int(scrollView.frame.width)
        let offsetMuti = CGFloat(offsetYu) / (scrollView.frame.width)
        self.pageControl.currentPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
        scrollView.setContentOffset(CGPoint(x: Int(scrollView.frame.width) * self.pageControl.currentPage, y: 0), animated: true)
        
        // 请求当前页的视频
        requestCurPageVideo(curPage: self.pageControl.currentPage)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let delay = abs(velocity.x) > 0.4 ? 0.6 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let offsetYu = Int(scrollView.contentOffset.x) % Int(scrollView.frame.width)
            let offsetMuti = CGFloat(offsetYu) / (scrollView.frame.width)
            self.pageControl.currentPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
            scrollView.setContentOffset(CGPoint(x: Int(scrollView.frame.width) * self.pageControl.currentPage, y: 0), animated: true)
        }
    }
    
}


