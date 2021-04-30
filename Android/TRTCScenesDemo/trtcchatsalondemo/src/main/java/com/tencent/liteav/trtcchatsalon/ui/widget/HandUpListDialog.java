package com.tencent.liteav.trtcchatsalon.ui.widget;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.ui.base.ChatSalonMemberEntity;

import java.util.ArrayList;
import java.util.List;

public class HandUpListDialog extends BottomSheetDialog {
    private Context            mContext;
    private RecyclerView       mRvList;
    private ListAdapter        mListAdapter;
    private onSelectedCallback mOnSelectedCallback;
    private TextView           mTitle;
    private List<ChatSalonMemberEntity> mMemberEntityList;

    public HandUpListDialog(@NonNull Context context) {
        super(context, R.style.TRTCChatSalonDialogTheme);
        setContentView(R.layout.trtcchatsalon_dialog_hand_up_list);
        initView(context);
    }

    public static int dp2px(Context context, float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, context.getResources().getDisplayMetrics());
    }

    private void initView(Context context) {
        mContext = context;
        mRvList = (RecyclerView) findViewById(R.id.rv_list);
        mTitle = (TextView) findViewById(R.id.title);
        if (mRvList != null) {
            mRvList.setLayoutManager(new LinearLayoutManager(mContext));
            mRvList.addItemDecoration(new SpaceDecoration(dp2px(mContext, 15),
                    1));
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    public void setOnSelectedCallback(onSelectedCallback onSelectedCallback) {
        mOnSelectedCallback = onSelectedCallback;
    }

    public void refreshView() {
        mTitle.setText(R.string.trtcchatsalon_loading);
    }

    public void notifyDataSetChanged() {
        if (mListAdapter != null) {
            mListAdapter.notifyDataSetChanged();
        }
    }

    public void setList(List<ChatSalonMemberEntity> userInfoList) {
        if (mListAdapter == null) {
            mMemberEntityList = userInfoList;
            mListAdapter = new ListAdapter(mContext, mMemberEntityList, new ListAdapter.OnItemClickListener() {
                @Override
                public void onItemClick(int position) {
                    if (mOnSelectedCallback == null) {
                        return;
                    }
                    mOnSelectedCallback.onSelected(mMemberEntityList.get(position));
                }
            });
            mRvList.setAdapter(mListAdapter);
        }
    }

    public interface onSelectedCallback {
        void onSelected(ChatSalonMemberEntity memberEntity);
    }

    public static class ListAdapter extends
            RecyclerView.Adapter<ListAdapter.ViewHolder> {
        private Context             context;
        private List<ChatSalonMemberEntity>  list;
        private OnItemClickListener onItemClickListener;

        public ListAdapter(Context context, List<ChatSalonMemberEntity> list,
                           OnItemClickListener onItemClickListener) {
            this.context = context;
            if (list == null) {
                list = new ArrayList<>();
            }
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);

            View view = inflater.inflate(R.layout.trtcchatsalon_item_hand_up, parent, false);

            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            ChatSalonMemberEntity item = list.get(position);
            holder.bind(item, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }


        public interface OnItemClickListener {
            void onItemClick(int position);
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            private TextView  mUserNameTv;
            private ImageButton mButtonInvite;
            private ImageView mImageAvatar;

            ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
                mButtonInvite = (ImageButton) itemView.findViewById(R.id.btn_invite_anchor);
                mImageAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            }

            public void bind(final ChatSalonMemberEntity model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }

                if (TextUtils.isEmpty(model.userName)) {
                    mUserNameTv.setText(model.userId);
                } else {
                    mUserNameTv.setText(model.userName);
                }

                if (!TextUtils.isEmpty(model.userAvatar)) {
                    Picasso.get().load(model.userAvatar).placeholder(R.drawable.trtcchatsalon_ic_cover).into(mImageAvatar);
                } else {
                    mImageAvatar.setImageResource(R.drawable.trtcchatsalon_ic_cover);
                }

                mButtonInvite.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }
        }
    }
}
