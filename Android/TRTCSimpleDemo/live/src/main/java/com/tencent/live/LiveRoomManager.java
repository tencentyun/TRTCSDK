package com.tencent.live;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.liteav.debug.GenerateTestUserSig;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * RTC视频互动直播房间管理逻辑
 *
 * 包括房间创建/销毁，房间列表拉取
 */
public class LiveRoomManager {

    private static final String TAG = "LiveRoomManager";
    private static final String URL = "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest";

    private RoomListListener                mListener;
    private final List<String>              mRoomList = new ArrayList<>();


    private String fetchData(Map<String, String> paramsMap) {
        try {
            java.net.URL url = new URL(URL);
            URLConnection connection = url.openConnection();
            connection.setDoInput(true);
            connection.setDoOutput(true);
            DataOutputStream dos = new DataOutputStream(connection.getOutputStream());
            StringBuilder sb = new StringBuilder();
            for (String key : paramsMap.keySet()) {
                sb.append(key + "=" + URLEncoder.encode(paramsMap.get(key), "UTF-8") + "&");
            }
            dos.writeBytes(sb.toString());
            dos.flush();
            dos.close();
            BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder sbt = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sbt.append(line);
            }
            Log.e(TAG, "fetchData: " + sbt.toString() + "");
            return sbt.toString();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 创建直播房间
     */
    public void createLiveRoom() {
        final Map<String, String> map = new HashMap<>();
        map.put("method", "createRoom");
        map.put("appId", GenerateTestUserSig.SDKAPPID + "");
        map.put("type", "1");
        // 进房roomid为 int 值，所以这里也需要 int， 为了方便直接转换成string，请保持和进房int一致
        final String roomId = String.valueOf(System.currentTimeMillis()%100000000);
        map.put("roomId", roomId);
        new Thread(new Runnable() {
            @Override
            public void run() {
                String info = fetchData(map);
                if (TextUtils.isEmpty(info)) {
                    return;
                }
                if (info.contains("创建房间成功")) {
                    if (mListener != null) {
                        mListener.onCreateRoomSuccess(roomId);
                    }
                }
            }
        }).start();
    }

    /**
     * 获取直播房间列表
     */
    public void queryLiveRoomList() {
        final Map<String, String> map = new HashMap<>();
        map.put("method", "getRoomList");
        map.put("appId", GenerateTestUserSig.SDKAPPID + "");
        map.put("type", "1");

        new Thread(new Runnable() {
            @Override
            public void run() {
                String jsonData = fetchData(map);
                if (TextUtils.isEmpty(jsonData)) {
                    if (mListener != null) {
                        mListener.onError("创建房间失败，请检查网络是否正常！");
                    }
                    return;
                }
                try {
                    JSONObject jsonObject = new JSONObject(jsonData);
                    JSONArray data = jsonObject.getJSONArray("data");
                    mRoomList.clear();
                    for (int i = 0; i < data.length(); i++ ) {
                        JSONObject dataObj = data.getJSONObject(i);
                        String roomId = dataObj.getString("roomId");
                        mRoomList.add(roomId);
                    }
                    if (mListener != null) {
                        mListener.onQueryRoomListSuccess(mRoomList);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    /**
     * 销毁直播房间
     */
    public void destoryLiveRoom(String roomId) {
        final HashMap<String, String> map = new HashMap<>();
        map.put("method", "destroyRoom");
        map.put("appId", GenerateTestUserSig.SDKAPPID + "");
        map.put("type", "1");
        map.put("roomId", String.valueOf(roomId));
        new Thread(new Runnable() {
            @Override
            public void run() {
                String info = fetchData(map);
                if (TextUtils.isEmpty(info)) {
                    return;
                }
                if (info.contains("销毁房间成功")) {
                    if (mListener != null) {
                        mListener.onDestoryRoomSuccess();
                    }
                }
            }
        }).start();
    }

    public void setRoomListListener(RoomListListener listener) {
        mListener = listener;
    }

    public interface RoomListListener {
        void onCreateRoomSuccess(String roomId);
        void onQueryRoomListSuccess(List<String> list);
        void onDestoryRoomSuccess();
        void onError(String errorInfo);
    }

}
