package com.tencent.liteav.meeting.ui.remote;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.meeting.ui.MemberEntity;

import java.util.List;

public class RemoteUserListView extends ConstraintLayout {
    private final Context mContext;

    private TextView               mTitleMain;
    private Toolbar                mToolbar;
    private TextView               mMuteAudioAllBtn;
    private TextView               mMuteVideoAllBtn;
    private TextView               mMuteAudioAllOffBtn;
    private RecyclerView           mUserListRv;
    private List<MemberEntity>     mMemberEntityList;
    private RemoteUserListAdapter  mRemoteUserListAdapter;
    private RemoteUserListCallback mRemoteUserListCallback;

    public RemoteUserListView(Context context) {
        this(context, null);
    }

    public RemoteUserListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        inflate(context, R.layout.view_meeting_remote_user_list, this);
        initView(this);
    }

    /**
     * 防止界面点击被透传
     */
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        super.onTouchEvent(event);
        return true;
    }

    private void initView(View itemView) {
        mTitleMain = (TextView) itemView.findViewById(R.id.main_title);
        mToolbar = (Toolbar) itemView.findViewById(R.id.toolbar);
        mMuteAudioAllBtn = (TextView) itemView.findViewById(R.id.btn_mute_audio_all);
        mMuteVideoAllBtn = (TextView) itemView.findViewById(R.id.btn_mute_video_all);
        mMuteAudioAllOffBtn = (TextView) itemView.findViewById(R.id.btn_mute_audio_all_off);
        mUserListRv = (RecyclerView) itemView.findViewById(R.id.rv_user_list);

        mToolbar.setNavigationOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onFinishClick();
                }
            }
        });
        mUserListRv.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false));
        mRemoteUserListAdapter = new RemoteUserListAdapter(mContext, new RemoteUserListAdapter.OnItemClickListener() {
            @Override
            public void onMuteAudioClick(int position) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onMuteAudioClick(position);
                }
            }

            @Override
            public void onMuteVideoClick(int position) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onMuteVideoClick(position);
                }
            }
        });
        mRemoteUserListAdapter.setMemberList(mMemberEntityList);
        mUserListRv.setAdapter(mRemoteUserListAdapter);
        mUserListRv.setHasFixedSize(true);

        mMuteAudioAllBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onMuteAllAudioClick();
                }
            }
        });

        mMuteAudioAllOffBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onMuteAllAudioOffClick();
                }
            }
        });

        mMuteVideoAllBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mRemoteUserListCallback != null) {
                    mRemoteUserListCallback.onMuteAllVideoClick();
                }
            }
        });
    }

    public void setRemoteUser(List<MemberEntity> memberEntityList) {
        mMemberEntityList = memberEntityList;
        if (mRemoteUserListAdapter != null) {
            mRemoteUserListAdapter.setMemberList(memberEntityList);
        }
    }

    public void notifyDataSetChanged() {
        if (mRemoteUserListAdapter != null) {
            mRemoteUserListAdapter.notifyDataSetChanged();
        }
    }

    public void setRemoteUserListCallback(RemoteUserListCallback remoteUserListCallback) {
        mRemoteUserListCallback = remoteUserListCallback;
    }

    public interface RemoteUserListCallback {
        void onFinishClick();

        void onMuteAllAudioClick();

        void onMuteAllAudioOffClick();

        void onMuteAllVideoClick();

        void onMuteAudioClick(int position);

        void onMuteVideoClick(int position);
    }
}
