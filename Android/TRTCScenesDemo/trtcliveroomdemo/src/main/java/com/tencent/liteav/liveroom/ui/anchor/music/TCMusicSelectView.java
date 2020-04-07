package com.tencent.liteav.liveroom.ui.anchor.music;

import android.content.Context;
import android.telecom.Call;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.ui.widget.CustomTitle;

import java.util.List;

/**
 * Module:   TCMusicSelectView
 * <p>
 * Function: 音乐列表的选择界面
 */
public class TCMusicSelectView extends LinearLayout {
    private CustomTitle    TvTitle;
    private Context        mContext;
    public  MusicListView  mMusicList;
    public  Button         mBtnAutoSearch;
    private Callback mCallback;

    public TCMusicSelectView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        LayoutInflater.from(mContext).inflate(R.layout.liveroom_view_music_chose, this);
    }

    public TCMusicSelectView(Context context) {
        this(context, null);
    }

    public void init(Callback callback, List<MusicEntity> data) {
        mCallback = callback;
        mMusicList = (MusicListView) findViewById(R.id.music_list_view);
        mMusicList.setData(data);
        mBtnAutoSearch = (Button) findViewById(R.id.music_btn_search);
        TvTitle = (CustomTitle) findViewById(R.id.music_ac_title);
        TvTitle.setReturnListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCallback != null) {
                    mCallback.onBackBtnClick();
                }
            }
        });
    }

    public interface Callback {
        void onBackBtnClick();
    }
}
