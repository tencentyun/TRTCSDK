package com.tencent.liteav.trtcvoiceroom.ui.list;

import android.content.Context;
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
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoom;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomCallback;
import com.tencent.liteav.trtcvoiceroom.model.TRTCVoiceRoomDef;
import com.tencent.liteav.trtcvoiceroom.ui.room.VoiceRoomAnchorActivity;
import com.tencent.liteav.trtcvoiceroom.ui.room.VoiceRoomAudienceActivity;
import com.tencent.liteav.trtcvoiceroom.ui.widget.SpaceDecoration;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;


/**
 * Module:   VoiceRoomListFragment
 * <p>
 * Function: 直播列表页面，展示房间列表
 */
public class VoiceRoomListFragment extends Fragment implements SwipeRefreshLayout.OnRefreshListener {
    private static final String TAG = "VoiceRoomListFragment";

    private static final String ROOM_COVER_ARRAY [] = {
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover1.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover2.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover3.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover4.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover5.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover6.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover7.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover8.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover9.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover10.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover11.png",
            "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover12.png",
    };

    private RoomListAdapter    mRoomListViewAdapter;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private List<RoomEntity>   mRoomEntityList = new ArrayList<>();
    private String             mSelfUserId;
    private RecyclerView       mListRv;
    private TextView           mListviewEmptyTv;
    private View               mCreateRoomBtn;

    public static VoiceRoomListFragment newInstance() {
        Bundle                args     = new Bundle();
        VoiceRoomListFragment fragment = new VoiceRoomListFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.trtcvoiceroom_fragment_room_list, container, false);
        initView(view);
        getRoomList();
        return view;
    }

    private void initView(@NonNull final View itemView) {
        mListRv = (RecyclerView) itemView.findViewById(R.id.rv_list);
        mListviewEmptyTv = (TextView) itemView.findViewById(R.id.tv_listview_empty);
        mCreateRoomBtn = itemView.findViewById(R.id.container_create_room);
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
        mListRv.addItemDecoration(
                new SpaceDecoration(getResources().getDimensionPixelOffset(R.dimen.trtcvoiceroom_room_list_margin_top),
                        2));
        mListRv.setAdapter(mRoomListViewAdapter);
        mRoomListViewAdapter.notifyDataSetChanged();

        mSelfUserId = ProfileManager.getInstance().getUserModel().userId;
    }

    /**
     * 点击的就是之前自己创建的房间，重新创建
     */
    private void startEnterExistRoom(RoomEntity info) {
        ToastUtils.showShort(getString(R.string.trtcvoiceroom_toast_reentering));
        String roomName    = info.roomName;
        String userId      = ProfileManager.getInstance().getUserModel().userId;
        String userName    = ProfileManager.getInstance().getUserModel().userName;
        String coverUrl    = info.coverUrl;
        VoiceRoomAnchorActivity.createRoom(getActivity(), roomName, userId, userName, coverUrl, TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC, true);
    }

    private void createRoom() {
        int index = new Random().nextInt(ROOM_COVER_ARRAY.length);
        String coverUrl = ROOM_COVER_ARRAY[index];
        String userName    = ProfileManager.getInstance().getUserModel().userName;
        VoiceRoomCreateDialog dialog = new VoiceRoomCreateDialog(getActivity());
        dialog.showVoiceRoomCreateDialog(mSelfUserId, userName, coverUrl, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT, true);
    }

    private void refreshView() {
        mListviewEmptyTv.setVisibility(mRoomEntityList.size() == 0 ? View.VISIBLE : View.GONE);
        mListRv.setVisibility(mRoomEntityList.size() == 0 ? View.GONE : View.VISIBLE);
        mRoomListViewAdapter.notifyDataSetChanged();
    }

    private void enterRoom(RoomEntity info) {
        VoiceRoomAudienceActivity.enterRoom(getActivity(), Integer.valueOf(info.roomId), mSelfUserId, TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
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
        RoomManager.getInstance().getRoomList(TCConstants.TYPE_VOICE_ROOM, new RoomManager.GetRoomListCallback() {
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
                    TRTCVoiceRoom.sharedInstance(getActivity()).getRoomInfoList(roomList, new TRTCVoiceRoomCallback.RoomInfoCallback() {
                        @Override
                        public void onCallback(int code, String msg, List<TRTCVoiceRoomDef.RoomInfo> list) {
                            if (code == 0) {
                                mRoomEntityList.clear();
                                for (TRTCVoiceRoomDef.RoomInfo roomInfo : list) {
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
                                ToastUtils.showLong(getString(R.string.trtcvoiceroom_toast_obtain_list_failed, msg));
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
                ToastUtils.showShort(getString(R.string.trtcvoiceroom_toast_request_network_failure, msg));
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
            View           view     = inflater.inflate(R.layout.trtcvoiceroom_item_room_list, parent, false);
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
                    Picasso.get().load(model.coverUrl).placeholder(R.drawable.trtcvoiceroom_ic_cover).into(mAnchorCoverImg);
                } else {
                    mAnchorCoverImg.setImageResource(R.drawable.trtcvoiceroom_ic_cover);
                }
                mAnchorNameTv.setText(model.anchorName);
                mRoomNameTv.setText(model.roomName);
                mMembersLive.setText(context.getString(R.string.trtcvoiceroom_numer_format, model.audiencesNum));

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