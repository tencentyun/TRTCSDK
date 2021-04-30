package com.tencent.liteav.trtcchatsalon.ui.list;

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
import android.widget.ImageView;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.squareup.picasso.Picasso;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.model.RoomManager;
import com.tencent.liteav.trtcchatsalon.R;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalon;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonCallback;
import com.tencent.liteav.trtcchatsalon.model.TRTCChatSalonDef;
import com.tencent.liteav.trtcchatsalon.ui.room.ChatSalonAnchorActivity;
import com.tencent.liteav.trtcchatsalon.ui.room.ChatSalonAudienceActivity;
import com.tencent.liteav.trtcchatsalon.ui.widget.SpaceDecoration;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;


/**
 * Module:   VoiceRoomListFragment
 * <p>
 * Function: 直播列表页面，展示房间列表
 */
public class ChatSalonListFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG = "ChatSalonListFragment";


    private RoomListAdapter    mRoomListViewAdapter;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private List<RoomEntity>   mRoomEntityList = new ArrayList<>();
    private String             mSelfUserId;
    private RecyclerView       mListRv;
    private TextView           mListviewEmptyTv;
    private ImageView          mCreateRoomBtn;

    public static ChatSalonListFragment newInstance() {
        Bundle                args     = new Bundle();
        ChatSalonListFragment fragment = new ChatSalonListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.trtcchatsalon_fragment_room_list, container, false);
        initView(view);
        getRoomList();
        return view;
    }

    private void initView(@NonNull final View itemView) {
        mListRv = (RecyclerView) itemView.findViewById(R.id.rv_list);
        mListviewEmptyTv = (TextView) itemView.findViewById(R.id.tv_listview_empty);
        mCreateRoomBtn = (ImageView) itemView.findViewById(R.id.btn_create_room);
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
        mRoomListViewAdapter = new RoomListAdapter(getContext(), mRoomEntityList,
                new RoomListAdapter.OnItemClickListener() {
                    @Override
                    public void onItemClick(int position) {
                        RoomEntity info = mRoomEntityList
                                .get(position);
                        if (info.anchorId.equals(mSelfUserId)) {
                            startEnterExistRoom(info);
                        } else {
                            enterRoom(info);
                        }
                    }
                });
        mListRv.setLayoutManager(new GridLayoutManager(getContext(), 2));
        mListRv.setAdapter(mRoomListViewAdapter);
        mListRv.addItemDecoration(
                new SpaceDecoration(getResources().getDimensionPixelOffset(R.dimen.trtcchatsalon_large_image_left_margin),
                        2));
        mRoomListViewAdapter.notifyDataSetChanged();

        mSelfUserId = ProfileManager.getInstance().getUserModel().userId;
    }

    /**
     * 点击的就是之前自己创建的房间，重新创建
     */
    private void startEnterExistRoom(RoomEntity info) {
        ToastUtils.showShort(R.string.trtcchatsalon_enter_room_again);
        String roomName    = info.roomName;
        String userId      = ProfileManager.getInstance().getUserModel().userId;
        String userName    = ProfileManager.getInstance().getUserModel().userName;
        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
        String coverAvatar = ProfileManager.getInstance().getUserModel().userAvatar;
        ChatSalonAnchorActivity.createRoom(getActivity(), roomName, userId, userName, userAvatar, coverAvatar, TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC, true);
    }

    private void createRoom() {
        Intent intent = new Intent(getActivity(), ChatSalonCreateActivity.class);
        getActivity().startActivity(intent);
    }

    private void refreshView() {
        mListviewEmptyTv.setVisibility(mRoomEntityList.size() == 0 ? View.VISIBLE : View.GONE);
        mListRv.setVisibility(mRoomEntityList.size() == 0 ? View.GONE : View.VISIBLE);
        mRoomListViewAdapter.notifyDataSetChanged();
    }

    private void enterRoom(RoomEntity info) {
        ChatSalonAudienceActivity.enterRoom(getActivity(), Integer.valueOf(info.roomId), mSelfUserId, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
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
        RoomManager.getInstance().getRoomList(TCConstants.TYPE_CHAT_SALON, new RoomManager.GetRoomListCallback() {
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
                    TRTCChatSalon.sharedInstance(getActivity()).getRoomInfoList(roomList, new TRTCChatSalonCallback.RoomInfoCallback() {
                        @Override
                        public void onCallback(int code, String msg, List<TRTCChatSalonDef.RoomInfo> list) {
                            if (code == 0) {
                                mRoomEntityList.clear();
                                for (TRTCChatSalonDef.RoomInfo roomInfo : list) {
                                    RoomEntity entity = new RoomEntity();
                                    entity.anchorId = roomInfo.ownerId;
                                    entity.anchorName = roomInfo.ownerName;
                                    entity.coverUrl = roomInfo.coverUrl;
                                    entity.roomId = String.valueOf(roomInfo.roomId);
                                    entity.roomName = roomInfo.roomName;
                                    entity.audiencesNum = roomInfo.memberCount;
                                    mRoomEntityList.add(entity);
                                }
                                mRoomListViewAdapter.notifyDataSetChanged();
                            } else {
                                ToastUtils.showLong(getString(R.string.trtcchatsalon_get_component_failed) + ":" + msg);
                            }
                            mSwipeRefreshLayout.setRefreshing(false);
                            refreshView();
                        }
                    });
                } else {
                    mSwipeRefreshLayout.setRefreshing(false);
                    refreshView();
                    mRoomEntityList.clear();
                }
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showShort(getString(R.string.trtcchatsalon_network_failed) + msg);
                mSwipeRefreshLayout.setRefreshing(false);
                refreshView();
            }
        });
    }

    private static class RoomEntity {
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
        private List<RoomEntity>    list;
        private OnItemClickListener onItemClickListener;

        public RoomListAdapter(Context context, List<RoomEntity> list,
                               OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View           view     = inflater.inflate(R.layout.trtcchatsalon_item_room_list, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            RoomEntity item = list.get(position);
            holder.bind(item, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        public interface OnItemClickListener {
            void onItemClick(int position);
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private ImageView mAnchorCoverImg;
            private TextView  mAnchorNameTv;
            private TextView  mRoomNameTv;
            private TextView  mMembersLive;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            private void initView(@NonNull final View itemView) {
                mAnchorCoverImg = (ImageView) itemView.findViewById(R.id.img_anchor_cover);
                mAnchorNameTv = (TextView) itemView.findViewById(R.id.tv_anchor_name);
                mRoomNameTv = (TextView) itemView.findViewById(R.id.tv_room_name);
                mMembersLive = (TextView) itemView.findViewById(R.id.live_members);
            }

            public void bind(final RoomEntity model,
                             final OnItemClickListener listener) {
                if (model == null) {
                    return;
                }
                if (!TextUtils.isEmpty(model.coverUrl)) {
                    Picasso.get().load(model.coverUrl).placeholder(R.drawable.trtcchatsalon_ic_cover).into(mAnchorCoverImg);
                } else {
                    mAnchorCoverImg.setImageResource(R.drawable.trtcchatsalon_ic_cover);
                }
                mAnchorNameTv.setText(model.anchorName);
                mRoomNameTv.setText(model.roomName);
                mMembersLive.setText(context.getString(R.string.trtcchatsalon_numer_format, model.audiencesNum));
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }
        }
    }
}