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
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomCallback;
import com.tencent.liteav.trtcvoiceroom.ui.base.MemberEntity;
import com.tencent.liteav.trtcvoiceroom.ui.base.VoiceRoomSeatEntity;

import java.util.List;

/**
 * 用于选取邀请人
 *
 * @author guanyifeng
 */
public class SelectMemberView extends BottomSheetDialog {
    private Context            mContext;
    private RecyclerView       mPusherListRv;
    private ImageView          mIvCloseSeat;
    private TextView           mTVCloseSeat;
    private ListAdapter        mListAdapter;
    private List<MemberEntity> mMemberEntityList;
    private onSelectedCallback mOnSelectedCallback;
    protected View             mCloseSeat;
    private int                mSeatIndex;

    public SelectMemberView(@NonNull Context context) {
        super(context, R.style.TRTCVoiceRoomDialogTheme);
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
        mIvCloseSeat = (ImageView) findViewById(R.id.iv_close_seat);
        mTVCloseSeat = (TextView) findViewById(R.id.tv_close_seat);
        mCloseSeat = findViewById(R.id.close_seat);

        if (mPusherListRv != null) {
            mPusherListRv.setLayoutManager(new LinearLayoutManager(mContext));
            mPusherListRv.addItemDecoration(new SpaceDecoration(dp2px(mContext, 15),
                    1));
        }
        mCloseSeat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnSelectedCallback != null) {
                    mOnSelectedCallback.onCloseButtonClick(mSeatIndex);
                }
                dismiss();
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

    public void notifyDataSetChanged() {
        if (mListAdapter != null) {
            mListAdapter.notifyDataSetChanged();
        }
    }

    public void setSeatIndex(int seatIndex) {
        mSeatIndex = seatIndex;
    }

    public int getSeatIndex() {
        return mSeatIndex;
    }

    public void updateCloseStatus(boolean isClose) {
        if (isClose) {
            mIvCloseSeat.setImageResource(R.drawable.trtcvoiceroom_open_seat);
            mTVCloseSeat.setText(mContext.getString(R.string.trtcvoiceroom_unlock));
        } else {
            mIvCloseSeat.setImageResource(R.drawable.trtcvoiceroom_close_seat);
            mTVCloseSeat.setText(mContext.getString(R.string.trtcvoiceroom_lock));
        }
    }

    public void setList(List<MemberEntity> userInfoList) {
        if (mListAdapter == null) {
            mMemberEntityList = userInfoList;
            mListAdapter = new ListAdapter(mContext, mMemberEntityList, new ListAdapter.OnItemClickListener() {
                @Override
                public void onItemClick(int position) {
                    if (mOnSelectedCallback != null) {
                        mOnSelectedCallback.onSelected(mSeatIndex, mMemberEntityList.get(position));
                    }
                    dismiss();
                }
            });
            mPusherListRv.setAdapter(mListAdapter);
        }
    }

    public interface onSelectedCallback {
        void onSelected(int seatIndex, MemberEntity memberEntity);
        void onCancel();
        void onCloseButtonClick(int seatIndex);
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
                    mButtonInvite.setText(context.getResources().getString(R.string.trtcvoiceroom_tv_invite));
                } else if (model.type == MemberEntity.TYPE_WAIT_AGREE) {
                    mButtonInvite.setVisibility(View.VISIBLE);
                    mButtonInvite.setText(R.string.trtcvoiceroom_agree);
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