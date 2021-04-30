package com.tencent.liteav.liveroom.ui.anchor;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.liveroom.ui.liveroomlist.LiveRoomListFragment;
import com.tencent.liteav.liveroom.ui.widget.SpaceDecoration;
import com.tencent.liteav.login.model.RoomManager;

import java.util.ArrayList;
import java.util.List;

public class AnchorPKSelectView extends RelativeLayout {
    private Context                                mContext;
    private RecyclerView                           mPusherListRv;
    private List<TRTCLiveRoomDef.TRTCLiveRoomInfo> mRoomInfos;
    private RoomListAdapter                        mRoomListAdapter;
    private onPKSelectedCallback                   mOnPKSelectedCallback;
    private TextView                               mPusherTagTv;
    private TextView                               mTextCancel;
    private int                                    mSelfRoomId;

    public AnchorPKSelectView(Context context) {
        this(context, null);
    }

    public AnchorPKSelectView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, widthMeasureSpec);
    }

    private void initView(Context context) {
        mContext = context;
        inflate(context, R.layout.trtcliveroom_view_pk_select, this);
        mPusherListRv = (RecyclerView) findViewById(R.id.rv_anchor_list);
        mRoomInfos = new ArrayList<>();
        mRoomListAdapter = new RoomListAdapter(mContext, mRoomInfos, new RoomListAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (mRoomInfos == null || mOnPKSelectedCallback == null) {
                    return;
                }
                mOnPKSelectedCallback.onSelected(mRoomInfos.get(position));
            }
        });
        mPusherListRv.setLayoutManager(new LinearLayoutManager(mContext));
        mPusherListRv.addItemDecoration(new SpaceDecoration(getResources().getDimensionPixelOffset(R.dimen.trtcliveroom_space_select_pk_rv),
                1));
        mPusherListRv.setAdapter(mRoomListAdapter);

        mPusherTagTv = (TextView) findViewById(R.id.tv_pusher_tag);

        mTextCancel = (TextView) findViewById(R.id.tv_cancel);
        mTextCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                setVisibility(GONE);
                mOnPKSelectedCallback.onCancel();
            }
        });
    }

    public void setSelfRoomId(int roomId) {
        mSelfRoomId = roomId;
    }

    public void setOnPKSelectedCallback(onPKSelectedCallback onPKSelectedCallback) {
        mOnPKSelectedCallback = onPKSelectedCallback;
    }

    public void refreshView() {
        mPusherTagTv.setText(getResources().getString(R.string.trtcliveroom_loading));
        RoomManager.getInstance().getRoomList(TCConstants.TYPE_LIVE_ROOM, new RoomManager.GetRoomListCallback() {
            @Override
            public void onSuccess(List<String> roomIdList) {
                List<Integer> roomList = new ArrayList<>();
                for (String id : roomIdList) {
                    try {
                        roomList.add(Integer.parseInt(id));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                TRTCLiveRoom.sharedInstance(mContext).getRoomInfos(roomList, new TRTCLiveRoomCallback.RoomInfoCallback() {
                    @Override
                    public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list) {
                        if (code == 0) {
                            mRoomInfos.clear();
                            for (TRTCLiveRoomDef.TRTCLiveRoomInfo info : list) {
                                //过滤哪些没有 userId 的房间（主播不在线）
                                if (info.roomId == mSelfRoomId || TextUtils.isEmpty(info.ownerId)) {
                                    continue;
                                }
                                mRoomInfos.add(info);
                            }
                            if (CollectionUtils.isEmpty(mRoomInfos)) {
                                mPusherTagTv.setText(getResources().getString(R.string.trtcliveroom_no_anchor_for_pk));
                            } else {
                                mPusherTagTv.setText(getResources().getString(R.string.trtcliveroom_title_pk_request));
                            }
                            mRoomListAdapter.notifyDataSetChanged();
                        }
                    }
                });
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showShort(getResources().getString(R.string.trtcliveroom_get_anchor_list_fail));
            }
        });
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (visibility == VISIBLE) {
            refreshView();
        }
    }

    public interface onPKSelectedCallback {
        void onSelected(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo);

        void onCancel();
    }

    public static class RoomListAdapter extends
            RecyclerView.Adapter<RoomListAdapter.ViewHolder> {

        private static final String TAG = LiveRoomListFragment.RoomListAdapter.class.getSimpleName();

        private Context                                context;
        private List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list;
        private OnItemClickListener                    onItemClickListener;

        public RoomListAdapter(Context context, List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list,
                               OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }


        static class ViewHolder extends RecyclerView.ViewHolder {
            private TextView mUserNameTv;
            private TextView mRoomNameTv;
            private Button   mButtonInvite;
            private ImageView mImageAvatar;

            ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
                mRoomNameTv = (TextView) itemView.findViewById(R.id.tv_room_name);
                mButtonInvite = (Button) itemView.findViewById(R.id.btn_invite_anchor);
                mImageAvatar = (ImageView) itemView.findViewById(R.id.iv_avatar);
            }

            public void bind(final TRTCLiveRoomDef.TRTCLiveRoomInfo model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }
                if (!TextUtils.isEmpty(model.roomName)) {
                    mRoomNameTv.setText(model.roomName);
                }
                if (TextUtils.isEmpty(model.ownerName)) {
                    mUserNameTv.setText(model.ownerId);
                } else {
                    mUserNameTv.setText(model.ownerName);
                }

                if (!TextUtils.isEmpty(model.coverUrl)) {
                    Picasso.get().load(model.coverUrl).placeholder(R.drawable.trtcliveroom_bg_cover).into(mImageAvatar);
                }

                mButtonInvite.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);

            View view = inflater.inflate(R.layout.trtcliveroom_item_select_pusher, parent, false);

            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            TRTCLiveRoomDef.TRTCLiveRoomInfo item = list.get(position);
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
}
