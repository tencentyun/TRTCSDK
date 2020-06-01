package com.tencent.liteav.meeting.model.impl.room.impl;

import android.util.Pair;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static com.tencent.liteav.meeting.model.impl.room.impl.IMProtocol.Define.*;

public class IMProtocol {

    public static class Define {
        public static final String KEY_VERSION = "version";
        public static final String KEY_ACTION = "action";
        public static final String VALUE_PROTOCOL_VERSION = "1.0.0";

        public static final int CODE_UNKNOWN                   = 0;

        public static final int CODE_ROOM_TEXT_MSG             = 300;
        public static final int CODE_ROOM_CUSTOM_MSG           = 301;
    }

    public static String getRoomTextMsgHeadJsonStr() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_ROOM_TEXT_MSG);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static String getCusMsgJsonStr(String cmd, String msg) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(Define.KEY_VERSION, VALUE_PROTOCOL_VERSION);
            jsonObject.put(Define.KEY_ACTION, Define.CODE_ROOM_CUSTOM_MSG);
            jsonObject.put("command", cmd);
            jsonObject.put("message", msg);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }

    public static Pair<String, String> parseCusMsg(JSONObject jsonObject) {
        String cmd = jsonObject.optString("command");
        String message = jsonObject.optString("message");
        return new Pair<>(cmd, message);
    }
}
