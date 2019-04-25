package com.tencent.liteav.demo.trtc;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.liteav.demo.R;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;


/**
 * Module:   TRTCGetUserIDAndUserSig
 *
 * Function: 用于获取组装 TRTCParam 所必须的 UserSig，腾讯云使用 UserSig 进行安全校验，保护您的 TRTC 流量不被盗用
 */
public class TRTCGetUserIDAndUserSig {
    private int mSdkAppId;
    private ArrayList<String> mUserIdArray;
    private ArrayList<String> mUserSigArray;

    private TRTCHttpHelper httpHelper;

    public TRTCGetUserIDAndUserSig(Context context){
        mSdkAppId = 0;
        mUserIdArray = new ArrayList<>();
        mUserSigArray = new ArrayList<>();

        loadFromConfig(context);
    }

    /**
     * 获取config中配置的appid
     */
    public int getSdkAppIdFromConfig() {
        return mSdkAppId;
    }

    /**
     * 获取config中配置的userid列表
     */
    public ArrayList<String> getUserIdFromConfig() {
        return mUserIdArray;
    }

    /**
     * 获取config中配置的usersig列表
     */
    public ArrayList<String> getUserSigFromConfig() {
        return mUserSigArray;
    }

    /**
     * 从本地的测试用配置文件中读取一批userid 和 usersig
     * 配置文件可以通过访问腾讯云TRTC控制台（https://console.cloud.tencent.com/rav）中的【快速上手】页面来获取
     * 配置文件中的 userid 和 usersig 是由腾讯云预先计算生成的，每一组 usersig 的有效期为 180天
     *
     * 该方案仅适合本地跑通demo和功能调试，产品真正上线发布，要使用服务器获取方案，即 getUserSigFromServer
     *
     * 参考文档：https://cloud.tencent.com/document/product/647/17275#GetForDebug
     *
     */
    public void loadFromConfig(Context context) {
        InputStream is = null;
        try {
            is = context.getResources().openRawResource(R.raw.config);
            String jsonData = readTextFromInputStream(is);
            loadJsonData(jsonData);
        } catch (Exception e) {
            mUserIdArray = new ArrayList<>();
            mUserSigArray = new ArrayList<>();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
            } catch (Exception e) {

            }
        }
    }

    public interface IGetUserSigListener {
        void onComplete(String userSig, String errMsg);
    }
    /**
     * 通过 http 请求到客户的业务服务器上获取 userid 和 usersig
     * 这种方式可以将签发 usersig 的计算工作放在您的业务服务器上进行，这样一来，usersig 的签发工作就可以安全可控
     *
     * 但本demo中的 getUserSigFromServer 函数仅作为示例代码，要跑通该逻辑，您需要参考：https://cloud.tencent.com/document/product/647/17275#GetFromServer
     */
    public void getUserSigFromServer(int sdkAppId, int roomId, String userId, String password, IGetUserSigListener listener) {
        if (httpHelper == null) {
            httpHelper = new TRTCHttpHelper();
        }
        httpHelper.post(sdkAppId, roomId, userId, password, listener);
    }


    /** 读取资源文件 */
    private String readTextFromInputStream(InputStream is) throws Exception{
        InputStreamReader reader = new InputStreamReader(is);
        BufferedReader bufferedReader = new BufferedReader(reader);
        StringBuffer buffer = new StringBuffer("");
        String str;
        while (null != (str = bufferedReader.readLine())){
            buffer.append(str);
            buffer.append("\n");
        }
        return buffer.toString();
    }

    /** 解析JSON配置文件 */
    private void loadJsonData(String jsonData) {
        if (TextUtils.isEmpty(jsonData)) return;
        try {
            JSONTokener jsonTokener = new JSONTokener(jsonData);
            JSONObject msgJson = (JSONObject) jsonTokener.nextValue();
            mSdkAppId = msgJson.getInt("sdkappid");
            JSONArray jsonUsersArr = msgJson.getJSONArray("users");
            if (null != jsonUsersArr) {
                for (int i = 0; i < jsonUsersArr.length(); i++) {
                    JSONObject jsonUser = jsonUsersArr.getJSONObject(i);
                    mUserIdArray.add(jsonUser.getString("userId"));
                    mUserSigArray.add(jsonUser.getString("userToken"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            mSdkAppId = -1;
        }
    }
}
