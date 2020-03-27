package com.tencent.liteav.liveroom.ui.anchor.music;

import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;

public class MusicEntity implements Parcelable {
    //id标识
    public int id;
    // 显示名称
    public String title;
    // 文件名称
    public String display_name;
    // 音乐文件的路径
    public String path;
    // 媒体播放总时间
    public int duration;
    // 专辑
    public String albums;
    // 艺术家
    public String artist;
    //歌手
    public String singer;
    public String durationStr;
    public long size;
    //0:idle 1:playing
    public char state = 0;
    public Uri fileUri;

    MusicEntity() {
    }

    protected MusicEntity(Parcel in) {
        id = in.readInt();
        title = in.readString();
        display_name = in.readString();
        path = in.readString();
        duration = in.readInt();
        albums = in.readString();
        artist = in.readString();
        singer = in.readString();
        durationStr = in.readString();
        size = in.readLong();
        state = (char) in.readInt();
        fileUri = in.readParcelable(Uri.class.getClassLoader());
    }

    public static final Creator<MusicEntity> CREATOR = new Creator<MusicEntity>() {
        @Override
        public MusicEntity createFromParcel(Parcel in) {
            return new MusicEntity(in);
        }

        @Override
        public MusicEntity[] newArray(int size) {
            return new MusicEntity[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(id);
        dest.writeString(title);
        dest.writeString(display_name);
        dest.writeString(path);
        dest.writeInt(duration);
        dest.writeString(albums);
        dest.writeString(artist);
        dest.writeString(singer);
        dest.writeString(durationStr);
        dest.writeLong(size);
        dest.writeInt(state);
        dest.writeParcelable(fileUri, flags);
    }

    @NonNull
    @Override
    public String toString() {
        return "MusicEntity{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", display_name='" + display_name + '\'' +
                ", path='" + path + '\'' +
                ", duration='" + duration + '\'' +
                ", albums=" + albums +
                ", artist=" + artist +
                ", singer=" + singer +
                ", durationStr=" + durationStr +
                ", size=" + size +
                ", state=" + state +
                ", fileUri=" + fileUri +
                '}';
    }
}