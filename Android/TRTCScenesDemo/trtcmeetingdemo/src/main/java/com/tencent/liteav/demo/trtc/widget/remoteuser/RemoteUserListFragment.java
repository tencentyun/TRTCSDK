package com.tencent.liteav.demo.trtc.widget.remoteuser;

import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.View;

import com.tencent.liteav.demo.trtc.R;
import com.tencent.liteav.demo.trtc.sdkadapter.remoteuser.RemoteUserConfigHelper;
import com.tencent.liteav.demo.trtc.widget.BaseSettingFragment;

/**
 * 用户列表页
 *
 * @author guanyifeng
 */
public class RemoteUserListFragment extends BaseSettingFragment {
    private static final String TAG = RemoteUserListFragment.class.getName();

    private RecyclerView                            mUserListRv;
    private RemoteUserListAdapter                   mAdapter;
    private RemoteUserListAdapter.ClickItemListener mClickItemListener;

    @Override
    protected void initView(View view) {
        mUserListRv = (RecyclerView) view.findViewById(R.id.rv_user_list);
        mUserListRv.setLayoutManager(new LinearLayoutManager(getContext()));
        mAdapter = new RemoteUserListAdapter(getContext());
        if (mClickItemListener != null) {
            mAdapter.setClickItemListener(mClickItemListener);
        }
        mUserListRv.setAdapter(mAdapter);
    }

    @Override
    public void onResume() {
        super.onResume();
        mAdapter.setUserInfoList(RemoteUserConfigHelper.getInstance().getRemoteUserConfigList());
        Log.d(TAG, "onResume user list size: " + RemoteUserConfigHelper.getInstance().getRemoteUserConfigList().size());
    }

    public void setClickItemListener(RemoteUserListAdapter.ClickItemListener clickItemListener) {
        mClickItemListener = clickItemListener;
        if (mAdapter != null) {
            mAdapter.setClickItemListener(mClickItemListener);
        }
    }

    @Override
    protected int getLayoutId() {
        return R.layout.trtc_fragment_remote_user_list;
    }
}
