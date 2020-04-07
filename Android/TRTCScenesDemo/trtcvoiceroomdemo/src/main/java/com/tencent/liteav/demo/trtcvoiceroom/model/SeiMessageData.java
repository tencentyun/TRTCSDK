package com.tencent.liteav.demo.trtcvoiceroom.model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * sei回调消息
 */
public class SeiMessageData implements Serializable {
    @SerializedName("canvas")
    @Expose
    public Canvas       canvas;
    @SerializedName("regions")
    @Expose
    public List<Region> regions = new ArrayList<>();
    @SerializedName("ver")
    @Expose
    public String       ver;
    @SerializedName("ts")
    @Expose
    public long          ts;
    @SerializedName("app_data")
    @Expose
    public String       appData;


    public class Region implements Serializable {
        @SerializedName("uid")
        @Expose
        public String uid;
        @SerializedName("zorder")
        @Expose
        public int    zorder;
        @SerializedName("volume")
        @Expose
        public int    volume;
        @SerializedName("x")
        @Expose
        public int    x;
        @SerializedName("y")
        @Expose
        public int    y;
        @SerializedName("w")
        @Expose
        public int    w;
        @SerializedName("h")
        @Expose
        public int    h;

    }

    public class Canvas implements Serializable {

        @SerializedName("w")
        @Expose
        public int w;
        @SerializedName("h")
        @Expose
        public int h;

    }
}
