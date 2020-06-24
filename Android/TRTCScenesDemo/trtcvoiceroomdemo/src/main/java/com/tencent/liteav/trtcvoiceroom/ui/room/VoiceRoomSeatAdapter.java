package com.tencent.liteav.trtcvoiceroom.ui.room;

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
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.ui.base.VoiceRoomSeatEntity;

import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class VoiceRoomSeatAdapter extends
        RecyclerView.Adapter<VoiceRoomSeatAdapter.ViewHolder> {
    private static final String TAG = VoiceRoomSeatAdapter.class.getSimpleName();

    private Context                   context;
    private List<VoiceRoomSeatEntity> list;
    private OnItemClickListener       onItemClickListener;
    private String                    mEmptyText;

    public VoiceRoomSeatAdapter(Context context, List<VoiceRoomSeatEntity> list,
                                OnItemClickListener onItemClickListener) {
        this.context = context;
        this.list = list;
        this.onItemClickListener = onItemClickListener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context        context  = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);

        View view = inflater.inflate(R.layout.trtcvoiceroom_item_seat_layout, parent, false);
        return new ViewHolder(view);
    }

    public void setEmptyText(String emptyText) {
        mEmptyText = emptyText;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        VoiceRoomSeatEntity item = list.get(position);
        holder.bind(context, item, onItemClickListener);
    }


    @Override
    public int getItemCount() {
        return list.size();
    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public CircleImageView mImgHead;
        public TextView        mTvName;
        public FrameLayout     mFrameLayoutHeadImg;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final Context context,
                         final VoiceRoomSeatEntity model,
                         final OnItemClickListener listener) {
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onItemClick(getLayoutPosition());

                }
            });
            if (model.isClose) {
                //close的界面
                mImgHead.setImageResource(R.drawable.trtcvoiceroom_ic_lock);
                mImgHead.setCircleBackgroundColor(context.getResources().getColor(R.color.trtcvoiceroom_circle));
                mTvName.setText("座位已锁定");
                mFrameLayoutHeadImg.setForeground(null);
                return;
            }
            if (!model.isUsed) {
                // 占位图片
                mImgHead.setImageResource(R.drawable.trtcvoiceroom_ic_head);
                mTvName.setText(mEmptyText);
                mTvName.setTextColor(context.getResources().getColor(R.color.trtcvoiceroom_text_color_disable));
            } else {
                if (!TextUtils.isEmpty(model.userAvatar)) {
                    Picasso.get().load(model.userAvatar).into(mImgHead);
                } else {
                    mImgHead.setImageResource(R.drawable.trtcvoiceroom_ic_head);
                }
                if (!TextUtils.isEmpty(model.userName)) {
                    mTvName.setText(model.userName);
                } else {
                    mTvName.setText("主播名还在查找");
                }
            }
            if (model.isMute) {
                mFrameLayoutHeadImg.setForeground(context.getResources().getDrawable(R.drawable.trtcvoiceroom_ic_head_mute));
            } else {
                mFrameLayoutHeadImg.setForeground(null);
            }
        }

        private void initView(@NonNull final View itemView) {
            mImgHead = (CircleImageView) itemView.findViewById(R.id.img_head);
            mTvName = (TextView) itemView.findViewById(R.id.tv_name);
            mFrameLayoutHeadImg = (FrameLayout) itemView.findViewById(R.id.layout_img_head);
        }
    }
}