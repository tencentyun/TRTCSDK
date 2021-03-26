package com.tencent.liteav.trtcchatsalon.model.impl.room.impl;

import android.text.TextUtils;
import android.util.Pair;

import com.google.gson.Gson;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TRTCLogger;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXInviteData;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXRoomInfo;
import com.tencent.liteav.trtcchatsalon.model.impl.base.TXSeatInfo;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_CUSTOM_MSG;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_DESTROY;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_KICK_SEAT_MSG;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.CODE_ROOM_PICK_SEAT_MSG;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_ATTR_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_CMD_ACTION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_CMD_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_ROOM_INFO;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_SEAT;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.KEY_USER_ID;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.VALUE_ATTR_VERSION;
import static com.tencent.liteav.trtcchatsalon.model.impl.room.impl.IMProtocol.Define.VALUE_CMD_VERSION;

public class IMProtocol {
    private static final String TAG = IMProtocol.class.getName();


    public static class Define {
        public static final String KEY_ATTR_VERSION   = "version";
        public static final String VALUE_ATTR_VERSION = "1.0";
        public static final String KEY_ROOM_INFO      = "roomInfo";
        public static final String KEY_SEAT           = "seat";
        public static final String KEY_USER_ID        = "userId";

        public static final String KEY_CMD_VERSION   = "version";
        public static final String VALUE_CMD_VERSION = "1.0";
        public static final String KEY_CMD_ACTION    = "action";

        public static final String KEY_INVITATION_VERSION   = "version";
        public static final String VALUE_INVITATION_VERSION = "1.0";
        public static final String KEY_INVITATION_CMD       = "command";
        public static final String KEY_INVITATION_CONTENT   = "content";


        public static final int CODE_UNKNOWN      = 0;
        public static final int CODE_ROOM_DESTROY = 200;

        public static final int CODE_ROOM_CUSTOM_MSG = 301;
        public static final int CODE_ROOM_KICK_SEAT_MSG = 302;
        public static final int CODE_ROOM_PICK_SEAT_MSG = 303;
    }

    public static HashMap<String, String> getInitRoomMap(TXRoomInfo TXRoomInfo) {
        Gson                    gson    = new Gson();
        HashMap<String, String> jsonMap = new HashMap<>();
        jsonMap.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
        jsonMap.put(KEY_ROOM_INFO, gson.toJson(TXRoomInfo));
        return jsonMap;
    }

    public static HashMap<String, String> getSeatInfoListJsonStr(Map<String, TXSeatInfo> TXSeatInfoMap) {
        Gson                    gson    = new Gson();
        HashMap<String, String> jsonMap = new HashMap<>();
        for (Map.Entry<String, TXSeatInfo> entry: TXSeatInfoMap.entrySet()) {
            String json = gson.toJson(entry.getValue(), TXSeatInfo.class);
            jsonMap.put(KEY_SEAT + entry.getKey(), json);
        }
        return jsonMap;
    }

    public static HashMap<String, String> getSeatInfoJsonStr(String userId, TXSeatInfo info) {
        Gson                    gson = new Gson();
        String                  json = gson.toJson(info, TXSeatInfo.class);
        HashMap<String, String> map  = new HashMap<>();
        map.put(KEY_SEAT + userId, json);
        return map;
    }

    public static List<String> getSeatKey(String userId) {
        List<String> seatUserIdList = new ArrayList<>();
        seatUserIdList.add(KEY_SEAT + userId);
        return seatUserIdList;
    }

    public static TXRoomInfo getRoomInfoFromAttr(Map<String, String> map) {
        TXRoomInfo TXRoomInfo;
        Gson       gson = new Gson();
        String     json = map.get(KEY_ROOM_INFO);
        if (TextUtils.isEmpty(json)) {
            return null;
        }
        try {
            TXRoomInfo = gson.fromJson(json, TXRoomInfo.class);
        } catch (Exception e) {
            TRTCLogger.e(TAG, "parse room info json error! " + json);
            TXRoomInfo = null;
        }
        return TXRoomInfo;
    }

    public static List<TXSeatInfo> getSeatListFromAttr(Map<String, String> map) {
        Gson             gson        = new Gson();
        List<TXSeatInfo> txSeatInfoList = new ArrayList<>();
        for (Map.Entry<String, String> entry: map.entrySet()) {
            String json = entry.getValue();
            TXSeatInfo txSeatInfo = new TXSeatInfo();
            if (!TextUtils.isEmpty(json)) {
                try {
                    txSeatInfo = gson.fromJson(json, TXSeatInfo.class);
                } catch (Exception e) {
                    TRTCLogger.e(TAG, "parse seat info json error! " + json);
                }
            }
            txSeatInfoList.add(txSeatInfo);
        }
        return txSeatInfoList;
    }

    public static Map<String, TXSeatInfo> getSeatMapFromAttr(Map<String, String> map) {
        Gson             gson        = new Gson();
        Map<String, TXSeatInfo> seatMap = new HashMap<>();
        for (Map.Entry<String, String> entry: map.entrySet()) {
            String json = entry.getValue();
            TXSeatInfo txSeatInfo = new TXSeatInfo();
            if (!TextUtils.isEmpty(json)) {
                try {
                    txSeatInfo = gson.fromJson(json, TXSeatInfo.class);
                } catch (Exception e) {
                    TRTCLogger.e(TAG, "parse seat info json error! " + json);
                }
            }
            if (!TextUtils.isEmpty(txSeatInfo.user)) {
                seatMap.put(txSeatInfo.user, txSeatInfo);
            }
        }
        return seatMap;
    }

    public static String getInvitationMsg(String roomId, String cmd, String content) {
        Gson         gson = new Gson();
        TXInviteData data = new TXInviteData();
        data.roomId = roomId;
        data.command = cmd;
        data.message = content;
        return gson.toJson(data, TXInviteData.class);
    }

    public static TXInviteData parseInvitationMsg(String json) {
        Gson         gson = new Gson();
        TXInviteData data;
        try {
            data = gson.fromJson(json, TXInviteData.class);
        } catch (Exception e) {
            return null;
        }
        return data;
    }

    public static String getRoomDestroyMsg() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_CMD_VERSION, VALUE_CMD_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_DESTROY);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCusMsgJsonStr(String cmd, String msg) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_CUSTOM_MSG);
            jsonObject.put("command", cmd);
            jsonObject.put("message", msg);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getKickMsgJsonStr(String userId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_KICK_SEAT_MSG);
            jsonObject.put(KEY_USER_ID, userId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getPickMsgJsonStr(String userId) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_ATTR_VERSION, VALUE_ATTR_VERSION);
            jsonObject.put(KEY_CMD_ACTION, CODE_ROOM_PICK_SEAT_MSG);
            jsonObject.put(KEY_USER_ID, userId);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static Pair<String, String> parseCusMsg(JSONObject jsonObject) {
        String cmd     = jsonObject.optString("command");
        String message = jsonObject.optString("message");
        return new Pair<>(cmd, message);
    }
}