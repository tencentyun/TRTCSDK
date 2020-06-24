package com.tencent.liteav.trtcvoiceroom.ui.widget;

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
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.ui.base.MemberEntity;

import java.util.List;

/**
 * 用于选取邀请人
 *
 * @author guanyifeng
 */
public class SelectMemberView extends BottomSheetDialog {
    private Context            mContext;
    private RecyclerView       mPusherListRv;
    private ListAdapter        mListAdapter;
    private List<MemberEntity> mMemberEntityList;
    private onSelectedCallback mOnSelectedCallback;
    private TextView           mPusherTagTv;
    private TextView           mTextCancel;
    private int                mSeatIndex;

    public SelectMemberView(@NonNull Context context) {
        super(context);
        setContentView(R.layout.trtcvoiceroom_view_select);
        initView(context);
    }

    public static int dp2px(Context context, float dpVal) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                dpVal, context.getResources().getDisplayMetrics());
    }

    private void initView(Context context) {
        mContext = context;
        mPusherListRv = (RecyclerView) findViewById(R.id.rv_pusher_list);
        mPusherTagTv = (TextView) findViewById(R.id.tv_pusher_tag);
        mTextCancel = (TextView) findViewById(R.id.tv_cancel);
        if (mPusherListRv != null) {
            mPusherListRv.setLayoutManager(new LinearLayoutManager(mContext));
            mPusherListRv.addItemDecoration(new SpaceDecoration(dp2px(mContext, 15),
                    1));
        }
        mTextCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                if (mOnSelectedCallback != null) {
                    mOnSelectedCallback.onCancel();
                }
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    public void setOnSelectedCallback(onSelectedCallback onSelectedCallback) {
        mOnSelectedCallback = onSelectedCallback;
    }

    public void refreshView() {
        mPusherTagTv.setText("正在加载中...");
    }

    public void notifyDataSetChanged() {
        if (mListAdapter != null) {
            mListAdapter.notifyDataSetChanged();
        }
    }

    public void setSeatIndex(int seatIndex) {
        mSeatIndex = seatIndex;
    }

    public void setList(List<MemberEntity> userInfoList) {
        if (mListAdapter == null) {
            mMemberEntityList = userInfoList;
            mListAdapter = new ListAdapter(mContext, mMemberEntityList, new ListAdapter.OnItemClickListener() {
                @Override
                public void onItemClick(int position) {
                    if (mOnSelectedCallback == null) {
                        return;
                    }
                    mOnSelectedCallback.onSelected(mSeatIndex, mMemberEntityList.get(position));
                }
            });
            mPusherListRv.setAdapter(mListAdapter);
        }
    }

    public interface onSelectedCallback {
        void onSelected(int seatIndex, MemberEntity memberEntity);

        void onCancel();
    }

    public static class ListAdapter extends
            RecyclerView.Adapter<ListAdapter.ViewHolder> {
        private Context             context;
        private List<MemberEntity>  list;
        private OnItemClickListener onItemClickListener;

        public ListAdapter(Context context, List<MemberEntity> list,
                           OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);

            View view = inflater.inflate(R.layout.trtcvoiceroom_item_select, parent, false);

            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            MemberEntity item = list.get(position);
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
            private Button    mButtonInvite;
            private ImageView mImageAvatar;

            ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
                mButtonInvite = (Button) itemView.findViewById(R.id.btn_invite_anchor);
                mImageAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            }

            public void bind(final MemberEntity model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }
                if (model.type == MemberEntity.TYPE_IDEL) {
                    mButtonInvite.setVisibility(View.VISIBLE);
                    mButtonInvite.setText("邀请");
                    mButtonInvite.setBackgroundColor(context.getResources().getColor(R.color.trtcvoiceroom_color_text_blue));
                } else if (model.type == MemberEntity.TYPE_WAIT_AGREE) {
                    mButtonInvite.setVisibility(View.VISIBLE);
                    mButtonInvite.setText("同意");
                    mButtonInvite.setBackgroundColor(context.getResources().getColor(R.color.trtcvoiceroom_color_text_red));
                } else {
                    mButtonInvite.setVisibility(View.INVISIBLE);
                }
                if (TextUtils.isEmpty(model.userName)) {
                    mUserNameTv.setText(model.userId);
                } else {
                    mUserNameTv.setText(model.userName);
                }

                if (!TextUtils.isEmpty(model.userAvatar)) {
                    Picasso.get().load(model.userAvatar).placeholder(R.drawable.trtcvoiceroom_ic_cover).into(mImageAvatar);
                } else {
                    mImageAvatar.setImageResource(R.drawable.trtcvoiceroom_ic_cover);
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
