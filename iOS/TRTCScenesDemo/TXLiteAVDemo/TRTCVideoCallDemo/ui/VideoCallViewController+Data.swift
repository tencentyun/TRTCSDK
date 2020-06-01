//
//  VideoCallViewController+Data.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
extension VideoCallViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [VideoCallUserModel], isInit: Bool = false) {
        resetUserList()
        let usersFilter = users.filter {
            $0.userId != VideoCallUtils.shared.curUserId()
        }
        userList.append(contentsOf: usersFilter)
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            var sp = sponsor
            sp.isVideoAvaliable = false
            userList = [sp]
        } else {
            var curUser = VideoCallUserModel()
            if let name = ProfileManager.shared.curUserModel?.name,
                let avatar = ProfileManager.shared.curUserModel?.avatar,
                let userId = ProfileManager.shared.curUserModel?.userId {
                curUser.name = name
                curUser.avatarUrl = avatar
                curUser.userId = userId
                curUser.isVideoAvaliable = true
                curUser.isEnter = true
            }
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionCount == 2 {
            return 0
        }
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCallUserCell", for: indexPath) as! VideoCallUserCell
        if (indexPath.row < avaliableList.count) {
            let user = avaliableList[indexPath.row]
            cell.UserModel = user
            if user.userId == VideoCallUtils.shared.curUserId(){
                localPreView.removeFromSuperview()
                cell.addSubview(localPreView)
                cell.sendSubviewToBack(localPreView)
                localPreView.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            }
        } else {
            cell.UserModel = VideoCallUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        let collectHight = collectionView.frame.size.height
        if (collectionCount <= 4) {
            let width = collectWidth / 2
            let height = collectHight / 2
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                if indexPath.row == 0 && collectionCount == 1 {
                    return CGSize(width: width, height: width)
                } else {
                    return CGSize(width: width, height: height)
                }
            } else {
                return CGSize(width: width, height: height)
            }
        } else {
            let width = collectWidth / 3
            let height = collectHight / 3
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// enterUser回调 每个用户进来只能调用一次
    /// - Parameter user: 用户信息
    func enterUser(user: VideoCallUserModel) {
        if user.userId != VideoCallUtils.shared.curUserId() {
            let renderView = VideoRenderView()
            renderView.UserModel = user
            TRTCVideoCall.shared.startRemoteView(userId: user.userId, view: renderView)
            VideoCallViewController.renderViews.append(renderView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
            renderView.addGestureRecognizer(tap)
            pan.require(toFail: tap)
            renderView.addGestureRecognizer(pan)
        }
        curState = .calling
        updateUser(user: user, animate: true)
    }
    
    func leaveUser(user: VideoCallUserModel) {
        TRTCVideoCall.shared.stopRemoteView(userId: user.userId)
        VideoCallViewController.renderViews = VideoCallViewController.renderViews.filter {
            $0.UserModel.userId != user.userId
        }
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            let dstUser = userList[index]
            let animate = dstUser.isVideoAvaliable
            userList.remove(at: index)
            reloadData(animate: animate)
        }
    }
    
    func updateUser(user: VideoCallUserModel, animate: Bool = false) {
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
        
        if curState == .calling && collectionCount > 2 {
            userCollectionView.isHidden = false
        } else {
            userCollectionView.isHidden = true
        }
        
        if collectionCount <= 2 {
            updateLayout()
            return
        }
        
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
    
    func updateLayout() {
        func setLocalViewInVCView(frame: CGRect, shouldTap: Bool = false) {
            if localPreView.frame == frame {
                return
            }
            localPreView.isUserInteractionEnabled = shouldTap
            localPreView.subviews.first?.isUserInteractionEnabled = !shouldTap
            if localPreView.superview != view {
                let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                localPreView.removeFromSuperview()
                view.insertSubview(localPreView, aboveSubview: userCollectionView)
                localPreView.frame = preFrame
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            }
        }
        
        if collectionCount == 2 {
            if localPreView.superview != view { // 从9宫格变回来
                setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoWidth - 18,
                                                   y: 20, width: kSmallVideoWidth, height: kSmallVideoWidth / 9.0 * 16.0), shouldTap: true)
            } else { //进来了一个人
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.collectionCount == 2 {
                        if self.localPreView.bounds.size.width != kSmallVideoWidth {
                            setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoWidth - 18,
                            y: 20, width: kSmallVideoWidth, height: kSmallVideoWidth / 9.0 * 16.0), shouldTap: true)
                        }
                    }
                }
            }
            
            let userFirst = avaliableList.filter {
                $0.userId != VideoCallUtils.shared.curUserId()
            }.first
            
            if let user = userFirst {
                if let firstRender = VideoCallViewController.getRenderView(userId: user.userId) {
                    firstRender.UserModel = user
                    if firstRender.superview != view {
                        let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                        view.insertSubview(firstRender, belowSubview: localPreView)
                        firstRender.frame = preFrame
                        UIView.animate(withDuration: 0.1) {
                            firstRender.frame = self.view.bounds
                        }
                    } else {
                        firstRender.frame = self.view.bounds
                    }
                } else {
                    print("error")
                }
            }
            
        } else { //用户退出只剩下自己（userleave引起的）
            if collectionCount == 1 {
                setLocalViewInVCView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
            }
        }
    }
}
