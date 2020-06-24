package com.tencent.liteav.trtcvoiceroom.ui.list;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.View;
import android.widget.ScrollView;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.tencent.liteav.debug.GenerateTestUserSig;
import com.tencent.liteav.login.model.RoomManager;
import com.tencent.liteav.trtcvoiceroom.R;

import java.text.SimpleDateFormat;
import java.util.Date;


/**
 * 用于显示列表页的activity
 *
 * @author guanyifeng
 */
public class VoiceRoomListActivity extends AppCompatActivity {

    private static final String TAG = VoiceRoomListActivity.class.getSimpleName();

    public final Handler uiHandler = new Handler();

    private TextView   titleTextView;
    private TextView   globalLogTextview;
    private ScrollView globalLogTextviewContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trtcvoiceroom_activity_room_list);

        findViewById(R.id.liveroom_back_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        titleTextView = ((TextView) findViewById(R.id.liveroom_title_textview));

        globalLogTextview = ((TextView) findViewById(R.id.videoroom_global_log_textview));
        globalLogTextview.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                new AlertDialog.Builder(VoiceRoomListActivity.this, R.style.TRTCVoiceRoomDialogTheme)
                        .setTitle("Global Log")
                        .setMessage("清除Log")
                        .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).setPositiveButton("清除", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        globalLogTextview.setText("");
                        dialog.dismiss();
                    }
                }).show();

                return true;
            }
        });
        findViewById(R.id.liveroom_link_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/document/product/647/35428"));
                startActivity(intent);
            }
        });

        globalLogTextviewContainer = ((ScrollView) findViewById(R.id.videoroom_global_log_container));
        initPermission();
        initializeLiveRoom();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        return super.onCreateOptionsMenu(menu);
    }

    private void initializeLiveRoom() {
        setTitle("语音聊天室");
        RoomManager.getInstance().initSdkAppId(GenerateTestUserSig.SDKAPPID);
        showFragment();
    }

    private void showFragment() {
        Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);
        if (!(fragment instanceof VoiceRoomListFragment)) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            fragment = VoiceRoomListFragment.newInstance();
            ft.replace(R.id.fragment_container, fragment);
            ft.commit();
        }
    }

    public void showGlobalLog(final boolean enable) {
        if (uiHandler != null)
            uiHandler.post(new Runnable() {
                @Override
                public void run() {
                    globalLogTextviewContainer.setVisibility(enable ? View.VISIBLE : View.GONE);
                }
            });
    }

    public void printGlobalLog(final String format, final Object... args) {
        if (uiHandler != null) {
            uiHandler.post(new Runnable() {
                @Override
                public void run() {
                    SimpleDateFormat dataFormat = new SimpleDateFormat("HH:mm:ss");
                    String           line       = String.format("[%s] %s\n", dataFormat.format(new Date()), String.format(format, args));
                    globalLogTextview.append(line);
                    if (globalLogTextviewContainer.getVisibility() != View.GONE) {
                        globalLogTextviewContainer.fullScroll(ScrollView.FOCUS_DOWN);
                    }
                }
            });
        }
    }

    public void setTitle(final String s) {
        uiHandler.post(new Runnable() {
            @Override
            public void run() {
                titleTextView.setLinksClickable(false);
                titleTextView.setText(s);
            }
        });
    }

    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }

}
