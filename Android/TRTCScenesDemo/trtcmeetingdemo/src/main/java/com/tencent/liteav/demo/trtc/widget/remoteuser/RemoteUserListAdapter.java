package com.tencent.liteav.demo.trtc.widget.remoteuser;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.RemoteUserConfig;

import java.util.List;

/**
 * @author guanyifeng
 */
public class RemoteUserListAdapter extends RecyclerView.Adapter<RemoteUserListAdapter.UserListViewHolder> {
    private LayoutInflater         mInflater;
    private ClickItemListener      mClickItemListener;
    private List<RemoteUserConfig> mUserInfoList;

    public RemoteUserListAdapter(Context context) {
        mInflater = LayoutInflater.from(context);
    }

    public void setClickItemListener(ClickItemListener clickItemListener) {
        mClickItemListener = clickItemListener;
    }

    @Override
    public UserListViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new UserListViewHolder(mInflater.inflate(R.layout.trtc_item_user_list, parent, false));
    }

    public void setUserInfoList(List<RemoteUserConfig> userInfoList) {
        mUserInfoList = userInfoList;
        notifyDataSetChanged();
    }

    @Override
    public void onBindViewHolder(UserListViewHolder holder, int position) {
        if (mUserInfoList == null) {
            return;
        }
        RemoteUserConfig userInfo = mUserInfoList.get(position);
        holder.bindData(userInfo);
    }

    @Override
    public int getItemCount() {
        return mUserInfoList == null ? 0 : mUserInfoList.size();
    }

    interface ClickItemListener {
        void onClickItem(RemoteUserConfig remoteUserConfig);
    }

    public class UserListViewHolder extends RecyclerView.ViewHolder {
        private TextView         mUserNameTv;
        private ImageView        mSparkIv;
        private ImageView        mVideoIv;
        private ImageView        mGoIv;
        private RemoteUserConfig mRemoteUserConfig;

        public UserListViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(@NonNull final View itemView) {
            mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
            mSparkIv = (ImageView) itemView.findViewById(R.id.iv_spark);
            mVideoIv = (ImageView) itemView.findViewById(R.id.iv_video);
            mGoIv = (ImageView) itemView.findViewById(R.id.iv_go);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mClickItemListener != null && mRemoteUserConfig != null) {
                        mClickItemListener.onClickItem(mRemoteUserConfig);
                    }
                }
            });
        }

        private void bindData(RemoteUserConfig userInfo) {
            if (userInfo == null) {
                return;
            }
            mRemoteUserConfig = userInfo;
            mGoIv.setVisibility(View.VISIBLE);
            mVideoIv.setImageResource(userInfo.isEnableVideo() ? R.drawable.remote_video_enable :
                    R.drawable.remote_video_disable);
            mSparkIv.setImageResource(userInfo.isEnableAudio() ? R.drawable.remote_audio_enable :
                    R.drawable.remote_audio_disable);
            mUserNameTv.setText(userInfo.getUserName());
        }
    }
}
