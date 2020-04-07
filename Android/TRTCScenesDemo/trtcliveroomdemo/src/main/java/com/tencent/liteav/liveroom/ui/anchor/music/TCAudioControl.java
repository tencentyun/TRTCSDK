package com.tencent.liteav.liveroom.ui.anchor.music;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.tencent.liteav.liveroom.R;
import com.tencent.liteav.liveroom.model.TRTCLiveRoom;
import com.tencent.liteav.liveroom.ui.common.utils.TCUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Module:   TCAudioControl
 * <p>
 * Function: 音乐的控制界面
 * <p>
 * 1. 调节伴奏音调、伴奏音量、人声音量
 * <p>
 * 2. 选择 BGM 进行播放
 * <p>
 * 3. 混响设置
 * <p>
 * 4. 变声设置
 */
public class TCAudioControl extends RelativeLayout implements SeekBar.OnSeekBarChangeListener, Button.OnClickListener {
    public static final int     NEXTBGM     = 1;
    public static final int     PREVIOUSBGM = 2;
    public static final int     RANDOMBGM   = 3;
    //Audio Control
    public static final String  TAG         = TCAudioControl.class.getSimpleName();
    private             SeekBar mMicVolumeSeekBar;
    private             SeekBar mBGMVolumeSeekBar;
    private             SeekBar mBGMSeekBar;

    private Button mBtnReverbDefalult;
    private Button mBtnReverb1;
    private Button mBtnReverb2;
    private Button mBtnReverb3;
    private Button mBtnReverb4;
    private Button mBtnReverb5;
    private Button mBtnReverb6;
    private int    mLastReverbIndex;

    private Button mBtnVoiceChangerDefault;
    private Button mBtnVoiceChanger1;
    private Button mBtnVoiceChanger2;
    private Button mBtnVoiceChanger3;
    private Button mBtnVoiceChanger4;
    private Button mBtnVoiceChanger5;
    private Button mBtnVoiceChanger6;
    private Button mBtnVoiceChanger7;
    private Button mBtnVoiceChanger8;
    private Button mBtnVoiceChanger9;
    private Button mBtnVoiceChanger10;
    private Button mBtnVoiceChanger11;
    private int    mLastVoiceChangerIndex;

    private Button mBtnStopBgm;

    private Button  mBtnAutoSearch;
    private Button  mBtnSelectActivity;
    private int     mMicVolume = 100;
    private int     mBGMVolume = 100;
    private int     mBGMPitch  = 100;
    private boolean mBGMSwitch = false;
    private boolean mScanning  = false;
    Context           mContext;
    List<MusicEntity> mMusicListData;
    MusicListView     mMusicList;
    public              TCMusicSelectView   mMusicSelectView;
    public              LinearLayout        mMusicControlPart;
    private             int                 mSelectItemPos      = -1;
    private             int                 mLastPlayingItemPos = -1;
    public static final int                 REQUESTCODE         = 1;
    private             Map<String, String> mPathSet;
    private             TRTCLiveRoom        mPusher;

    public void setPusher(TRTCLiveRoom pusher) {
        mPusher = pusher;
    }

    public TCAudioControl(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        LayoutInflater.from(context).inflate(R.layout.liveroom_view_audio_ctrl, this);
        init();
    }

    public TCAudioControl(Context context) {
        this(context, null);
    }

    public final Activity getActivity() {
        return (Activity) mContext;
    }

    private synchronized void playBGM(String name, String path, int pos) {
        if (mLastPlayingItemPos >= 0 && mLastPlayingItemPos != pos) {
            mMusicListData.get(mLastPlayingItemPos).state = 0;
        }
        if (!mPusher.getAudioEffectManager().playBGM(path)) {
            // Note:AndroidQ(10)不可以读取非私有目录文件
            Toast.makeText(getActivity().getApplicationContext(), "打开BGM失败:" + path, Toast.LENGTH_SHORT).show();
            mMusicList.getAdapter().notifyDataSetChanged();
            return;
        }
        mPusher.getAudioEffectManager().setMicVolume(mBGMVolume);
        mBGMSwitch = true;
        mMusicListData.get(pos).state = 1;
        mLastPlayingItemPos = pos;
        mMusicList.getAdapter().notifyDataSetChanged();
    }

    public synchronized void stopBGM() {
        mBGMSwitch = false;
        if (mPusher != null) mPusher.getAudioEffectManager().stopBGM();
    }

    public synchronized void playBGM(int order) {
        mSelectItemPos = mLastPlayingItemPos;
        switch (order) {
            case NEXTBGM:
                mSelectItemPos = mSelectItemPos + 1;
                if (mSelectItemPos >= mMusicListData.size()) {
                    mSelectItemPos = 0;
                }
                break;
            case PREVIOUSBGM:
                mSelectItemPos = mSelectItemPos - 1;
                if (mSelectItemPos < 0) {
                    mSelectItemPos = mMusicListData.size() - 1;
                }
                break;
            case RANDOMBGM:
                mSelectItemPos = (int) (Math.random() * mMusicListData.size());
                break;
        }
        mMusicList.requestFocus();
        mMusicList.setItemChecked(mSelectItemPos, true);

        MusicEntity musicEntity = mMusicListData.get(mSelectItemPos);
        playBGM(musicEntity.title, musicEntity.path, mSelectItemPos);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_reverb_default) {
            mPusher.getAudioEffectManager().setReverbType(0);
        } else if (id == R.id.btn_reverb_1) {
            mPusher.getAudioEffectManager().setReverbType(1);
        } else if (id == R.id.btn_reverb_2) {
            mPusher.getAudioEffectManager().setReverbType(2);
        } else if (id == R.id.btn_reverb_3) {
            mPusher.getAudioEffectManager().setReverbType(3);
        } else if (id == R.id.btn_reverb_4) {
            mPusher.getAudioEffectManager().setReverbType(4);
        } else if (id == R.id.btn_reverb_5) {
            mPusher.getAudioEffectManager().setReverbType(5);
        } else if (id == R.id.btn_reverb_6) {
            mPusher.getAudioEffectManager().setReverbType(6);
        } else if (id == R.id.btn_voicechanger_default) {
            mPusher.getAudioEffectManager().setVoiceChangerType(0);
        } else if (id == R.id.btn_voicechanger_1) {
            mPusher.getAudioEffectManager().setVoiceChangerType(1);
        } else if (id == R.id.btn_voicechanger_2) {
            mPusher.getAudioEffectManager().setVoiceChangerType(2);
        } else if (id == R.id.btn_voicechanger_3) {
            mPusher.getAudioEffectManager().setVoiceChangerType(3);
        } else if (id == R.id.btn_voicechanger_4) {
            mPusher.getAudioEffectManager().setVoiceChangerType(4);
        } else if (id == R.id.btn_voicechanger_5) {
            mPusher.getAudioEffectManager().setVoiceChangerType(5);
        } else if (id == R.id.btn_voicechanger_6) {
            mPusher.getAudioEffectManager().setVoiceChangerType(6);
        } else if (id == R.id.btn_voicechanger_7) {
            mPusher.getAudioEffectManager().setVoiceChangerType(7);
        } else if (id == R.id.btn_voicechanger_8) {
            mPusher.getAudioEffectManager().setVoiceChangerType(8);
        } else if (id == R.id.btn_voicechanger_9) {
            mPusher.getAudioEffectManager().setVoiceChangerType(9);
        } else if (id == R.id.btn_voicechanger_10) {
            mPusher.getAudioEffectManager().setVoiceChangerType(10);
        } else if (id == R.id.btn_voicechanger_11) {
            mPusher.getAudioEffectManager().setVoiceChangerType(11);
        } else if (id == R.id.btn_stop_bgm) {
            stopBGM();
        }

        if (R.id.btn_stop_bgm != v.getId() && v.getId() != mLastReverbIndex &&
                (v.getId() == R.id.btn_reverb_default || v.getId() == R.id.btn_reverb_1 ||
                        v.getId() == R.id.btn_reverb_2 || v.getId() == R.id.btn_reverb_3 ||
                        v.getId() == R.id.btn_reverb_4 || v.getId() == R.id.btn_reverb_5 ||
                        v.getId() == R.id.btn_reverb_6)) {   // 混响
            v.setBackground(getResources().getDrawable(R.drawable.round_button_3));

            View lastV = findViewById(mLastReverbIndex);
            if (null != lastV) {
                lastV.setBackgroundDrawable(getResources().getDrawable(R.drawable.round_button_2));
            }

            mLastReverbIndex = v.getId();

        } else if (R.id.btn_stop_bgm != v.getId() && v.getId() != mLastVoiceChangerIndex) {  // 变声
            v.setBackground(getResources().getDrawable(R.drawable.round_button_3));

            View lastV = findViewById(mLastVoiceChangerIndex);
            if (null != lastV) {
                lastV.setBackgroundDrawable(getResources().getDrawable(R.drawable.round_button_2));
            }

            mLastVoiceChangerIndex = v.getId();
        }
    }

    class UpdatePlayProgressThread implements Runnable {
        public boolean mRun = true;
        TCAudioControl mPlayer;

        public UpdatePlayProgressThread(TCAudioControl musicPlayer) {
            mPlayer = musicPlayer;
        }

        @Override
        public void run() {
            while (mRun) {
                try {
                    Thread.sleep(1000);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void init() {
        mMicVolumeSeekBar = (SeekBar) findViewById(R.id.seekBar_voice_volume);
        mMicVolumeSeekBar.setOnSeekBarChangeListener(this);
        mBGMVolumeSeekBar = (SeekBar) findViewById(R.id.seekBar_bgm_volume);
        mBGMVolumeSeekBar.setOnSeekBarChangeListener(this);
        mBGMSeekBar = (SeekBar) findViewById(R.id.seekBar_bgm_seek);
        mBGMSeekBar.setOnSeekBarChangeListener(this);

        mBtnReverbDefalult = (Button) findViewById(R.id.btn_reverb_default);
        mBtnReverbDefalult.setOnClickListener(this);
        mBtnReverb1 = (Button) findViewById(R.id.btn_reverb_1);
        mBtnReverb1.setOnClickListener(this);
        mBtnReverb2 = (Button) findViewById(R.id.btn_reverb_2);
        mBtnReverb2.setOnClickListener(this);
        mBtnReverb3 = (Button) findViewById(R.id.btn_reverb_3);
        mBtnReverb3.setOnClickListener(this);
        mBtnReverb4 = (Button) findViewById(R.id.btn_reverb_4);
        mBtnReverb4.setOnClickListener(this);
        mBtnReverb5 = (Button) findViewById(R.id.btn_reverb_5);
        mBtnReverb5.setOnClickListener(this);
        mBtnReverb6 = (Button) findViewById(R.id.btn_reverb_6);
        mBtnReverb6.setOnClickListener(this);

        mBtnVoiceChangerDefault = (Button) findViewById(R.id.btn_voicechanger_default);
        mBtnVoiceChangerDefault.setOnClickListener(this);
        mBtnVoiceChanger1 = (Button) findViewById(R.id.btn_voicechanger_1);
        mBtnVoiceChanger1.setOnClickListener(this);
        mBtnVoiceChanger2 = (Button) findViewById(R.id.btn_voicechanger_2);
        mBtnVoiceChanger2.setOnClickListener(this);
        mBtnVoiceChanger3 = (Button) findViewById(R.id.btn_voicechanger_3);
        mBtnVoiceChanger3.setOnClickListener(this);
        mBtnVoiceChanger4 = (Button) findViewById(R.id.btn_voicechanger_4);
        mBtnVoiceChanger4.setOnClickListener(this);
        mBtnVoiceChanger5 = (Button) findViewById(R.id.btn_voicechanger_5);
        mBtnVoiceChanger5.setOnClickListener(this);
        mBtnVoiceChanger6 = (Button) findViewById(R.id.btn_voicechanger_6);
        mBtnVoiceChanger6.setOnClickListener(this);
        mBtnVoiceChanger7 = (Button) findViewById(R.id.btn_voicechanger_7);
        mBtnVoiceChanger7.setOnClickListener(this);
        mBtnVoiceChanger8 = (Button) findViewById(R.id.btn_voicechanger_8);
        mBtnVoiceChanger8.setOnClickListener(this);
        mBtnVoiceChanger9 = (Button) findViewById(R.id.btn_voicechanger_9);
        mBtnVoiceChanger9.setOnClickListener(this);
        mBtnVoiceChanger10 = (Button) findViewById(R.id.btn_voicechanger_10);
        mBtnVoiceChanger10.setOnClickListener(this);
        mBtnVoiceChanger11 = (Button) findViewById(R.id.btn_voicechanger_11);
        mBtnVoiceChanger11.setOnClickListener(this);

        mBtnStopBgm = (Button) findViewById(R.id.btn_stop_bgm);
        mBtnStopBgm.setOnClickListener(this);

        mBtnSelectActivity = (Button) findViewById(R.id.btn_select_bgm);
        mMusicSelectView = (TCMusicSelectView) findViewById(R.id.xml_music_select_view);
        mMusicControlPart = (LinearLayout) findViewById(R.id.xml_music_control_part);
        mMusicListData = new ArrayList<MusicEntity>();
        mMusicSelectView.init(new TCMusicSelectView.Callback() {
            @Override
            public void onBackBtnClick() {
                mMusicSelectView.setVisibility(GONE);
                mMusicControlPart.setVisibility(VISIBLE);
            }
        }, mMusicListData);
        mMusicList = mMusicSelectView.mMusicList;
        mPathSet = new HashMap<String, String>();
        mBtnAutoSearch = mMusicSelectView.mBtnAutoSearch;
        mMusicSelectView.setBackgroundColor(0xffffffff);
        WindowManager wm     = (WindowManager) getContext().getSystemService(Context.WINDOW_SERVICE);
        int           height = wm.getDefaultDisplay().getHeight();
        mMusicSelectView.setMinimumHeight(height);

        mBtnSelectActivity.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMusicSelectView.setVisibility(mMusicSelectView.getVisibility() == View.VISIBLE ? View.GONE : View.VISIBLE);
                mMusicControlPart.setVisibility(View.GONE);
            }
        });

        mMusicList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                MusicEntity entity = mMusicListData.get(position);
                playBGM(entity.title, entity.path, position);
                mSelectItemPos = position;
            }
        });


        mBtnAutoSearch.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mScanning) {
                    mScanning = false;
                    fPause = true;
                } else {
                    mScanning = true;
                    getMusicList(mContext, mMusicListData);
                    mScanning = false;
                    if (mMusicListData.size() > 0) {
                        mMusicList.setupList(LayoutInflater.from(mContext), mMusicListData);
                        mSelectItemPos = 0;
                        mMusicList.requestFocus();
                        mMusicList.setItemChecked(0, true);
                    }
                }
            }
        });
    }

    public void unInit() {
        if (mBGMSwitch) {
            stopBGM();
        }
    }

    public void processActivityResult(Uri uri) {
        Cursor cursor = mContext.getContentResolver().query(uri,
                new String[]{
                        MediaStore.Audio.Media._ID,
                        MediaStore.Audio.Media.TITLE,
                        MediaStore.Audio.Media.DISPLAY_NAME,
                        MediaStore.Audio.Media.DURATION,
                        MediaStore.Audio.Media.ARTIST,
                        MediaStore.Audio.Media.DATA,
                        MediaStore.Audio.Media.SIZE},
                null, null, null);
        MusicEntity musicEntity = new MusicEntity();
        if (cursor == null) {
            Log.e(TAG, "GetMediaList cursor is null.");
            musicEntity.duration = 0;
            musicEntity.path = TCUtils.getPath(mContext, uri);
            String[] names = musicEntity.path.split("/");
            if (names != null) {
                musicEntity.display_name = names[names.length - 1];
                musicEntity.title = musicEntity.display_name;
            } else {
                musicEntity.display_name = "未命名歌曲";
                musicEntity.title = musicEntity.display_name;
            }
        } else {
            int count = cursor.getCount();
            if (count <= 0) {
                Log.e(TAG, "GetMediaList cursor count is 0.");
                return;
            }
            cursor.moveToFirst();

            musicEntity.id = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.Media._ID));
            //musicEntity.title = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.TITLE));
            musicEntity.display_name = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME));
            String title = musicEntity.display_name.split("\\.")[0];
            musicEntity.title = title.equals("") ? musicEntity.display_name : title;
            musicEntity.size = cursor.getLong(cursor.getColumnIndex(MediaStore.Audio.Media.SIZE));
            //                if(!checkIsMusic(musicEntity.duration, musicEntity.size)) {
            //                    continue;
            //                }
            musicEntity.artist = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST));
            musicEntity.path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DATA));
            if (musicEntity.path == null) {
                musicEntity.path = TCUtils.getPath(mContext, uri);
            }
            musicEntity.duration = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.Media.DURATION));
        }
        if (musicEntity.path == null) {
            Toast.makeText(mContext, "Get Music Path Error", Toast.LENGTH_SHORT);
            return;
        } else {
            if (mPathSet.get(musicEntity.path) != null) {
                Toast.makeText(mContext, "请勿重复添加", Toast.LENGTH_SHORT);
                return;
            }
        }
        mPathSet.put(musicEntity.path, musicEntity.display_name);
        if (musicEntity.duration == 0) {
            musicEntity.duration = mPusher.getAudioEffectManager().getBGMDuration(musicEntity.path);
        }
        musicEntity.durationStr = longToStrTime(musicEntity.duration);
        mMusicListData.add(musicEntity);
        if (mMusicListData != null) {
            mSelectItemPos = mMusicListData.size() - 1;
        } else {
            mSelectItemPos = -1;
        }
        mMusicList.setupList(LayoutInflater.from(mContext), mMusicListData);
        mMusicList.requestFocus();
        mMusicList.setItemChecked(mSelectItemPos, true);
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (seekBar.getId() == R.id.seekBar_voice_volume) {
            mMicVolume = progress;
            mPusher.getAudioEffectManager().setMicVolume(mMicVolume);
        } else if (seekBar.getId() == R.id.seekBar_bgm_volume) {
            mBGMVolume = progress;
            mPusher.getAudioEffectManager().setBGMVolume(mBGMVolume);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        if (seekBar.getId() == R.id.seekBar_bgm_seek) {
            int duration = mPusher.getAudioEffectManager().getBGMDuration(null);
            mPusher.getAudioEffectManager().setBGMPosition(duration * seekBar.getProgress() / 100);
        }
    }

    class MusicScanner extends BroadcastReceiver {
        private AlertDialog.Builder builder = null;
        private AlertDialog         ad      = null;
        Context           mContext;
        List<MusicEntity> mList;
        TextView          mPathView;

        public void startScanner(Context context, TextView pathView, List<MusicEntity> list) {
            mContext = context;
            mList = list;
            mPathView = pathView;
            IntentFilter intentfilter = new IntentFilter(Intent.ACTION_MEDIA_SCANNER_STARTED);
            intentfilter.addAction(Intent.ACTION_MEDIA_SCANNER_FINISHED);
            intentfilter.addDataScheme("file");

            File sdcardDir = mContext.getExternalFilesDir(null);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {

                if (sdcardDir != null) {
                    String[] paths = new String[]{sdcardDir.getAbsolutePath()};
                    MediaScannerConnection.scanFile(mContext, paths, null, null);
                }
            } else {
                mContext.registerReceiver(this, intentfilter);
                if (sdcardDir != null) {
                    mContext.sendBroadcast(new Intent(Intent.ACTION_MEDIA_MOUNTED, Uri.parse("file://" + sdcardDir.getAbsolutePath())));
                }
            }
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (Intent.ACTION_MEDIA_SCANNER_STARTED.equals(action)) {
                builder = new AlertDialog.Builder(context, R.style.LiveRoomDialogTheme);
                builder.setMessage("正在扫描存储卡...");
                ad = builder.create();
                ad.show();
            } else if (Intent.ACTION_MEDIA_SCANNER_FINISHED.equals(action)) {
                getMusicList(mContext, mList);
                ad.dismiss();
            }
        }
    }

    String longToStrTime(long time) {
        time /= 1000;
        return (time / 60) + ":" + ((time % 60) > 9 ? (time % 60) : ("0" + (time % 60)));
    }

    static public boolean fPause = false;

    public void getMusicList(Context context, List<MusicEntity> list) {
        Cursor            cursor    = null;
        List<MusicEntity> mediaList = list;
        try {
            cursor = context.getContentResolver().query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    new String[]{
                            MediaStore.Audio.Media._ID,
                            MediaStore.Audio.Media.TITLE,
                            MediaStore.Audio.Media.DISPLAY_NAME,
                            MediaStore.Audio.Media.DURATION,
                            MediaStore.Audio.Media.ARTIST,
                            MediaStore.Audio.Media.DATA,
                            MediaStore.Audio.Media.SIZE},
                    null, null, MediaStore.Video.Media.DEFAULT_SORT_ORDER);
            //selection, null, MediaStore.Audio.Media.DATE_ADDED + " DESC");
            if (cursor == null) {
                Log.e(TAG, "GetMediaList cursor is null.");
                return;
            }
            int count = cursor.getCount();
            if (count <= 0) {
                Log.e(TAG, "GetMediaList cursor count is 0.");
                return;
            }
            MusicEntity musicEntity = null;
            //          String[] columns = cursor.getColumnNames();
            while (!fPause && cursor.moveToNext()) {
                musicEntity = new MusicEntity();
                // 兼容 Android 10以上
                Uri uri = ContentUris.withAppendedId(
                        MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, cursor.getLong(cursor.getColumnIndexOrThrow((MediaStore.Audio.Media._ID))));
                musicEntity.fileUri = uri;
                musicEntity.id = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.Media._ID));
                musicEntity.title = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.TITLE));
                musicEntity.display_name = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DISPLAY_NAME));
                musicEntity.size = cursor.getLong(cursor.getColumnIndex(MediaStore.Audio.Media.SIZE));
                //                if(!checkIsMusic(musicEntity.duration, musicEntity.size)) {
                //                    continue;
                //                }
                musicEntity.artist = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST));
                musicEntity.path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.Media.DATA));

                Log.d(TAG, "MusicEntry:" + musicEntity.toString());
                if (musicEntity.path == null) {
                    fPause = false;
                    Toast.makeText(mContext, "Get Music Path Error", Toast.LENGTH_SHORT);
                    return;
                } else {
                    if (mPathSet.get(musicEntity.path) != null) {
                        Toast.makeText(mContext, "请勿重复添加", Toast.LENGTH_SHORT);
                        fPause = false;
                        return;
                    }
                }
                mPathSet.put(musicEntity.path, musicEntity.display_name);
                musicEntity.duration = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.Media.DURATION));
                if (musicEntity.duration == 0) {
                    musicEntity.duration = mPusher.getAudioEffectManager().getBGMDuration(musicEntity.path);
                }
                musicEntity.durationStr = longToStrTime(musicEntity.duration);
                mediaList.add(musicEntity);
            }
            fPause = false;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return;
    }

}

