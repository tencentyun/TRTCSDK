package com.tencent.liteav.trtcchatsalon.ui.room;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.ui.base.ChatSalonMemberEntity;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class ChatSalonAudienceAdapter extends
        RecyclerView.Adapter<ChatSalonAudienceAdapter.ViewHolder> {
    private static final String TAG = ChatSalonAudienceAdapter.class.getSimpleName();

    private Context                                mContext;
    private List<ChatSalonMemberEntity>            mDataList;
    private OnItemClickListener                    mOnItemClickListener;
    private String                                 mEmptyText;
    private HashMap<String, ChatSalonMemberEntity> mChatSalonMap;

    public ChatSalonAudienceAdapter(Context context, List<ChatSalonMemberEntity> list,
                                    OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mDataList = list;
        this.mOnItemClickListener = onItemClickListener;
        mChatSalonMap = new HashMap<>();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);

        View view = inflater.inflate(R.layout.trtcchatsalon_item_audience_layout, parent, false);
        return new ViewHolder(view);
    }

    public void setEmptyText(String emptyText) {
        mEmptyText = emptyText;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        ChatSalonMemberEntity item = mDataList.get(position);
        holder.bind(mContext, item, mOnItemClickListener);
    }


    @Override
    public int getItemCount() {
        return mDataList.size();
    }

    public void addMember(ChatSalonMemberEntity entity) {
        if (entity == null) {
            return;
        }
        if (entity.userId == null) {
            return;
        }
        if (!mChatSalonMap.containsKey(entity.userId)) {
            mDataList.add(entity);
            mChatSalonMap.put(entity.userId, entity);
            notifyDataSetChanged();
        }
    }

    public void removeMember(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        ChatSalonMemberEntity localUserInfo = mChatSalonMap.get(userId);
        if (localUserInfo != null) {
            mDataList.remove(localUserInfo);
            mChatSalonMap.remove(userId);
            notifyDataSetChanged();
        }
    }

    public void addMembers(List<ChatSalonMemberEntity> list) {
        if (list != null) {
            for (ChatSalonMemberEntity entity : list) {
                addMember(entity);
            }
        }
        notifyDataSetChanged();
    }

    public HashMap<String, ChatSalonMemberEntity> getChatSalonMap() {
        return  mChatSalonMap;
    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public CircleImageView mImgHead;
        public TextView mTvName;
        public FrameLayout mFrameLayoutHeadImg;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final Context context,
                         final ChatSalonMemberEntity model,
                         final OnItemClickListener listener) {
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onItemClick(getLayoutPosition());

                }
            });
            if (!TextUtils.isEmpty(model.userAvatar)) {
                Picasso.get().load(model.userAvatar).into(mImgHead);
            } else {
                mImgHead.setImageResource(R.drawable.trtcchatsalon_ic_head);
            }
            if (!TextUtils.isEmpty(model.userName)) {
                mTvName.setText(model.userName);
            } else {
                mTvName.setText(R.string.trtcchatsalon_anchor_name_finding);
            }
        }

        private void initView(@NonNull final View itemView) {
            mImgHead = (CircleImageView) itemView.findViewById(R.id.img_head);
            mTvName = (TextView) itemView.findViewById(R.id.tv_name);
            mFrameLayoutHeadImg = (FrameLayout) itemView.findViewById(R.id.layout_img_head);
        }
    }
}