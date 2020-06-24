package com.tencent.liteav.liveroom.ui.common.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.Toast;

import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.common.utils.TCUtils;

import java.util.LinkedList;

/**
 * Module:   TCUserAvatarListAdapter
 * <p>
 * Function: 直播头像列表Adapter
 */
public class TCUserAvatarListAdapter extends RecyclerView.Adapter<TCUserAvatarListAdapter.AvatarViewHolder> {

    private final static int TOP_STORGE_MEMBER = 50; //最大容纳量

    private Context mContext;
    private String  mPusherId;//主播id
    private LinkedList<TRTCLiveRoomDef.TRTCLiveUserInfo> mUserAvatarList;

    public TCUserAvatarListAdapter(Context context, String pusherId) {
        this.mContext = context;
        this.mPusherId = pusherId;
        this.mUserAvatarList = new LinkedList<>();
    }

    /**
     * 添加用户信息
     *
     * @param userInfo 用户基本信息
     * @return 存在重复或头像为主播则返回false
     */
    public boolean addItem(TRTCLiveRoomDef.TRTCLiveUserInfo userInfo) {
        //去除主播头像
        if (userInfo.userId.equals(mPusherId))
            return false;

        //去重操作
        for (TRTCLiveRoomDef.TRTCLiveUserInfo tcSimpleUserInfo : mUserAvatarList) {
            if (tcSimpleUserInfo.userId.equals(userInfo.userId))
                return false;
        }

        //始终显示新加入item为第一位
        mUserAvatarList.add(0, userInfo);
        //超出时删除末尾项
        if (mUserAvatarList.size() > TOP_STORGE_MEMBER) {
            mUserAvatarList.remove(TOP_STORGE_MEMBER);
            notifyItemRemoved(TOP_STORGE_MEMBER);
        }
        notifyItemInserted(0);
        return true;
    }

    public void removeItem(String userId) {
        TRTCLiveRoomDef.TRTCLiveUserInfo tempUserInfo = null;

        for (TRTCLiveRoomDef.TRTCLiveUserInfo userInfo : mUserAvatarList)
            if (userInfo.userId.equals(userId))
                tempUserInfo = userInfo;


        if (null != tempUserInfo) {
            mUserAvatarList.remove(tempUserInfo);
            notifyDataSetChanged();
        }
    }

    @Override
    public AvatarViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext)
                .inflate(R.layout.trtcliveroom_item_user_avatar, parent, false);

        final AvatarViewHolder avatarViewHolder = new AvatarViewHolder(view);
        avatarViewHolder.ivAvatar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                TRTCLiveRoomDef.TRTCLiveUserInfo userInfo = mUserAvatarList.get(avatarViewHolder.getAdapterPosition());
                Toast.makeText(mContext.getApplicationContext(), mContext.getString(R.string.trtcliveroom_tap_current_user, userInfo.userId), Toast.LENGTH_SHORT).show();
            }
        });

        return avatarViewHolder;
    }

    @Override
    public void onBindViewHolder(AvatarViewHolder holder, int position) {
        TRTCLiveRoomDef.TRTCLiveUserInfo info = mUserAvatarList.get(position);
        if (info != null) {
            TCUtils.showPicWithUrl(mContext, holder.ivAvatar, info.userAvatar, R.drawable.trtcliveroom_bg_cover);
        }
    }

    @Override
    public int getItemCount() {
        return mUserAvatarList != null ? mUserAvatarList.size() : 0;
    }

    public static class AvatarViewHolder extends RecyclerView.ViewHolder {

        ImageView ivAvatar;

        public AvatarViewHolder(View itemView) {
            super(itemView);
            ivAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
        }
    }
}
