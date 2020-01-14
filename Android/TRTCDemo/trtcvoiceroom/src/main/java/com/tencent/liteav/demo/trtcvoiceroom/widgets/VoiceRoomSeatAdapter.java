package com.tencent.liteav.demo.trtcvoiceroom.widgets;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.liteav.demo.trtcvoiceroom.R;
import com.tencent.liteav.demo.trtcvoiceroom.Utils;

import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class VoiceRoomSeatAdapter extends
        RecyclerView.Adapter<VoiceRoomSeatAdapter.ViewHolder> {
    private static final String TAG = VoiceRoomSeatAdapter.class.getSimpleName();

    private Context                   context;
    private List<VoiceRoomSeatEntity> list;
    private OnItemClickListener       onItemClickListener;

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

        View view = inflater.inflate(R.layout.voiceroom_item_seat_layout, parent, false);
        return new ViewHolder(view);
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

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public CircleImageView mHeadImg;
        public TextView        mNameTv;
        public String          mOldUserId = "";

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
            if (model.isPlaceHolder) {
                // 占位图片
                mHeadImg.setImageResource(R.drawable.wait_background);
                mNameTv.setText("虚位以待");
                mNameTv.setTextColor(context.getResources().getColor(R.color.colorWaitText));
                mOldUserId = "";
            } else {
                if (!mOldUserId.equals(model.userName)) {
                    mHeadImg.setImageBitmap(Utils.getAvatar(model.userName));
                    mNameTv.setText(model.userName);
                    mNameTv.setTextColor(context.getResources().getColor(R.color.white));
                }
                mOldUserId = model.userName;
                boolean isTalk = model.isTalk;
                if (isTalk) {
                    mHeadImg.setBorderColor(context.getResources().getColor(R.color.colorUserTalk));
                } else {
                    mHeadImg.setBorderColor(context.getResources().getColor(R.color.colorUserMute));
                }
            }
        }

        private void initView(@NonNull final View itemView) {
            mHeadImg = (CircleImageView) itemView.findViewById(R.id.img_head);
            mNameTv = (TextView) itemView.findViewById(R.id.tv_name);
        }
    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }
}