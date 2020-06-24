package com.tencent.liteav.trtcvideocalldemo.ui.adapter;


import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.login.model.UserModel;
import com.tencent.liteav.trtcvideocalldemo.R;
import com.tencent.liteav.trtcvideocalldemo.ui.TRTCVideoCallSelectContactActivity;

import java.util.List;

public class SelectedContactAdapter extends RecyclerView.Adapter<SelectedContactAdapter.ViewHolder> {
    private static final String TAG = "SelectedContactAdapter";

    private Context mContext;
    private List<UserModel> mList;
    private TRTCVideoCallSelectContactActivity.OnItemClickListener onItemClickListener;

    public SelectedContactAdapter(Context context, List<UserModel> list,
                                  TRTCVideoCallSelectContactActivity.OnItemClickListener onItemClickListener) {
        this.mContext = context;
        this.mList = list;
        this.onItemClickListener = onItemClickListener;
    }

    @Override
    public SelectedContactAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.trtcvideocall_recycle_item_selected_contact, parent, false);
        return new SelectedContactAdapter.ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(SelectedContactAdapter.ViewHolder holder, int position) {
        UserModel item = mList.get(position);
        holder.bind(item, onItemClickListener);
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        private ImageView mAvatarImage;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final UserModel model,
                         final TRTCVideoCallSelectContactActivity.OnItemClickListener listener) {
            Picasso.get().load(model.userAvatar).into(mAvatarImage);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onItemClick(getLayoutPosition());
                }
            });
        }

        private void initView(@NonNull final View itemView) {
            mAvatarImage = (ImageView) itemView.findViewById(R.id.img_avatar);
        }
    }
}

