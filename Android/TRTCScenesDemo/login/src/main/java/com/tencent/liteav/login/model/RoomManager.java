package com.tencent.liteav.login.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.OkHttpClient;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.POST;

public class RoomManager {
    private static final RoomManager mOurInstance = new RoomManager();

    public static final int ERROR_CODE_UNKNOWN = -1;

    private final Retrofit mRetrofit;
    private final Api      mApi;
    private       int      mSdkAppId;

    private Call<ResponseEntity<Void>>           createRoomCall;
    private Call<ResponseEntity<Void>>           destroyRoomCall;
    private Call<ResponseEntity<List<RoomInfo>>> getRoomListCall;

    public static RoomManager getInstance() {
        return mOurInstance;
    }

    private RoomManager() {
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        mRetrofit = new Retrofit.Builder()
                .baseUrl("https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/")
                .client(builder.build())
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        mApi = mRetrofit.create(Api.class);
    }

    /**
     * 需要先设置一个sdkappid
     *
     * @param sdkAppId
     */
    public void initSdkAppId(int sdkAppId) {
        mSdkAppId = sdkAppId;
    }

    public void createRoom(int roomId, String type, final ActionCallback callback) {
        if (createRoomCall != null && createRoomCall.isExecuted()) {
            createRoomCall.cancel();
        }
        Map<String, String> param = new HashMap<>();
        param.put("method", "createRoom");
        param.put("appId", String.valueOf(mSdkAppId));
        param.put("roomId", String.valueOf(roomId));
        param.put("type", type);
        createRoomCall = mApi.roomOperator(param);
        createRoomCall.enqueue(new Callback<ResponseEntity<Void>>() {
            @Override
            public void onResponse(Call<ResponseEntity<Void>> call, Response<ResponseEntity<Void>> response) {
                ResponseEntity res = response.body();
                if (res.errorCode == 0) {
                    if (callback != null) {
                        callback.onSuccess();
                    }
                } else {
                    if (callback != null) {
                        callback.onFailed(res.errorCode, res.errorMessage);
                    }
                }
            }

            @Override
            public void onFailure(Call<ResponseEntity<Void>> call, Throwable t) {
                if (callback != null) {
                    callback.onFailed(ERROR_CODE_UNKNOWN, "未知错误");
                }
            }
        });
    }

    public void destroyRoom(int roomId, String type, final ActionCallback callback) {
        if (destroyRoomCall != null && destroyRoomCall.isExecuted()) {
            destroyRoomCall.cancel();
        }
        Map<String, String> param = new HashMap<>();
        param.put("method", "destroyRoom");
        param.put("appId", String.valueOf(mSdkAppId));
        param.put("roomId", String.valueOf(roomId));
        param.put("type", type);
        destroyRoomCall = mApi.roomOperator(param);
        destroyRoomCall.enqueue(new Callback<ResponseEntity<Void>>() {
            @Override
            public void onResponse(Call<ResponseEntity<Void>> call, Response<ResponseEntity<Void>> response) {
                ResponseEntity res = response.body();
                if (res.errorCode == 0) {
                    if (callback != null) {
                        callback.onSuccess();
                    }
                } else {
                    if (callback != null) {
                        callback.onFailed(res.errorCode, res.errorMessage);
                    }
                }
            }

            @Override
            public void onFailure(Call<ResponseEntity<Void>> call, Throwable t) {
                if (callback != null) {
                    callback.onFailed(ERROR_CODE_UNKNOWN, "未知错误");
                }
            }
        });
    }

    public void getRoomList(String type, final GetRoomListCallback callback) {
        if (getRoomListCall != null && getRoomListCall.isExecuted()) {
            getRoomListCall.cancel();
        }
        Map<String, String> param = new HashMap<>();
        param.put("method", "getRoomList");
        param.put("appId", String.valueOf(mSdkAppId));
        param.put("type", type);
        getRoomListCall = mApi.getRoomList(param);
        getRoomListCall.enqueue(new Callback<ResponseEntity<List<RoomInfo>>>() {
            @Override
            public void onResponse(Call<ResponseEntity<List<RoomInfo>>> call, Response<ResponseEntity<List<RoomInfo>>> response) {
                ResponseEntity res = response.body();
                if (res.errorCode == 0 && res.data != null) {
                    List<RoomInfo> roomInfoList = (List<RoomInfo>) res.data;
                    List<String>   roomIdList   = new ArrayList<>();
                    for (RoomInfo info : roomInfoList) {
                        roomIdList.add(info.roomId);
                    }
                    if (callback != null) {
                        callback.onSuccess(roomIdList);
                    }
                } else {
                    if (callback != null) {
                        callback.onFailed(res.errorCode, res.errorMessage);
                    }
                }
            }

            @Override
            public void onFailure(Call<ResponseEntity<List<RoomInfo>>> call, Throwable t) {
                if (callback != null) {
                    callback.onFailed(ERROR_CODE_UNKNOWN, "未知错误");
                }
            }
        });
    }

    /**
     * ==== 网络层相关 ====
     */
    private interface Api {
        @POST("/forTest")
        @FormUrlEncoded
        Call<ResponseEntity<Void>> roomOperator(@FieldMap Map<String, String> map);


        @POST("/forTest")
        @FormUrlEncoded
        Call<ResponseEntity<List<RoomInfo>>> getRoomList(@FieldMap Map<String, String> map);
    }

    private class ResponseEntity<T> {
        public int    errorCode;
        public String errorMessage;
        public T      data;
    }

    public static class RoomInfo {
        public String roomId;
    }

    // 操作回调
    public interface ActionCallback {
        void onSuccess();

        void onFailed(int code, String msg);
    }

    // 操作回调
    public interface GetRoomListCallback {
        void onSuccess(List<String> roomIdList);

        void onFailed(int code, String msg);
    }
}
