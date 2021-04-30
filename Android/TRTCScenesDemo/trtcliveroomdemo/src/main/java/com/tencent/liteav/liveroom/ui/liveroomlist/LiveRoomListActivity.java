package com.tencent.liteav.liveroom.ui.liveroomlist;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.ui.common.utils.StateBarUtils;
import com.tencent.liteav.liveroom.ui.common.utils.TCConstants;
import com.tencent.liteav.login.model.RoomManager;


/**
 * 用于显示直播间列表的activity
 *
 * @author guanyifeng
 */
public class LiveRoomListActivity extends AppCompatActivity {
    private static final String TAG = LiveRoomListActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        RoomManager.getInstance().initSdkAppId(GenerateTestUserSig.SDKAPPID);
        setContentView(R.layout.trtcliveroom_activity_room_list);
        StateBarUtils.initStatusBar(this);
        initNavigationBack();
        initTitleEvent();
        initNavigationMenu();
        initLiveRoomListFragment();
        requestPermission();
    }

    private void initNavigationBack() {
        findViewById(R.id.liveroom_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
    }

    private void initTitleEvent() {
        findViewById(R.id.liveroom_title_textview).setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                switchCDNPlayMode();
                return false;
            }
        });
    }

    private void initNavigationMenu() {
        findViewById(R.id.liveroom_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(TCConstants.TRTC_LIVE_ROOM_DOCUMENT_URL));
                startActivity(intent);
            }
        });

        boolean useCDNFirst = SPUtils.getInstance().getBoolean(TCConstants.USE_CDN_PLAY, false);
        if (useCDNFirst) {
            findViewById(R.id.tv_cdn_tag).setVisibility(View.VISIBLE);
        }
    }

    private void initLiveRoomListFragment() {
        Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);
        if (!(fragment instanceof LiveRoomListFragment)) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            fragment = LiveRoomListFragment.newInstance();
            ft.replace(R.id.fragment_container, fragment);
            ft.commit();
        }
    }

    private void switchCDNPlayMode() {
        final boolean useCDNFirst = SPUtils.getInstance().getBoolean(TCConstants.USE_CDN_PLAY, false);
        int targetResId = useCDNFirst ? R.string.trtcliveroom_switch_trtc_mode : R.string.trtcliveroom_switch_cdn_mode;
        new AlertDialog.Builder(this)
                .setMessage(targetResId)
                .setPositiveButton(R.string.trtcliveroom_ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        boolean switchMode = !useCDNFirst;
                        SPUtils.getInstance().put(TCConstants.USE_CDN_PLAY, switchMode);
                        ToastUtils.showLong(R.string.trtcliveroom_warning_switched_mode);
                    }
                })
                .setNegativeButton(R.string.trtcliveroom_cancle, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                .create()
                .show();
    }

    private void requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }
}
