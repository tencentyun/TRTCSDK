package com.tencent.live;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.liteav.debug.Constant;

import java.util.List;

import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAnchor;
import static com.tencent.trtc.TRTCCloudDef.TRTCRoleAudience;

/**
 * 视频互动直播的入口页面
 *
 * 页面显示了当前正在直播的房间列表，以及“开始直播”的入口
 * 可以点击列表中的某个房间，以观众的身份进入房间，观看直播
 * 也可以点击“开始直播”，创建自己的直播房间，创建房间后，你的房间id会在房间列表上显示出来
 */
public class LiveRoomListActivity extends AppCompatActivity implements LiveRoomManager.RoomListListener {

    private ListView                        mRoomListView;        //【控件】显示房间列表
    private Button                          mStartLiveButton;     //【控件】开始直播
    private TextView                        mTextTip;             //【控件】没有直播间的提示
    private ImageView                       mBackButton;          //【控件】返回按钮
    private LiveRoomManager                 mLiveRoomManager;     // 房间管理
    private LiveRoomListAdapter             mLiveRoomListAdapter; // 房间列表填充器

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_room_list);
        initView();
        mLiveRoomManager = new LiveRoomManager();
        mLiveRoomManager.setRoomListListener(this);
    }

    private void initView() {
        getSupportActionBar().hide();
        mBackButton      = findViewById(R.id.room_list_ic_back);
        mRoomListView    = findViewById(R.id.lv_room_list);
        mStartLiveButton = findViewById(R.id.bt_enter_live);
        mTextTip         = findViewById(R.id.room_tip_null_list_textview);
        mStartLiveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mLiveRoomManager.createLiveRoom();
            }
        });
        mBackButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        mLiveRoomManager.queryLiveRoomList();
    }

    @Override
    public void onCreateRoomSuccess(String roomId) {
        Intent intent = new Intent(LiveRoomListActivity.this, LivePushActivity.class);
        intent.putExtra(Constant.ROOM_ID, String.valueOf(roomId));
        intent.putExtra(Constant.USER_ID, String.valueOf(roomId));
        intent.putExtra(Constant.ROLE_TYPE, TRTCRoleAnchor);
        startActivity(intent);
    }

    @Override
    public void onQueryRoomListSuccess(final List<String> list) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (list.size() == 0) {
                    mTextTip.setVisibility(View.VISIBLE);
                } else {
                    mTextTip.setVisibility(View.GONE);
                }
                mLiveRoomListAdapter = new LiveRoomListAdapter(LiveRoomListActivity.this, list);
                mRoomListView.setAdapter(mLiveRoomListAdapter);
                mRoomListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> adapterView, View view, int position, long l) {
                        Intent intent = new Intent(LiveRoomListActivity.this, LivePlayActivity.class);
                        intent.putExtra(Constant.ROOM_ID, list.get(position));
                        intent.putExtra(Constant.USER_ID, "user_" + System.currentTimeMillis());
                        intent.putExtra(Constant.ROLE_TYPE, TRTCRoleAudience);
                        startActivity(intent);
                    }
                });
            }
        });
    }

    @Override
    public void onDestoryRoomSuccess() {
    }

    @Override
    public void onError(final String errorInfo) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(LiveRoomListActivity.this, errorInfo, Toast.LENGTH_LONG).show();
            }
        });
    }

    class LiveRoomListAdapter extends BaseAdapter {

        private List<String> mRoomList;
        private Context mContext;

        public LiveRoomListAdapter(Context context, List<String> roomList) {
            mRoomList = roomList;
            mContext = context;
        }

        @Override
        public int getCount() {
            if (mRoomList == null) {
                return 0;
            }
            return mRoomList.size();
        }

        @Override
        public Object getItem(int position) {
            if (mRoomList == null) {
                return null;
            }
            return mRoomList.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder holder = null;
            if (convertView == null) {
                convertView = LayoutInflater.from(mContext).inflate(R.layout.live_room_item, parent, false);
                holder = new ViewHolder();
                holder.roomIdText = convertView.findViewById(R.id.tv_room_id);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            holder.roomIdText.setText("直播间ID：" + mRoomList.get(position));
            return convertView;
        }
    }

    static class ViewHolder {
        TextView roomIdText;
    }
}
