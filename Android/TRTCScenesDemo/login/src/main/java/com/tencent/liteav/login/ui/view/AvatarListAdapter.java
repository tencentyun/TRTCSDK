package com.tencent.liteav.login.ui.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.login.R;

import java.util.List;
import de.hdodenhof.circleimageview.CircleImageView;

public class AvatarListAdapter extends
        RecyclerView.Adapter<AvatarListAdapter.ViewHolder> {
    private static final String TAG = AvatarListAdapter.class.getSimpleName();

    private Context                   mContext;
    private List<String>              mAvatarList;
    private OnItemClickListener       mOnItemClickListener;
    private int                       mSelectPosition = -1;

    public AvatarListAdapter(Context context, List<String> list, OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mAvatarList = list;
        this.mOnItemClickListener = onItemClickListener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context        context  = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.login_item_avatar_layout, parent, false);
        return new ViewHolder(view);
    }


    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        String item = mAvatarList.get(position);
        holder.bind(mContext, item, position, mOnItemClickListener);
    }


    @Override
    public int getItemCount() {
        return mAvatarList.size();
    }

    public interface OnItemClickListener {
        void onItemClick(String avatarUrl);
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public CircleImageView mImgHead;
        public ImageView mIvSelect;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final Context context,
                         final String userAvatar,
                         final int   position,
                         final OnItemClickListener listener) {
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onItemClick(userAvatar);
                    if (mSelectPosition != position) {
                        notifyDataSetChanged();
                        mSelectPosition = position;
                    }
                }
            });
            if (TextUtils.isEmpty(userAvatar)) {
                mImgHead.setImageResource(R.drawable.login_ic_head);
            } else {
                Picasso.get().load(userAvatar).into(mImgHead);
            }
            if (position == mSelectPosition) {
                mIvSelect.setVisibility(View.VISIBLE);
            } else {
                mIvSelect.setVisibility(View.GONE);
            }
        }

        private void initView(@NonNull final View itemView) {
            mImgHead = (CircleImageView) itemView.findViewById(R.id.img_head);
            mIvSelect = (ImageView) itemView.findViewById(R.id.iv_select);
        }
    }
}