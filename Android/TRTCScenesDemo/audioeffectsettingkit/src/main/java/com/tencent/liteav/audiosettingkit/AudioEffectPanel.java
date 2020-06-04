package com.tencent.liteav.audiosettingkit;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class AudioEffectPanel extends FrameLayout {

    private static final String TAG = AudioEffectPanel.class.getSimpleName();

    private Context mContext;
    private Button mBtnSelectedSong;
    private RecyclerView mRVAuidoChangeType;
    private RecyclerView mRVAudioReverbType;
    private RecyclerView mRVAudioBGM;
    private SeekBar  mSbMicVolume;
    private SeekBar  mSbBGMVolume;
    private SeekBar  mSbPitchLevel;
    private RecyclerViewAdapter mChangerRVAdapter;
    private RecyclerViewAdapter mReverbRVAdapter;
    private BGMRecyclerViewAdapter mBGMRVAdapter;
    private List<ItemEntity> mChangerItemEntityList;
    private List<ItemEntity> mReverbItemEntityList;
    private ImageView mIVBGMBack;
    private LinearLayout mMainAudioEffectPanel;
    private LinearLayout mBGMPanel;
    private List<BGMItemEntity> mBGMItemEntityList;
    private TextView mTvClosePanel;
    private TextView mTvBGMVolume;
    private TextView mTvPitchLevel;
    private TextView mTvMicVolume;
    private TextView mTvActor;
    private TextView mTvStartTime;
    private TextView mTvTotalTime;
    private TextView mTvBGM;
    private LinearLayout mLayoutSelectBGM;
    private ImageButton mImgbtnBGMPlay;
    private TXAudioEffectManager mAudioEffectManager;
    private BGMListener mBGMPlayListenr;
    private static final String ONLINE_BGM_FIRST = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic1.mp3";
    private static final String ONLINE_BGM_SECOND = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic2.mp3";
    private static final String ONLINE_BGM_THIRD = "http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic3.mp3";

    private int mBGMId;
    private boolean mIsPlaying = false;
    private boolean mIsPlayEnd = false;

    private static final List<String>  REVERB_LIST            = Arrays.asList("关闭混响", "KTV", "小房间", "大会堂", "低沉", "洪亮", "金属声", "磁性");
    private static final List<Integer> REVERB_TYPE_ARR        = Arrays.asList(TRTCCloudDef.TRTC_REVERB_TYPE_0,
            TRTCCloudDef.TRTC_REVERB_TYPE_1, TRTCCloudDef.TRTC_REVERB_TYPE_2, TRTCCloudDef.TRTC_REVERB_TYPE_3,
            TRTCCloudDef.TRTC_REVERB_TYPE_4, TRTCCloudDef.TRTC_REVERB_TYPE_5, TRTCCloudDef.TRTC_REVERB_TYPE_6, TRTCCloudDef.TRTC_REVERB_TYPE_7);
    // 对应 SDK 的变声列表（TRTCCloudDef中定义）
    private static final List<String>  VOICE_CHANGER_LIST     = Arrays.asList("关闭变声", "熊孩子", "萝莉", "大叔", "重金属", "感冒", "外国人", "困兽", "死肥仔", "强电流", "重机械", "空灵");
    private static final List<Integer> VOICE_CHANGER_TYPE_ARR = Arrays.asList(TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_1, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_2, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_3,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_4, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_5, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_6,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_7, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_8, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_9,
            TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_10, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_11);

    public AudioEffectPanel(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        LayoutInflater.from(context).inflate(R.layout.audio_effect_panel, this);
        initView();
    }

    private void initView() {

        mTvClosePanel = (TextView) findViewById(R.id.tv_close_panel);
        mTvBGMVolume =  (TextView) findViewById(R.id.tv_bgm_volume);
        mTvMicVolume = (TextView) findViewById(R.id.tv_mic_volume);
        mTvPitchLevel = (TextView) findViewById(R.id.tv_pitch_level);
        mTvActor = (TextView) findViewById(R.id.tv_actor);
        mTvStartTime = (TextView) findViewById(R.id.tv_bgm_start_time);
        mTvTotalTime = (TextView) findViewById(R.id.tv_bgm_end_time);
        mImgbtnBGMPlay = (ImageButton) findViewById(R.id.ib_audio_bgm_play);
        mTvBGM = (TextView) findViewById(R.id.tv_bgm);
        mLayoutSelectBGM = (LinearLayout) findViewById(R.id.ll_select_bgm);
        mLayoutSelectBGM.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(VISIBLE);
            }
        });

        mTvClosePanel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(GONE);
                if (mAudioEffectPanelHideListener != null) {
                    mAudioEffectPanelHideListener.onClosePanel();
                }
            }
        });

        mBtnSelectedSong = (Button) findViewById(R.id.audio_btn_select_song);
        mBtnSelectedSong.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(VISIBLE);
            }
        });
        mSbMicVolume = (SeekBar) findViewById(R.id.sb_mic_volume);
        mSbMicVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvMicVolume.setText(progress + "");
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceCaptureVolume(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        mSbBGMVolume = (SeekBar) findViewById(R.id.sb_bgm_volume);
        mSbBGMVolume.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mTvBGMVolume.setText(progress + "");
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setMusicPlayoutVolume(mBGMId, progress);
                    mAudioEffectManager.setMusicPublishVolume(mBGMId, progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        mSbPitchLevel = (SeekBar) findViewById(R.id.sb_pitch_level);
        mSbPitchLevel.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                float pitch = ((progress - 50) / (float) 50);
                mTvPitchLevel.setText(pitch + "");
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setMusicPitch(mBGMId, pitch);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        mIVBGMBack = (ImageView) findViewById(R.id.iv_bgm_back);
        mIVBGMBack.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(VISIBLE);
                mBGMPanel.setVisibility(GONE);
            }
        });

        mMainAudioEffectPanel = (LinearLayout) findViewById(R.id.audio_main_ll);
        mBGMPanel = (LinearLayout) findViewById(R.id.audio_main_bgm);

        mRVAudioReverbType = (RecyclerView) findViewById(R.id.audio_reverb_type_rv);
        mRVAuidoChangeType = (RecyclerView) findViewById(R.id.audio_change_type_rv);
        mRVAudioBGM = (RecyclerView) findViewById(R.id.audio_bgm_rv);

        mChangerItemEntityList = createAudioChangeItems();
        mReverbItemEntityList = createReverbItems();
        mBGMItemEntityList = createBGMItems();
        // 选变声
        mChangerRVAdapter = new RecyclerViewAdapter(mContext, mChangerItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                int type = mChangerItemEntityList.get(position).mType;
                Log.d(TAG, "select changer type " + type);
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceChangerType(translateChangerType(type));
                }
                for (int i = 0 ; i <  mChangerItemEntityList.size(); i++) {
                    if (position == i) {
                        mChangerItemEntityList.get(i).mIsSelected = true;
                    } else {
                        mChangerItemEntityList.get(i).mIsSelected = false;
                    }
                }
                mChangerRVAdapter.notifyDataSetChanged();
            }
        });
        LinearLayoutManager layoutManager = new LinearLayoutManager(mContext);
        layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRVAuidoChangeType.setLayoutManager(layoutManager);
        mRVAuidoChangeType.setAdapter(mChangerRVAdapter);
        // 选混响
        mReverbRVAdapter = new RecyclerViewAdapter(mContext, mReverbItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                int type = mReverbItemEntityList.get(position).mType;
                Log.d(TAG, "select reverb type " + type);
                if (mAudioEffectManager != null) {
                    mAudioEffectManager.setVoiceReverbType(translateReverbType(type));
                }
                for (int i = 0 ; i <  mReverbItemEntityList.size(); i++) {
                    if (position == i) {
                        mReverbItemEntityList.get(i).mIsSelected = true;
                    } else {
                        mReverbItemEntityList.get(i).mIsSelected = false;
                    }
                }
                mReverbRVAdapter.notifyDataSetChanged();
            }
        });

        LinearLayoutManager reverbLayoutManager = new LinearLayoutManager(mContext);
        reverbLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        mRVAudioReverbType.setLayoutManager(reverbLayoutManager);
        mRVAudioReverbType.setAdapter(mReverbRVAdapter);

        // 选BGM
        mBGMRVAdapter = new BGMRecyclerViewAdapter(mContext, mBGMItemEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {

            }
        });
        mRVAudioBGM.setLayoutManager(new LinearLayoutManager(mContext));
        mRVAudioBGM.setAdapter(mBGMRVAdapter);
    }

    private TXAudioEffectManager.TXVoiceChangerType translateChangerType(int type) {
        TXAudioEffectManager.TXVoiceChangerType changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
        switch (type) {
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_1:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_2:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_3:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_4:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_5:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_6:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_7:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_8:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_9:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_10:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
                break;
            case TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_11:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
                break;
        }
        return changerType;
    }

    private TXAudioEffectManager.TXVoiceReverbType translateReverbType(int type) {
        TXAudioEffectManager.TXVoiceReverbType reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
        switch (type) {
            case TRTCCloudDef.TRTC_REVERB_TYPE_0:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_1:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_2:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_3:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_4:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_5:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_6:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
                break;
            case TRTCCloudDef.TRTC_REVERB_TYPE_7:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_7;
                break;
        }
        return reverbType;
    }


    public void unInit() {
        if (mAudioEffectManager != null) {
            mAudioEffectManager.stopPlayMusic(mBGMId);
            mAudioEffectManager = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
        }
        mIsPlaying = false;
        mIsPlayEnd = false;
        mBGMPlayListenr = null;
    }

    private List<ItemEntity> createAudioChangeItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_original), R.drawable.audio_effect_setting_changetype_original_open, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_0));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_child), R.drawable.audio_effect_setting_changetype_child, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_1));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_luoli), R.drawable.audio_effect_setting_changetype_luoli, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_2));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_dashu), R.drawable.audio_effect_setting_changetype_dashu, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_3));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_metal), R.drawable.audio_effect_setting_changetype_metal, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_4));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_sick), R.drawable.audio_effect_setting_changetype_sick, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_5));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_foreign), R.drawable.audio_effect_setting_changetype_foreign, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_6));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_kunsou), R.drawable.audio_effect_setting_changetype_kunsou, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_7));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_feizai), R.drawable.audio_effect_setting_changetype_feizai, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_8));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_dianliu), R.drawable.audio_effect_setting_changetype_dianliu, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_9));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_machine), R.drawable.audio_effect_setting_changetype_machine, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_10));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_changetype_kongling), R.drawable.audio_effect_setting_changetype_kongling, TRTCCloudDef.TRTC_VOICE_CHANGER_TYPE_11));
        return list;
    }

    private List<ItemEntity> createReverbItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_origin), R.drawable.audio_effect_setting_reverbtype_origin_high, TRTCCloudDef.TRTC_REVERB_TYPE_0));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_ktv), R.drawable.audio_effect_setting_reverbtype_ktv, TRTCCloudDef.TRTC_REVERB_TYPE_1));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_room), R.drawable.audio_effect_setting_reverbtype_room, TRTCCloudDef.TRTC_REVERB_TYPE_2));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_meeting), R.drawable.audio_effect_setting_reverbtype_meeting, TRTCCloudDef.TRTC_REVERB_TYPE_3));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_lowdeep), R.drawable.audio_effect_setting_reverbtype_lowdeep, TRTCCloudDef.TRTC_REVERB_TYPE_4));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_hongliang), R.drawable.audio_effect_setting_reverbtype_hongliang, TRTCCloudDef.TRTC_REVERB_TYPE_5));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_heavymetal), R.drawable.audio_effect_setting_reverbtype_heavymetal, TRTCCloudDef.TRTC_REVERB_TYPE_6));
        list.add(new ItemEntity(getResources().getString(R.string.audio_effect_setting_reverbtype_cixing), R.drawable.audio_effect_setting_reverbtype_cixing, TRTCCloudDef.TRTC_REVERB_TYPE_7));
        return list;
    }

    public class ItemEntity {
        public String mTitle;
        public int    mIconId;
        public int    mType;
        public boolean mIsSelected = false;

        public ItemEntity(String title, int iconId, int type) {
            mTitle = title;
            mIconId = iconId;
            mType = type;
        }
    }

    public class RecyclerViewAdapter extends
            RecyclerView.Adapter<RecyclerViewAdapter.ViewHolder> {

        private Context              context;
        private List<ItemEntity> list;
        private OnItemClickListener onItemClickListener;

        public RecyclerViewAdapter(Context context, List<ItemEntity> list,
                                   OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private CircleImageView mItemImg;
            private TextView mTitleTv;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final ItemEntity model, final int position,
                             final OnItemClickListener listener) {
                mItemImg.setImageResource(model.mIconId);
                mTitleTv.setText(model.mTitle);
                if (model.mIsSelected) {
                    mItemImg.setBorderWidth(4);
                    mItemImg.setBorderColor(getResources().getColor(R.color.white));
                    mTitleTv.setTextColor(getResources().getColor(R.color.white));
                } else {
                    mItemImg.setBorderWidth(0);
                    mItemImg.setBorderColor(getResources().getColor(R.color.transparent));
                    mTitleTv.setTextColor(getResources().getColor(R.color.white_alpha));
                }
                itemView.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(position);
                    }
                });
            }

            private void initView(final View itemView) {
                mItemImg = (CircleImageView) itemView.findViewById(R.id.img_item);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_title);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.audio_main_entry_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(view);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, final int position) {
            ItemEntity item = list.get(position);
            holder.bind(item, position, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

    }

    private List<BGMItemEntity> createBGMItems() {
        List<BGMItemEntity> list = new ArrayList<>();
        list.add(new BGMItemEntity("环绕声测试1", ONLINE_BGM_FIRST, "佚名"));
        list.add(new BGMItemEntity("环绕声测试2", ONLINE_BGM_SECOND, "佚名"));
        list.add(new BGMItemEntity("环绕声测试3", ONLINE_BGM_THIRD, "佚名"));
        return list;
    }

    public class BGMItemEntity {
        public String mTitle;
        public String mActor;
        public String mPath;

        public BGMItemEntity(String title, String path, String actor) {
            mTitle = title;
            mPath = path;
            mActor = actor;
        }
    }

    public class BGMRecyclerViewAdapter extends
            RecyclerView.Adapter<BGMRecyclerViewAdapter.ViewHolder> {

        private Context mContext;
        private List<BGMItemEntity> list;
        private OnItemClickListener onItemClickListener;

        public BGMRecyclerViewAdapter(Context context, List<BGMItemEntity> list,
                                        OnItemClickListener onItemClickListener) {
            this.mContext = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public class ViewHolder extends RecyclerView.ViewHolder {
            private ImageView mItemImg;
            private TextView mTitleTv;
            private TextView mTextActor;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final BGMItemEntity model, final int positon,
                             final OnItemClickListener listener) {
                mItemImg.setImageResource(R.drawable.audio_effect_setting_bgm_play);
                mTitleTv.setText(model.mTitle);
                mTextActor.setText(model.mActor);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        handleBGM(positon, model);
                    }
                });
            }

            private void initView(final View itemView) {
                mItemImg = (ImageView) itemView.findViewById(R.id.iv_bgm_play);
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_bgm_title);
                mTextActor = (TextView) itemView.findViewById(R.id.tv_bgm_actor);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.audio_bgm_entry_item, parent, false);
            ViewHolder viewHolder = new ViewHolder(view);
            return viewHolder;
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            BGMItemEntity item = list.get(position);
            holder.bind(item, position, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    private class BGMListener implements TXAudioEffectManager.TXMusicPlayObserver {

        @Override
        public void onMusicPlayProgress(int id, final long curPtsMS, long durationMS) {
//            Log.d(TAG, "onMusicPlayProgress id " + id + ", curPtsMS = " + curPtsMS + ", durationMS " + durationMS);
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mTvStartTime.setText(formattedTime(curPtsMS /1000) + "");
                }
            });
        }

        @Override
        public void onMusicPlayError(int id, int errCode) {
            Log.d(TAG, "onMusicPlayError id " + id + ", errCode = " + errCode);
        }

        @Override
        public void onMusicPlayFinish(int id) {
            Log.d(TAG, "onMusicPlayFinish id " + id);
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    // 播放完成更新状态
                    mImgbtnBGMPlay.setVisibility(VISIBLE);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_play);
                    mIsPlayEnd = true;
                }
            });
        }
    }

    public void showAudioPanel() {
        mBGMPanel.setVisibility(GONE);
        mMainAudioEffectPanel.setVisibility(VISIBLE);
    }

    public void hideAudioPanel() {
        mBGMPanel.setVisibility(GONE);
        mMainAudioEffectPanel.setVisibility(GONE);
    }

    public void setAudioEffectManager(TXAudioEffectManager audioEffectManager) {
        mAudioEffectManager = audioEffectManager;
    }

    private void handleBGM(int position, final BGMItemEntity model) {
        if (mAudioEffectManager == null) {
            return;
        }
        mAudioEffectManager.stopPlayMusic(mBGMId);
        mBGMId = position;
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mBGMPanel.setVisibility(GONE);
                mMainAudioEffectPanel.setVisibility(VISIBLE);
                mTvBGM.setVisibility(View.GONE);
                mBtnSelectedSong.setVisibility(View.GONE);

                mTvActor.setVisibility(VISIBLE);
                mTvActor.setText(model.mTitle);
                mTvStartTime.setVisibility(VISIBLE);
                mTvTotalTime.setVisibility(VISIBLE);
                mTvTotalTime.setText("/" + formattedTime(mAudioEffectManager.getMusicDurationInMS(model.mPath)/1000) + "");
                mImgbtnBGMPlay.setVisibility(VISIBLE);
                mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
            }
        });
        final TXAudioEffectManager.AudioMusicParam audioMusicParam = new TXAudioEffectManager.AudioMusicParam(position, model.mPath);
        audioMusicParam.publish = true; //上行
        mAudioEffectManager.startPlayMusic(audioMusicParam);
        mBGMPlayListenr = new BGMListener();
        mAudioEffectManager.setMusicObserver(mBGMId, mBGMPlayListenr);
        mIsPlaying = true;

        mImgbtnBGMPlay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsPlayEnd) {
                    mAudioEffectManager.startPlayMusic(audioMusicParam);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
                    mIsPlayEnd = false;
                    mIsPlaying = true;
                    return;
                } else if (mIsPlaying) {
                    mAudioEffectManager.pausePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_play);
                    mIsPlaying = false;
                } else {
                    mAudioEffectManager.resumePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.audio_effect_setting_bgm_pause);
                    mIsPlaying = true;
                }
            }
        });
    }

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private OnAudioEffectPanelHideListener mAudioEffectPanelHideListener;

    public void setOnAudioEffectPanelHideListener(OnAudioEffectPanelHideListener listener) {
        mAudioEffectPanelHideListener = listener;
    }

    public interface OnAudioEffectPanelHideListener {
        void onClosePanel();
    }

    private String formattedTime(long second) {
        String hs, ms, ss, formatTime;

        long h, m, s;
        h = second / 3600;
        m = (second % 3600) / 60;
        s = (second % 3600) % 60;
        if (h < 10) {
            hs = "0" + h;
        } else {
            hs = "" + h;
        }

        if (m < 10) {
            ms = "0" + m;
        } else {
            ms = "" + m;
        }

        if (s < 10) {
            ss = "0" + s;
        } else {
            ss = "" + s;
        }
        if (h > 0) {
            formatTime = hs + ":" + ms + ":" + ss;
        } else {
            formatTime = ms + ":" + ss;
        }
        return formatTime;
    }
}
