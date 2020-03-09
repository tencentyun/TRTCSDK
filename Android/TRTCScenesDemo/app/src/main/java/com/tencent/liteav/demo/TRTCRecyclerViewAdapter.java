package com.tencent.liteav.demo;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.List;

public class TRTCRecyclerViewAdapter extends
        RecyclerView.Adapter<TRTCRecyclerViewAdapter.ViewHolder> {

    private static final String TAG = TRTCRecyclerViewAdapter.class.getSimpleName();

    private Context              context;
    private List<TRTCItemEntity> list;
    private OnItemClickListener  onItemClickListener;

    public TRTCRecyclerViewAdapter(Context context, List<TRTCItemEntity> list,
                                   OnItemClickListener onItemClickListener) {
        this.context = context;
        this.list = list;
        this.onItemClickListener = onItemClickListener;
    }


    public static class ViewHolder extends RecyclerView.ViewHolder {
        private ImageView        mItemImg;
        private TextView         mTitleTv;
        private TextView         mContentTv;
        private ConstraintLayout mClItem;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        public void bind(final TRTCItemEntity model,
                         final OnItemClickListener listener) {
            mItemImg.setImageResource(model.mIconId);
            mTitleTv.setText(model.mTitle);
            mContentTv.setText(model.mContent);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onItemClick(getLayoutPosition());
                }
            });
        }

        private void initView(@NonNull final View itemView) {
            mItemImg = (ImageView) itemView.findViewById(R.id.img_item);
            mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
            mContentTv = (TextView) itemView.findViewById(R.id.tv_content);
            mClItem = (ConstraintLayout) itemView.findViewById(R.id.item_cl);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context        context  = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);

        View view = inflater.inflate(R.layout.module_entry_item, parent, false);

        ViewHolder viewHolder = new ViewHolder(view);

        return viewHolder;
    }


    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        TRTCItemEntity item = list.get(position);
        holder.bind(item, onItemClickListener);
    }

    @Override
    public int getItemCount() {
        return list.size();
    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

}