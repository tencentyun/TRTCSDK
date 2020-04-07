package com.tencent.liteav.liveroom.ui.liveroomlist;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomCallback;
import com.tencent.liteav.liveroom.model.TRTCLiveRoomDef;
import com.tencent.liteav.liveroom.ui.anchor.TCCameraAnchorActivity;
import com.tencent.liteav.liveroom.ui.audience.TCAudienceActivity;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.liveroom.ui.widget.RoundImageView;
import com.tencent.liteav.liveroom.ui.widget.SpaceDecoration;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.RoomManager;

import java.util.ArrayList;
import java.util.List;


/**
 * Module:   LiveRoomListFragment
 * <p>
 * Function: 直播列表页面，展示房间列表
 */
public class LiveRoomListFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG = "LiveRoomListFragment";


    private RoomListAdapter    mRoomListViewAdapter;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private List<RoomInfo>     mRoomInfoList = new ArrayList<>();
    private String             mSelfUserId;
    private RecyclerView       mListRv;
    private TextView           mListviewEmptyTv;
    private Button             mCreateRoomBtn;
    private boolean            isUseCdnPlay  = false;

    public static LiveRoomListFragment newInstance() {
        Bundle               args     = new Bundle();
        LiveRoomListFragment fragment = new LiveRoomListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.liveroom_fragment_room_list, container, false);
        initView(view);
        getRoomList();
        return view;
    }

    private void initView(@NonNull final View itemView) {
        mListRv = (RecyclerView) itemView.findViewById(R.id.rv_list);
        mListviewEmptyTv = (TextView) itemView.findViewById(R.id.tv_listview_empty);
        mCreateRoomBtn = (Button) itemView.findViewById(R.id.btn_create_room);
        mCreateRoomBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createRoom();
            }
        });
        mSwipeRefreshLayout = (SwipeRefreshLayout) itemView.findViewById(R.id.swipe_refresh_layout_list);
        mSwipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light, android.R.color.holo_orange_light, android.R.color.holo_red_light);
        mSwipeRefreshLayout.setOnRefreshListener(this);
        mRoomListViewAdapter = new RoomListAdapter(getContext(), mRoomInfoList,
                new RoomListAdapter.OnItemClickListener() {
                    @Override
                    public void onItemClick(int position) {
                        RoomInfo info = mRoomInfoList
                                .get(position);
                        if (info.anchorId.equals(mSelfUserId)) {
                            createRoom();
                        } else {
                            enterRoom(info);
                        }
                    }
                });
        mListRv.setLayoutManager(new GridLayoutManager(getContext(), 2));
        mListRv.setAdapter(mRoomListViewAdapter);
        mListRv.addItemDecoration(
                new SpaceDecoration(getResources().getDimensionPixelOffset(R.dimen.large_image_left_margin),
                        2));
        mRoomListViewAdapter.notifyDataSetChanged();

        mSelfUserId = ProfileManager.getInstance().getUserModel().userId;
        isUseCdnPlay = SPUtils.getInstance().getBoolean(TCConstants.USE_CDN_PLAY, false);
    }

    private void createRoom() {
        Intent intent = new Intent(getContext(), TCCameraAnchorActivity.class);
        startActivity(intent);
    }

    private void refreshView() {
        mListviewEmptyTv.setVisibility(mRoomInfoList.size() == 0 ? View.VISIBLE : View.GONE);
        mListRv.setVisibility(mRoomInfoList.size() == 0 ? View.GONE : View.VISIBLE);
        mRoomListViewAdapter.notifyDataSetChanged();
    }

    private void enterRoom(RoomInfo info) {
        Intent intent = new Intent(getActivity(), TCAudienceActivity.class);
        intent.putExtra(TCConstants.ROOM_TITLE, info.roomName);
        intent.putExtra(TCConstants.GROUP_ID, Integer.valueOf(info.roomId));
        intent.putExtra(TCConstants.USE_CDN_PLAY, isUseCdnPlay);
        intent.putExtra(TCConstants.PUSHER_ID, info.anchorId);
        intent.putExtra(TCConstants.PUSHER_NAME, info.anchorName);
        intent.putExtra(TCConstants.COVER_PIC, info.coverUrl);
        intent.putExtra(TCConstants.PUSHER_AVATAR, info.coverUrl);
        startActivity(intent);
    }

    @Override
    public void onRefresh() {
        getRoomList();
    }

    /**
     * 刷新直播列表
     */
    private void getRoomList() {
        mSwipeRefreshLayout.setRefreshing(true);
        // 首先从后台获取 房间列表的id
        RoomManager.getInstance().getRoomList(TCConstants.TYPE_LIVE_ROOM, new RoomManager.GetRoomListCallback() {
            @Override
            public void onSuccess(final List<String> roomIdList) {
                if (!CollectionUtils.isEmpty(roomIdList)) {
                    // 从组件出获取房间信息
                    List<Integer> roomList = new ArrayList<>();
                    for (String id : roomIdList) {
                        try {
                            roomList.add(Integer.parseInt(id));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    TRTCLiveRoom.sharedInstance(getContext()).getRoomInfos(roomList, new TRTCLiveRoomCallback.RoomInfoCallback() {
                        @Override
                        public void onCallback(int code, String msg, List<TRTCLiveRoomDef.TRTCLiveRoomInfo> list) {
                            if (code == 0) {
                                mRoomInfoList.clear();
                                for (TRTCLiveRoomDef.TRTCLiveRoomInfo trtcLiveRoomInfo : list) {
                                    RoomInfo info = new RoomInfo();
                                    info.anchorId = trtcLiveRoomInfo.ownerId;
                                    info.anchorName = trtcLiveRoomInfo.ownerName;
                                    info.roomName = trtcLiveRoomInfo.roomName;
                                    info.roomId = String.valueOf(trtcLiveRoomInfo.roomId);
                                    info.coverUrl = trtcLiveRoomInfo.coverUrl;
                                    info.audiencesNum = trtcLiveRoomInfo.memberCount;
                                    mRoomInfoList.add(info);
                                }
                                refreshView();
                            }
                        }
                    });
                } else {
                    mRoomInfoList.clear();
                }
                mSwipeRefreshLayout.setRefreshing(false);
                refreshView();
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showShort("请求网络失败 " + msg);
                mSwipeRefreshLayout.setRefreshing(false);
                refreshView();
            }
        });
    }

    private static class RoomInfo {
        public String roomName;
        public String roomId;
        public String anchorName;
        public String coverUrl;
        public int    audiencesNum;
        public String anchorId;
    }

    /**
     * 用于展示房间列表的item
     */
    public static class RoomListAdapter extends
            RecyclerView.Adapter<RoomListAdapter.ViewHolder> {

        private static final String TAG = RoomListAdapter.class.getSimpleName();

        private Context             context;
        private List<RoomInfo>      list;
        private OnItemClickListener onItemClickListener;

        public RoomListAdapter(Context context, List<RoomInfo> list,
                               OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }


        public static class ViewHolder extends RecyclerView.ViewHolder {
            private RoundImageView mAnchorCoverImg;
            private TextView       mAnchorNameTv;
            private TextView       mRoomNameTv;
            private TextView       mMembersLive;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mAnchorCoverImg = (RoundImageView) itemView.findViewById(R.id.img_anchor_cover);
                mAnchorNameTv = (TextView) itemView.findViewById(R.id.tv_anchor_name);
                mRoomNameTv = (TextView) itemView.findViewById(R.id.tv_room_name);
                mMembersLive = (TextView) itemView.findViewById(R.id.live_members);
            }

            public void bind(final RoomInfo model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }
                if (!TextUtils.isEmpty(model.coverUrl)) {
                    Picasso.get().load(model.coverUrl).placeholder(R.drawable.bg_cover).into(mAnchorCoverImg);
                }
                mAnchorNameTv.setText(model.anchorName);
                mRoomNameTv.setText(model.roomName);
                mMembersLive.setText(String.valueOf(model.audiencesNum));
                itemView.setOnClickListener(new View.OnClickListener() {
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
            View           view     = inflater.inflate(R.layout.liveroom_item_room_list, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            RoomInfo item = list.get(position);
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