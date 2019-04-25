package com.tencent.liteav.demo.trtc;

import android.text.TextUtils;
import android.util.Log;

import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * Module:   TRTCHttpHelper
 *
 * Function: 用http向服务器请求usersig
 *
 */
public class TRTCHttpHelper {
    private final static int CONNECT_TIMEOUT = 10;
    private final static int READ_TIMEOUT = 8;
    private final static int WRITE_TIMEOUT = 8;

    private final static String JSON_ERRORCODE = "errorCode";
    private final static String JSON_ERRORINFO = "errorInfo";
    private final static String JSON_DATA = "data";

    private final static String JSON_APPID = "appid";
    private final static String JSON_ROOMNUM = "roomnum";
    private final static String JSON_IDENTIFIER = "identifier";
    private final static String JSON_USERSIG = "userSig";
    private final static String JSON_PWD = "pwd";
    private final static String JSON_PRIVMAP = "privMap";
    private final static String JSON_ACCTYPE = "accounttype";

    private final static String SERVER_URL = "";

    private static final String TAG = TRTCHttpHelper.class.getSimpleName();

    private OkHttpClient okHttpClient;

    public TRTCHttpHelper() {
        okHttpClient = new OkHttpClient.Builder()
                .addInterceptor(new RetryInterceptor(3))//重试
                .readTimeout(READ_TIMEOUT, TimeUnit.SECONDS)//设置读取超时时间
                .writeTimeout(WRITE_TIMEOUT, TimeUnit.SECONDS)//设置写的超时时间
                .connectTimeout(CONNECT_TIMEOUT, TimeUnit.SECONDS)//设置连接超时时间
                .build();
    }

    public void post(int sdkAppId, int roomId, String userId, String password, final TRTCGetUserIDAndUserSig.IGetUserSigListener listener) {
        if (TextUtils.isEmpty(SERVER_URL)) {
            if (listener != null) {
                listener.onComplete(null, "url is empty");
            }
            return;
        }
        try {
            JSONObject jsonReq = new JSONObject();
            jsonReq.put(JSON_APPID, sdkAppId);
            jsonReq.put(JSON_ROOMNUM, roomId);
            jsonReq.put(JSON_IDENTIFIER, userId);
            jsonReq.put(JSON_PWD, password);
            jsonReq.put(JSON_PRIVMAP, 255);
            jsonReq.put(JSON_ACCTYPE, 14418);
            RequestBody body = RequestBody.create(MediaType.parse("application/json"), jsonReq.toString());
            Request req = new Request.Builder()
                    .url(SERVER_URL)
                    .post(body)
                    .build();
            Log.i(TAG, "loadUserSig->url: "+req.url().toString());
            Log.i(TAG, "loadUserSig->post: "+jsonReq.toString());
            okHttpClient.newCall(req).enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    Log.w(TAG, "loadUserSig->fail: "+e.toString());
                    if (listener != null) {
                        listener.onComplete(null, "http request failed");
                    }
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    if (!response.isSuccessful()){
                        Log.w(TAG, "loadUserSig->fail: "+response.message());
                        if (listener != null) {
                            listener.onComplete(null, response.message());
                        }
                    }else{
                        try {
                            JSONTokener jsonTokener = new JSONTokener(response.body().string());
                            JSONObject msgJson = (JSONObject) jsonTokener.nextValue();
                            int code = msgJson.getInt(JSON_ERRORCODE);
                            if (0 != code){
                                if (listener != null) {
                                    listener.onComplete(null, msgJson.getString(JSON_ERRORINFO));
                                }
                            }else{
                                JSONObject dataJson = msgJson.getJSONObject(JSON_DATA);
                                String userSig = dataJson.getString(JSON_USERSIG);
                                if (listener != null) {
                                    listener.onComplete(userSig, msgJson.getString(JSON_ERRORINFO));
                                }
                            }
                        }catch (Exception e){
                            Log.i(TAG, "loadUserSig->exception: "+e.toString());
                            if (listener != null) {
                                listener.onComplete(null, e.toString());
                            }
                        }
                    }
                }
            });
        } catch (Exception e){
            if (listener != null) {
                listener.onComplete(null, e.toString());
            }
        }
    }

    /**
     * 重试拦截器
     */
    static class RetryInterceptor implements Interceptor {

        public int maxRetry;//最大重试次数
        private int retryNum = 0;//假如设置为3次重试的话，则最大可能请求4次（默认1次+3次重试）

        public RetryInterceptor(int maxRetry) {
            this.maxRetry = maxRetry;
        }

        @Override
        public Response intercept(Interceptor.Chain chain) throws IOException {
            Request request = chain.request();
            Log.i("ServerUserSig", "retryNum=" + retryNum+ "/" + maxRetry);
            Response response = chain.proceed(request);
            while (!response.isSuccessful() && retryNum < maxRetry) {
                retryNum++;
                Log.i("ServerUserSig", "retryNum=" + retryNum + "/" + maxRetry);
                response = chain.proceed(request);
            }
            return response;
        }
    }
}
