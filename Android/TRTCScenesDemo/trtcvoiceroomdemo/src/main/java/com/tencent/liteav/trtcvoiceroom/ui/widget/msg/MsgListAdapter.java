package com.tencent.liteav.trtcvoiceroom.ui.widget.msg;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.tencent.liteav.trtcvoiceroom.R;

import java.util.List;

public class MsgListAdapter extends
        RecyclerView.Adapter<MsgListAdapter.ViewHolder> {

    private static final String TAG = MsgListAdapter.class.getSimpleName();

    private Context             context;
    private List<MsgEntity>     mList;
    private OnItemClickListener mOnItemClickListener;

    public MsgListAdapter(Context context, List<MsgEntity> list,
                          OnItemClickListener onItemClickListener) {
        this.context = context;
        this.mList = list;
        this.mOnItemClickListener = onItemClickListener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context        context    = parent.getContext();
        LayoutInflater inflater   = LayoutInflater.from(context);
        View           view       = inflater.inflate(R.layout.trtcvoiceroom_item_msg, parent, false);
        ViewHolder     viewHolder = new ViewHolder(view);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        MsgEntity item = mList.get(position);
        holder.bind(item, mOnItemClickListener);
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    public interface OnItemClickListener {
        void onAgreeClick(int position);
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        private TextView mTvMsgContent;
        private TextView mBtnMsgAgree;

        public ViewHolder(View itemView) {
            super(itemView);
            initView(itemView);
        }

        private void initView(View itemView) {
            mTvMsgContent = (TextView) itemView.findViewById(R.id.tv_msg_content);
            mBtnMsgAgree = (TextView) itemView.findViewById(R.id.btn_msg_agree);
        }

        public void bind(final MsgEntity model,
                         final OnItemClickListener listener) {
            String userName = !TextUtils.isEmpty(model.userName) ? model.userName : model.userId;
            if (!TextUtils.isEmpty(userName)) {
                mTvMsgContent.setText(userName + ":" + model.content);
            } else {
                mTvMsgContent.setText(model.content);
            }
            if (model.type == MsgEntity.TYPE_AGREED) {
                mBtnMsgAgree.setVisibility(View.GONE);
                mBtnMsgAgree.setEnabled(false);
            } else if (model.type == MsgEntity.TYPE_WAIT_AGREE) {
                mBtnMsgAgree.setVisibility(View.VISIBLE);
                mBtnMsgAgree.setText(R.string.trtcvoiceroom_agree);
                mBtnMsgAgree.setEnabled(true);
            } else {
                mBtnMsgAgree.setVisibility(View.GONE);
            }
            mBtnMsgAgree.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (listener != null) {
                        listener.onAgreeClick(getLayoutPosition());
                    }
                }
            });
        }
    }

}