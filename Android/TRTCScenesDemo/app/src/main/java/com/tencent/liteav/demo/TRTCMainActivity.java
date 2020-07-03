package com.tencent.liteav.demo;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.URLSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.blankj.utilcode.constant.PermissionConstants;
import com.blankj.utilcode.util.PermissionUtils;
import com.tencent.liteav.liveroom.ui.liveroomlist.LiveRoomListActivity;

import com.tencent.liteav.login.ui.LoginActivity;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.meeting.ui.CreateMeetingActivity;
import com.tencent.liteav.trtcaudiocalldemo.ui.TRTCAudioCallSelectContactActivity;
import com.tencent.liteav.trtcvideocalldemo.ui.TRTCVideoCallSelectContactActivity;
import com.tencent.liteav.trtcvoiceroom.ui.list.VoiceRoomListActivity;
import com.tencent.rtmp.TXLiveBase;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class TRTCMainActivity extends Activity {

    private static final String TAG = TRTCMainActivity.class.getName();

    private TextView                mMainTitle;
    private TextView                mTvVersion;
    private List<TRTCItemEntity>    mTRTCItemEntityList;
    private RecyclerView            mRvList;
    private TRTCRecyclerViewAdapter mTRTCRecyclerViewAdapter;
    private ImageView               mLogoutImg;
    private AlertDialog             mAlertDialog;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if ((getIntent().getFlags() & Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) != 0) {
            Log.d(TAG, "brought to front");
            finish();
            return;
        }
        setContentView(R.layout.activity_trtc_main);
        mTvVersion = (TextView) findViewById(R.id.main_tv_version);
        mTvVersion.setText("腾讯云 TRTC v" + TXLiveBase.getSDKVersionStr()+"(7.4.278)");
        mMainTitle = (TextView) findViewById(R.id.main_title);
        mMainTitle.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                AsyncTask.execute(new Runnable() {
                    @Override
                    public void run() {
                        File logFile = getLogFile();
                        if (logFile != null) {
                            Intent intent = new Intent(Intent.ACTION_SEND);
                            intent.setType("application/octet-stream");
                            //intent.setPackage("com.tencent.mobileqq");
                            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(logFile));
                            startActivity(Intent.createChooser(intent, "分享日志"));
                        }
                    }
                });
                return false;
            }
        });
        mRvList = (RecyclerView) findViewById(R.id.main_recycler_view);
        mTRTCItemEntityList = createTRTCItems();
        mTRTCRecyclerViewAdapter = new TRTCRecyclerViewAdapter(this, mTRTCItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                TRTCItemEntity entity = mTRTCItemEntityList.get(position);
                Intent         intent = new Intent(TRTCMainActivity.this, entity.mTargetClass);
                intent.putExtra("TITLE", entity.mTitle);
                intent.putExtra("TYPE", entity.mType);
                TRTCMainActivity.this.startActivity(intent);
            }
        });
        mRvList.setLayoutManager(new GridLayoutManager(this, 2));
        mRvList.setAdapter(mTRTCRecyclerViewAdapter);
        mLogoutImg = (ImageView) findViewById(R.id.img_logout);
        mLogoutImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLogoutDialog();
            }
        });
        interceptHyperLink((TextView) findViewById(R.id.tv_privacy));
        initPermission();
    }
    private void stopService() {
        Intent intent = new Intent(this, CallService.class);
        stopService(intent);
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
    private void showLogoutDialog() {
        if (mAlertDialog == null) {
            mAlertDialog = new AlertDialog.Builder(this, R.style.common_alert_dialog)
                    .setMessage("确定要退出登录吗？")
                    .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            // 执行退出登录操作
                            ProfileManager.getInstance().logout(new ProfileManager.ActionCallback() {
                                @Override
                                public void onSuccess() {
                                    stopService();
                                    // 退出登录
                                    startLoginActivity();
                                }
                                @Override
                                public void onFailed(int code, String msg) {
                                }
                            });
                        }
                    })
                    .setNegativeButton("取消", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                        }
                    })
                    .create();
        }
        if (!mAlertDialog.isShowing()) {
            mAlertDialog.show();
        }
    }
    private void startLoginActivity() {
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
        finish();
    }
    private List<TRTCItemEntity> createTRTCItems() {
        List<TRTCItemEntity> list = new ArrayList<>();
        list.add(new TRTCItemEntity("多人视频会议", "语音自动降噪、视频画质超高清，适用于在线会议、远程培训、小班课等场景。", R.drawable.multi_meeting, 0, CreateMeetingActivity.class));
        list.add(new TRTCItemEntity("语音聊天室", "内含变声、音效、混响、背景音乐等声音玩法，适用于闲聊房、K歌房、开黑房等语聊场景。", R.drawable.voice_chatroom, 0, VoiceRoomListActivity.class));
        list.add(new TRTCItemEntity("视频互动直播", "低延时、十万人高并发的大型互动直播解决方案，观众时延低至800ms，上下麦切换免等待。", R.drawable.live_stream, 0, LiveRoomListActivity.class));
        list.add(new TRTCItemEntity("语音通话", "48kHz高音质，60%丢包可正常语音通话，领先行业的3A处理，杜绝回声和啸叫。", R.drawable.voice_call, 0, TRTCAudioCallSelectContactActivity.class));
        list.add(new TRTCItemEntity("视频通话", "支持720P/1080P高清画质，50%丢包率可正常视频通话，自带美颜、挂件、抠图等AI特效。", R.drawable.video_call, 0, TRTCVideoCallSelectContactActivity.class));
        return list;
    }
    private File getLogFile() {
        String       path      = getExternalFilesDir(null).getAbsolutePath() + "/log/tencent/liteav";
        List<String> logs      = new ArrayList<>();
        File         directory = new File(path);
        if (directory != null && directory.exists() && directory.isDirectory()) {
            long lastModify = 0;
            File files[]    = directory.listFiles();
            if (files != null && files.length > 0) {
                for (File file : files) {
                    if (file.getName().endsWith("xlog")) {
                        logs.add(file.getAbsolutePath());
                    }
                }
            }
        }
        String zipPath = path + "/liteavLog.zip";
        return zip(logs, zipPath);
    }
    private void initPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PermissionUtils.permission(PermissionConstants.STORAGE, PermissionConstants.MICROPHONE, PermissionConstants.CAMERA)
                    .request();
        }
    }
    private File zip(List<String> files, String zipFileName) {
        File zipFile = new File(zipFileName);
        zipFile.deleteOnExit();
        InputStream     is  = null;
        ZipOutputStream zos = null;
        try {
            zos = new ZipOutputStream(new FileOutputStream(zipFile));
            zos.setComment("LiteAV log");
            for (String path : files) {
                File file = new File(path);
                try {
                    if (file.length() == 0 || file.length() > 8 * 1024 * 1024) continue;
                    is = new FileInputStream(file);
                    zos.putNextEntry(new ZipEntry(file.getName()));
                    byte[] buffer = new byte[8 * 1024];
                    int    length = 0;
                    while ((length = is.read(buffer)) != -1) {
                        zos.write(buffer, 0, length);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        is.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (FileNotFoundException e) {
            Log.w(TAG, "zip log error");
            zipFile = null;
        } finally {
            try {
                zos.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return zipFile;
    }
    /**
     * 用于跳转隐私协议
     *
     * @param tv
     */
    private void interceptHyperLink(TextView tv) {
        tv.setMovementMethod(LinkMovementMethod.getInstance());
        CharSequence text = tv.getText();
        if (text instanceof Spannable) {
            int       end       = text.length();
            Spannable spannable = (Spannable) tv.getText();
            URLSpan[] urlSpans  = spannable.getSpans(0, end, URLSpan.class);
            if (urlSpans.length == 0) {
                return;
            }
            SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder(text);
            // 循环遍历并拦截 所有http://开头的链接
            for (URLSpan uri : urlSpans) {
                String url = uri.getURL();
                if (url.indexOf("https://") == 0 || url.indexOf("http://") == 0) {
                    CustomUrlSpan customUrlSpan = new CustomUrlSpan(this, url);
                    spannableStringBuilder.setSpan(customUrlSpan, spannable.getSpanStart(uri),
                            spannable.getSpanEnd(uri), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                }
            }
            tv.setText(spannableStringBuilder);
        }
    }

    public class CustomUrlSpan extends ClickableSpan {

        private Context context;
        private String  url;

        public CustomUrlSpan(Context context, String url) {
            this.context = context;
            this.url = url;
        }

        @Override
        public void onClick(View widget) {
            // 在这里可以做任何自己想要的处理
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(url));
            context.startActivity(intent);
        }
    }

    public class TRTCItemEntity {
        public String mTitle;
        public String mContent;
        public int    mIconId;
        public Class  mTargetClass;
        public int    mType;

        public TRTCItemEntity(String title, String content, int iconId, int type, Class targetClass) {
            mTitle = title;
            mContent = content;
            mIconId = iconId;
            mTargetClass = targetClass;
            mType = type;
        }
    }

    public class TRTCRecyclerViewAdapter extends
            RecyclerView.Adapter<TRTCRecyclerViewAdapter.ViewHolder> {

        private Context              context;
        private List<TRTCItemEntity> list;
        private OnItemClickListener  onItemClickListener;

        public TRTCRecyclerViewAdapter(Context context, List<TRTCItemEntity> list,
                                       OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private ImageView        mItemImg;
            private TextView         mTitleTv;
            private ConstraintLayout mClItem;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final TRTCItemEntity model,
                             final OnItemClickListener listener) {
                mItemImg.setImageResource(model.mIconId);
                mTitleTv.setText(model.mTitle);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }

            private void initView(final View itemView) {
                mItemImg = (ImageView) itemView.findViewById(R.id.img_item);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
                mClItem = (ConstraintLayout) itemView.findViewById(R.id.item_cl);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.module_trtc_entry_item, parent, false);
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

    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }
}
