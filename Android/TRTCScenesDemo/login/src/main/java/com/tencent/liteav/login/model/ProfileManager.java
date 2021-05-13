package com.tencent.liteav.login.model;

import android.content.Context;
import android.text.TextUtils;
import android.app.Activity;
import android.util.Log;
import android.widget.Toast;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.login.R;

import java.util.ArrayList;
import java.util.List;

public class ProfileManager {
    private static final ProfileManager ourInstance = new ProfileManager();

    public static final int ERROR_CODE_UNKNOWN         = -1;
    public static final int ERROR_CODE_NEED_REGISTER   = -2;

    private final static String PER_DATA       = "per_profile_manager";
    private final static String PER_USER_MODEL = "per_user_model";
    private static final String PER_USER_ID    = "per_user_id";
    private static final String PER_TOKEN      = "per_user_token";
    private static final String PER_USER_DATE  = "per_user_publish_video_date";
    private static final String TAG            = ProfileManager.class.getName();

    private UserModel mUserModel;
    private String    mUserId;
    private String    mToken;
    private String    mUserPubishVideoDate;
    private boolean   isLogin = false;
    private Context   mContext;

    public static ProfileManager getInstance() {
        return ourInstance;
    }

    public void initContext(Context context) {
        mContext = context;
    }

    private ProfileManager() {
    }

    public boolean isLogin() {
        return isLogin;
    }

    public UserModel getUserModel() {
        if (mUserModel == null) {
            loadUserModel();
        }
        return mUserModel;
    }

    public String getUserId() {
        if (mUserId == null) {
            mUserId = SPUtils.getInstance(PER_DATA).getString(PER_USER_ID, "");
        }
        return mUserId;
    }

    private void setUserId(String userId) {
        mUserId = userId;
        SPUtils.getInstance(PER_DATA).put(PER_USER_ID, userId);
    }

    private void setUserModel(UserModel model) {
        mUserModel = model;
        saveUserModel();
    }

    public String getToken() {
        if (mToken == null) {
            loadToken();
        }
        return mToken;
    }

    public void setToken(String token) {
        mToken = token;
        SPUtils.getInstance(PER_DATA).put(PER_TOKEN, mToken);
    }

    private void loadToken() {
        mToken = SPUtils.getInstance(PER_DATA).getString(PER_TOKEN, "");
    }


    public String getUserPublishVideoDate() {
        if (mUserPubishVideoDate == null) {
            mUserPubishVideoDate = SPUtils.getInstance(PER_DATA).getString(PER_USER_DATE, "");
        }
        return mUserPubishVideoDate;
    }

    public void setUserPublishVideoDate(String date) {
        mUserPubishVideoDate = date;
        try {
            SPUtils.getInstance(PER_DATA).put(PER_USER_DATE, mUserPubishVideoDate);
        } catch (Exception e) {
        }
    }

    public void getSms(String phone, final ActionCallback callback) {
        callback.onSuccess();
    }

    public void logout(final ActionCallback callback) {
        setUserId("");
        isLogin = false;
        callback.onSuccess();
    }

    public void login(String userId, String sms, final ActionCallback callback) {
        isLogin = true;
        setUserId(userId);
        final UserModel userModel = new UserModel();
        userModel.phone = userId;
        userModel.userId = userId;
        userModel.userSig = GenerateTestUserSig.genTestUserSig(userModel.userId);
        setUserModel(userModel);
        loginIM(userModel, new ActionCallback() {
            @Override
            public void onSuccess() {
                setUserModel(userModel);
                isLogin = true;
                callback.onSuccess();
            }

            @Override
            public void onFailed(int code, String msg) {
                isLogin = false;
                callback.onFailed(code, msg);
            }
        });
    }

    public void autoLogin(String userId, String token, final ActionCallback callback) {
        isLogin = true;
        setUserId(userId);
        final UserModel userModel = new UserModel();
        userModel.phone = userId;
        userModel.userId = userId;
        userModel.userSig = GenerateTestUserSig.genTestUserSig(userModel.userId);
        setUserModel(userModel);
        loginIM(userModel, new ActionCallback() {
            @Override
            public void onSuccess() {
                setUserModel(userModel);
                isLogin = true;
                callback.onSuccess();
            }

            @Override
            public void onFailed(int code, String msg) {
                isLogin = false;
                callback.onFailed(code, msg);
            }
        });
    }

    private void loginIM(final UserModel userModel, final ActionCallback callback) {
        if (mContext == null) {
            Log.d(TAG, "login im failed, context is null");
            return;
        }
        final IMManager imManager = IMManager.sharedInstance();
        imManager.initIMSDK(mContext);
        imManager.login(userModel.userId, userModel.userSig, new IMManager.ActionCallback() {
            @Override
            public void onSuccess() {
                //1. 登录IM成功
                showToast(mContext.getString(R.string.login_toast_login_success));
                imManager.getUserInfo(userModel.userId, new IMManager.UserCallback() {
                    @Override
                    public void onCallback(int code, String msg, IMUserInfo userInfo) {
                        if (code == 0) {
                            if (userInfo == null) {
                                callback.onFailed(ERROR_CODE_UNKNOWN, "user info get is null");
                                return;
                            }
                            // 如果说第一次没有设置用户名，跳转注册用户名
                            if (TextUtils.isEmpty(userInfo.userName)) {
                                callback.onFailed(ERROR_CODE_NEED_REGISTER, mContext.getString(R.string.login_not_register));
                            } else {
                                userModel.userName = userInfo.userName;
                                userModel.userAvatar = userInfo.userAvatar;
                                callback.onSuccess();
                            }
                        } else {
                            callback.onFailed(code, msg);
                        }
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                // 登录IM失败
                callback.onFailed(code, msg);
                showToast(mContext.getString(R.string.login_toast_login_fail, code, msg));
            }
        });
    }

    public void setNickName(final String nickname, final ActionCallback callback) {
        IMManager.sharedInstance().setNickname(nickname, new IMManager.Callback() {
            @Override
            public void onCallback(int errorCode, String message) {
                if (errorCode == 0) {
                    mUserModel.userName = nickname;
                    saveUserModel();
                    callback.onSuccess();
                } else {
                    callback.onFailed(errorCode, message);
                    showToast(mContext.getString(R.string.login_toast_failed_to_set_username, message));
                }
            }
        });
    }

    public void setAvatar(final String avatar, final ActionCallback callback) {
        IMManager.sharedInstance().setAvatar(avatar, new IMManager.Callback() {
            @Override
            public void onCallback(int errorCode, String message) {
                if (errorCode == 0) {
                    mUserModel.userAvatar = avatar;
                    saveUserModel();
                    callback.onSuccess();
                } else {
                    callback.onFailed(errorCode, message);
                    showToast(mContext.getString(R.string.login_toast_failed_to_set_username, message));
                }
            }
        });
    }

    public void setNicknameAndAvatar(final String nickname, final String avatar, final ActionCallback callback) {
        IMManager.sharedInstance().setAvatar(avatar, new IMManager.Callback() {
            @Override
            public void onCallback(int errorCode, String message) {
                if (errorCode == 0) {
                    mUserModel.userAvatar = avatar;
                    mUserModel.userName = nickname;
                    saveUserModel();
                    callback.onSuccess();
                } else {
                    callback.onFailed(errorCode, message);
                    showToast(mContext.getString(R.string.login_toast_failed_to_set_username, message));
                }
            }
        });
    }

    public NetworkAction getUserInfoByUserId(String userId, final GetUserInfoCallback callback) {
        UserModel userModel = new UserModel();
        userModel.userAvatar = getAvatarUrl(userId);
        userModel.phone = userId;
        userModel.userId = userId;
        userModel.userName = userId;
        callback.onSuccess(userModel);
        return new NetworkAction();
    }

    public NetworkAction getUserInfoByPhone(String phone, final GetUserInfoCallback callback) {
        UserModel userModel = new UserModel();
        userModel.userAvatar = getAvatarUrl(phone);
        userModel.phone = phone;
        userModel.userId = phone;
        userModel.userName = phone;
        callback.onSuccess(userModel);
        return new NetworkAction();
    }

    public void getUserInfoBatch(List<String> userIdList, final GetUserInfoBatchCallback callback) {
        if (userIdList == null) {
            return;
        }
        List<UserModel> userModelList = new ArrayList<>();
        for (String userId : userIdList) {
            UserModel userModel = new UserModel();
            userModel.userAvatar = getAvatarUrl(userId);
            userModel.phone = userId;
            userModel.userId = userId;
            userModel.userName = userId;
            userModelList.add(userModel);
        }
        callback.onSuccess(userModelList);
    }

    private String getAvatarUrl(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }
        byte[] bytes = userId.getBytes();
        int    index = bytes[bytes.length - 1] % 10;
        String avatarName = "avatar" + index + "_100";
        return "https://imgcache.qq.com/qcloud/public/static//" + avatarName + ".20191230.png";
    }

    private void showToast(String message) {
        Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
    }

    private void saveUserModel() {
        try {
            SPUtils.getInstance(PER_DATA).put(PER_USER_MODEL, GsonUtils.toJson(mUserModel));
        } catch (Exception e) {
        }
    }

    private void loadUserModel() {
        try {
            String json = SPUtils.getInstance(PER_DATA).getString(PER_USER_MODEL);
            mUserModel = GsonUtils.fromJson(json, UserModel.class);
        } catch (Exception e) {
        }
    }

    public static class NetworkAction {

        public NetworkAction() {
        }

        public void cancel() {
        }
    }

    // 操作回调
    public interface ActionCallback {
        void onSuccess();

        void onFailed(int code, String msg);
    }

    // 通过userid/phone获取用户信息回调
    public interface GetUserInfoCallback {
        void onSuccess(UserModel model);

        void onFailed(int code, String msg);
    }

    // 通过userId批量获取用户信息回调
    public interface GetUserInfoBatchCallback {
        void onSuccess(List<UserModel> model);

        void onFailed(int code, String msg);
    }

    public void checkNeedShowSecurityTips(Activity activity) {

    }
}
