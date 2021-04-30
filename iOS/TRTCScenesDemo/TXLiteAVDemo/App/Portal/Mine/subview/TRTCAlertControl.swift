//
//  TRTCAlertViewModel.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

class AvatarModel: NSObject {
    let url: String
    init(url: String) {
        self.url = url
        super.init()
    }
}

class TRTCAlertViewModel: NSObject {
    
    func setUserAvatar(_ avatarUrl: String) {
        ProfileManager.shared.curUserModel?.avatar = avatarUrl
    }
    
    func synchronizUserInfo() {
        ProfileManager.shared.synchronizUserInfo()
    }
    
    var currentSelectAvatarModel: AvatarModel?
    
    lazy var avatarListDataSource: [AvatarModel] = {
        var res : [AvatarModel] = []
        
        let allUrl = [
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar10.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar11.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar12.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar13.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar14.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar15.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar16.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar17.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar18.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar19.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar2.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar20.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar21.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar22.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar23.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar24.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar3.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar4.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar5.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar6.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar7.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar8.png",
            "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar9.png",
        ]
        
        allUrl.forEach { (url) in
            let model = AvatarModel(url: url)
            res.append(model)
        }
        
        return res
    }()
}
