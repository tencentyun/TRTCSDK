@objc enum AudioCallAction: Int32, Codable { //UserA 向 UserB 发起通话请求
    case error = -1             //系统错误
    case unknown = 0            //未知流程
    case dialing = 1            //请求发起
    case sponsorCancel = 2      //用户取消 [UserA 在 UserB 未回应时主动取消视频请求]
    case reject = 3             //用户拒绝 [UserB 拒绝通话]
    case sponsorTimeout = 4     //用户未应答 [UserB 超时未回复]
    case hangup = 5             //用户挂断 [UserA or UserB 挂断通话]
    case linebusy = 6           //用户通话中 [UserB 通话中]
}

@objc public enum AudioCallType : Int32, Codable {
    case unknown = 0
    case audio = 1
    case video = 2
}

//model
@objc class AudioCallModel: NSObject, Codable {
    @objc var version: UInt32 = audioCallVersion                //自定义消息 version
    @objc internal var calltype: AudioCallType = .unknown       //邀请类型 video or voice
    @objc var groupid: String? = nil                            //邀请群组
    @objc var callid: String = ""                               //通话ID，每次请求的唯一ID
    @objc var roomid: UInt32 = 0                                //房间ID
    @objc var action: AudioCallAction = .unknown                //信令消息
    @objc var code: Int = 0                                     //信令代码
    @objc var invitedList: [String] = []                        //邀请列表
    
    func copy() -> AudioCallModel {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("encode失败")
        }
        let decoder = JSONDecoder()
        guard let target = try? decoder.decode(AudioCallModel.self, from: data) else {
           fatalError("decode失败")
        }
        return target
    }
    
    enum CodingKeys: String, CodingKey {
        case version
        case calltype = "call_type"
        case groupid = "group_id"
        case callid = "call_id"
        case roomid = "room_id"
        case action
        case invitedList = "invited_list"
    }
}


extension AudioCallAction {
    var debug: String {
        switch self {
        case .dialing:
            return ".dialing"
        case .sponsorCancel:
            return ".sponsorCancel"
        case .reject:
            return ".reject"
        case .sponsorTimeout:
            return ".sponsorTimeout"
        case .hangup:
            return ".hangup"
        case .linebusy:
            return ".linebusy"
        default:
            return ".unknown"
        }
    }
}

//constant
let audioCallVersion: UInt32 = 4
