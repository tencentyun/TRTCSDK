//
//  profileManager.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/23/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import Alamofire

let loginBaseUrl = "https://xxx.com/release/"

//LoginModel
@objc class LoginModel: NSObject, Codable {
    @objc var errorCode: Int = -1
    @objc var errorMessage: String = ""
    var data: LoginResultModel? = nil
}

@objc class LoginResultModel: NSObject, Codable {
    @objc var token: String
    @objc var phone: String
    @objc var name: String
    @objc var avatar: String
    @objc var userId: String
    @objc var userSig: String = ""
    
    public init(userID: String) {
        userId = userID
        token = userID
        phone = userID
        name = userID
        userSig = GenerateTestUserSig.genTestUserSig(userID)
        avatar = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"
        super.init()
    }
}

@objc class QueryModel: NSObject, Codable {
    @objc var errorCode: Int = -1
    @objc var errorMessage: String = ""
    var data: UserModel? = nil
}

@objc class QueryBatchModel: NSObject, Codable {
    @objc var errorCode: Int = -1
    @objc var errorMessage: String = ""
    var data: [UserModel]? = nil
}

@objc public class UserModel: NSObject, Codable {
    @objc var phone: String?
    @objc var name: String
    @objc var avatar: String
    @objc var userId: String
    
    public init(userID: String) {
        userId = userID
        name = userID
        avatar = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"
        phone = userID
        super.init()
    }
    
    func copy() -> UserModel {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            fatalError("encode failed")
        }
        let decoder = JSONDecoder()
        guard let target = try? decoder.decode(UserModel.self, from: data) else {
           fatalError("decode failed")
        }
        return target
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        if let user = object as? UserModel {
            if user.userId == userId {
                return true
            }
        }
        return false
    }
}

//NameModel
@objc class NameModel: NSObject, Codable {
    @objc var errorCode:
        Int32 = -1
    @objc var errorMessage: String = ""
}

//VerifyModel
@objc class VerifyModel: NSObject, Codable {
    @objc var errorCode: Int32 = -1
    @objc var errorMessage: String = ""
    var data: VerifyResultModel? = nil
}

@objc class VerifyResultModel: NSObject, Codable {
    var sessionId: String? = nil
    var requestId: String? = nil
    var codeStr: String? = nil
}

@objc public class ProfileManager: NSObject {
    @objc public static let shared = ProfileManager()
    private override init() {}
    
    var phone = BehaviorRelay<String>(value: "")
    var code = BehaviorRelay<String>(value: "")
    var sessionId: String = ""
    @objc var curUserModel: LoginResultModel? = nil
    
    /// 自动登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    /// - Returns:是否可以自动登录
    @objc public func autoLogin(success: @escaping ()->Void,
                          failed: @escaping (_ error: String)->Void) -> Bool {
        let tokenKey = "com.tencent.trtcScences.demo"
        if let cacheData = UserDefaults.standard.object(forKey: tokenKey) as? Data {
            do {
                let cacheUser = try JSONDecoder().decode(LoginResultModel.self, from: cacheData)
                curUserModel = cacheUser
                let fail: (_ error: String)->Void = { err in
                    failed(err)
                    UserDefaults.standard.set(nil, forKey: tokenKey)
                }
                login(success: success, failed: fail, auto: true)
                return true
            } catch {
                print("Retrieve Failed")
                return false
            }
        }
        return false
    }
    
    /// 发送验证码
    /// - Parameters:
    ///   - success: 成功
    ///   - failed: 失败
    ///   - error: 错误信息
    @objc public func sendVerifyCode(success: @escaping ()->Void,
                               failed: @escaping (_ error: String)-> Void) {
        let verifyCodeUrl = loginBaseUrl + "sms"
        let phoneValue = phone.value
        assert(phoneValue.count == 11)
        let params = ["phone":phoneValue, "method":"getSms"] as [String : Any]
        Alamofire.request(verifyCodeUrl, method: .post, parameters: params).responseJSON { [weak self] (data) in
            guard let self = self else {return}
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(VerifyModel.self, from: respData) else {
                    failed("VerifyModel decode failed")
                    fatalError("VerifyModel decode failed")
                }
                if result.errorCode == 0 , let sessionID = result.data?.sessionId {
                    self.sessionId = sessionID
                    success()
                } else {
                    failed(result.errorMessage)
                }
            } else {
                failed("Send failed, please try again later.")
            }
        }
    }
    
    /// 登录
    /// - Parameters:
    ///   - success: 登录成功
    ///   - failed: 登录失败
    ///   - error: 错误信息
    @objc public func login(success: @escaping ()->Void,
                      failed: @escaping (_ error: String)->Void , auto: Bool = false) {
        let phoneValue = phone.value
        if !auto {
            assert(phoneValue.count > 0)
            curUserModel = LoginResultModel(userID: phone.value)
        }
        // cache data
        let tokenKey = "com.tencent.trtcScences.demo"
        do {
            let cacheData = try JSONEncoder().encode(curUserModel)
            UserDefaults.standard.set(cacheData, forKey: tokenKey)
        } catch {
          print("Save Failed")
        }
        success()
    }
    
    /// 设置昵称
    /// - Parameters:
    ///   - name: 昵称
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    @objc public func setNickName(name: String, success: @escaping ()->Void,
                        failed: @escaping (_ error: String)->Void) {
        let nameUrl = loginBaseUrl + "nickname"
        guard let userId = curUserModel?.userId else {
            failed("Regist failed, please try again later.")
            return
        }
        guard let token = curUserModel?.token else {
            failed("Regist failed, please try again later.")
            return
        }
        let params = ["userId":userId,"name":name,"token":token] as [String : Any]
        Alamofire.request(nameUrl, method: .post, parameters: params).responseJSON { (data) in
            if let respData = data.data, respData.count > 0 {
                let decoder = JSONDecoder()
                guard let result = try? decoder.decode(NameModel.self, from: respData) else {
                    failed("NameModel decode失败")
                    fatalError("NameModel decode失败")
                }
                if result.errorCode == 0 {
                    success()
                    debugPrint("\(result)")
                } else {
                    debugPrint("\(result.errorMessage)")
                    if result.errorCode == -1008 { //token失效 返回到登录页面
                        failed(result.errorMessage)
                    } else {
                        failed(result.errorMessage)
                    }
                }
            } else {
                failed("Regist failed, please try again later.")
            }
        }
    }
    
    /// 根据手机号查询用户信息
    /// - Parameters:
    ///   - phone: 手机号码
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    @objc public func queryUserInfo(phone: String, success: @escaping (UserModel)->Void,
                              failed: @escaping (_ error: String)->Void) {
        if phone.count > 0 {
            success(UserModel.init(userID: phone))
        } else {
            failed("Wrong userID")
        }
    }
    
    /// 查询单个用户信息
    /// - Parameters:
    ///   - userID: 用户id
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error: 错误信息
    @objc public func queryUserInfo(userID: String, success: @escaping (UserModel)->Void,
                                    failed: @escaping (_ error: String)->Void) {
        if userID.count > 0 {
            success(UserModel.init(userID: userID))
        } else {
            failed("Wrong userID")
        }
    }
    
    /// 查询多个用户信息
    /// - Parameters:
    ///   - userIDs: 用户id列表
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - error : 错误信息
    @objc public func queryUserListInfo(userIDs: [String], success: @escaping ([UserModel])->Void,
                                  failed: @escaping (_ error: String)->Void) {
        if userIDs.count > 0 {
            var models: [UserModel] = []
            for userID in userIDs {
                models.append(UserModel.init(userID: userID))
            }
            success(models)
        } else {
            failed("Null userIDs")
        }
    }
    
    /// IM 登录当前用户
    /// - Parameters:
    ///   - success: 成功
    ///   - failed: 失败
    @objc func IMLogin(userSig: String, success: @escaping ()->Void, failed: @escaping (_ error: String)->Void) {
        V2TIMManager.sharedInstance()?.initSDK(SDKAPPID, config: nil, listener: nil)
        
        guard let userID = curUserModel?.userId else {
            failed("userID wrong")
            return
        }
        let user = String(userID)
        let loginParam = TIMLoginParam.init()
        loginParam.identifier = user
        loginParam.userSig = userSig
        V2TIMManager.sharedInstance()?.login(user, userSig: userSig, succ: {
            debugPrint("login success")
            V2TIMManager.sharedInstance()?.getUsersInfo([userID], succ: { [weak self] (infos) in
                guard let `self` = self else { return }
                if let info = infos?.first {
                    self.curUserModel?.avatar = info.faceURL
                    self.curUserModel?.name = info.nickName
                    self.curUserModel?.userId = info.userID
                    success()
                }
                else {
                    failed("")
                }
            }, fail: { (code, err) in
                failed(err ?? "")
                debugPrint("get user info failed, code:\(code), error: \(err ?? "nil")")
            })
            
            
        }, fail: { (code, errorDes) in
            failed(errorDes ?? "")
            debugPrint("login failed, code:\(code), error: \(errorDes ?? "nil")")
        })
    }
    
    @objc func curUserID() -> String? {
        guard let userID = curUserModel?.userId else {
            return nil
        }
        return userID
    }
    
    @objc public func removeLoginCache() {
        let tokenKey = "com.tencent.trtcScences.demo"
        UserDefaults.standard.set(nil, forKey: tokenKey)
    }
    
    @objc public func curUserSig() -> String {
           return curUserModel?.userSig ?? ""
    }
    
    @objc func synchronizUserInfo() {
        guard let userModel = curUserModel else {
            return
        }
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = userModel.name
        userInfo.faceURL = userModel.avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            debugPrint("set profile failed.")
        })
    }
}
