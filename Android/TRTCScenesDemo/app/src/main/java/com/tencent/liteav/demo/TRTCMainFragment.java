package com.tencent.liteav.demo;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayoutManager;
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

import com.tencent.liteav.demo.common.widget.ConfirmDialogFragment;
import com.tencent.liteav.liveroom.ui.liveroomlist.LiveRoomListActivity;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.ui.LoginActivity;
import com.tencent.liteav.meeting.ui.CreateMeetingActivity;
import com.tencent.liteav.trtccalling.model.TRTCCalling;
import com.tencent.liteav.trtccalling.ui.TRTCCallingEntranceActivity;
import com.tencent.liteav.trtcchatsalon.ui.list.ChatSalonListActivity;
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

public class TRTCMainFragment extends Fragment {

    private static final String TAG = TRTCMainFragment.class.getName();

    private TextView                mMainTitle;
    private TextView                mTvVersion;
    private List<TRTCItemEntity>    mTRTCItemEntityList;
    private RecyclerView            mRvList;
    private TRTCRecyclerViewAdapter mTRTCRecyclerViewAdapter;
    private TextView                mLogoutTv;
    private ConfirmDialogFragment   mAlertDialog;
    private Context                 mContext;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = getActivity();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_trtc_main, container, false);
        mAlertDialog = new ConfirmDialogFragment();
        mTvVersion = (TextView) rootView.findViewById(R.id.main_tv_version);
        mTvVersion.setText(getString(R.string.app_tv_trtc_version, TXLiveBase.getSDKVersionStr()));
        mMainTitle = (TextView) rootView.findViewById(R.id.main_title);
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
                            startActivity(Intent.createChooser(intent, getString(R.string.app_title_share_log)));
                        }
                    }
                });
                return false;
            }
        });
        mRvList = (RecyclerView) rootView.findViewById(R.id.main_recycler_view);
        mTRTCItemEntityList = createTRTCItems();
        mTRTCRecyclerViewAdapter = new TRTCRecyclerViewAdapter(mContext, mTRTCItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                TRTCItemEntity entity = mTRTCItemEntityList.get(position);
                Intent         intent = new Intent(mContext, entity.mTargetClass);
                intent.putExtra("TITLE", entity.mTitle);
                intent.putExtra("TYPE", entity.mType);
                TRTCMainFragment.this.startActivity(intent);
            }
        });
        mRvList.setLayoutManager(new GridLayoutManager(mContext, 1));
        mRvList.setAdapter(mTRTCRecyclerViewAdapter);
        mLogoutTv = (TextView) rootView.findViewById(R.id.tv_login_out);
        mLogoutTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLogoutDialog();
            }
        });
        interceptHyperLink((TextView)rootView.findViewById(R.id.tv_privacy));
        return rootView;
    }

    private void showLogoutDialog() {
        if (mAlertDialog.isAdded()) {
            mAlertDialog.dismiss();
        }
        mAlertDialog.setMessage(mContext.getString(R.string.app_dialog_log_out));
        mAlertDialog.setNegativeClickListener(new ConfirmDialogFragment.NegativeClickListener() {
            @Override
            public void onClick() {
                mAlertDialog.dismiss();
            }
        });
        mAlertDialog.setPositiveClickListener(new ConfirmDialogFragment.PositiveClickListener() {
            @Override
            public void onClick() {
                mAlertDialog.dismiss();
                // 执行退出登录操作
                ProfileManager.getInstance().logout(new ProfileManager.ActionCallback() {
                    @Override
                    public void onSuccess() {
                        CallService.stop(mContext);
                        // 退出登录
                        startLoginActivity();
                    }

                    @Override
                    public void onFailed(int code, String msg) {
                    }
                });
            }
        });
        mAlertDialog.show(getActivity().getFragmentManager(), "confirm_fragment");
    }

    private void startLoginActivity() {
        Intent intent = new Intent(mContext, LoginActivity.class);
        startActivity(intent);
        getActivity().finish();
    }

    private List<TRTCItemEntity> createTRTCItems() {
        List<TRTCItemEntity> list = new ArrayList<>();
        list.add(new TRTCItemEntity(getString(R.string.item_chat_room), getString(R.string.app_tv_chat_room_tips), R.drawable.app_voice_chatroom, 0, VoiceRoomListActivity.class));
        list.add(new TRTCItemEntity(getString(R.string.item_video_conferencing), getString(R.string.app_tv_video_conferencing_tips), R.drawable.app_multi_meeting, 0, CreateMeetingActivity.class));
        list.add(new TRTCItemEntity(getString(R.string.item_voice_call), getString(R.string.app_tv_voice_call_tips), R.drawable.app_audio_call, TRTCCalling.TYPE_AUDIO_CALL, TRTCCallingEntranceActivity.class));
        list.add(new TRTCItemEntity(getString(R.string.item_video_call), getString(R.string.app_tv_video_call_tips), R.drawable.app_video_call, TRTCCalling.TYPE_VIDEO_CALL, TRTCCallingEntranceActivity.class));
        list.add(new TRTCItemEntity(getString(R.string.item_video_interactive_live_streaming), getString(R.string.app_tv_video_interactive_live_streaming_tips), R.drawable.app_live_stream, 0, LiveRoomListActivity.class));
        list.add(new TRTCItemEntity(getString(R.string.item_chat_salon), getString(R.string.app_tv_chat_salon_tips), R.drawable.app_chat_salon, 0, ChatSalonListActivity.class));
        return list;
    }

    private File getLogFile() {
        String       path      = mContext.getExternalFilesDir(null).getAbsolutePath() + "/log/liteav";
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
                    CustomUrlSpan customUrlSpan = new CustomUrlSpan(mContext, url);
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
            private TextView         mDescription;
            private ConstraintLayout mClItem;
            private View             mBottomLine;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final TRTCItemEntity model,
                             final OnItemClickListener listener) {
                mItemImg.setImageResource(model.mIconId);
                mTitleTv.setText(model.mTitle);
                mDescription.setText(model.mContent);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
                mBottomLine.setVisibility(((getLayoutPosition() == list.size() - 1) ? View.VISIBLE : View.GONE));
            }

            private void initView(final View itemView) {
                mItemImg = (ImageView) itemView.findViewById(R.id.img_item);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
                mClItem = (ConstraintLayout) itemView.findViewById(R.id.item_cl);
                mDescription = (TextView) itemView.findViewById(R.id.tv_description);
                mBottomLine = itemView.findViewById(R.id.bottom_line);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context    = parent.getContext();
            LayoutInflater inflater   = LayoutInflater.from(context);
            View           view       = inflater.inflate(R.layout.module_trtc_entry_item, parent, false);
            ViewHolder     viewHolder = new ViewHolder(view);
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