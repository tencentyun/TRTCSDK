package com.tencent.liteav.trtcvoiceroom.ui.widget;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.BottomSheetDialog;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SwitchCompat;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.tencent.liteav.audio.TXAudioEffectManager;
import com.tencent.liteav.trtcvoiceroom.R;
import com.tencent.liteav.trtcvoiceroom.ui.base.EarMonitorInstance;
import com.tencent.liteav.trtcvoiceroom.ui.utils.Utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import de.hdodenhof.circleimageview.CircleImageView;

import static android.view.View.GONE;
import static android.view.View.VISIBLE;


public class AudioEffectPanel extends BottomSheetDialog {

    private static final String TAG = AudioEffectPanel.class.getSimpleName();

    private static final int AUDIO_REVERB_TYPE_0 = 0;
    private static final int AUDIO_REVERB_TYPE_1 = 1;
    private static final int AUDIO_REVERB_TYPE_2 = 2;
    private static final int AUDIO_REVERB_TYPE_3 = 3;
    private static final int AUDIO_REVERB_TYPE_4 = 4;
    private static final int AUDIO_REVERB_TYPE_5 = 5;
    private static final int AUDIO_REVERB_TYPE_6 = 6;
    private static final int AUDIO_REVERB_TYPE_7 = 7;
    private static final int AUDIO_VOICECHANGER_TYPE_0 = 0;
    private static final int AUDIO_VOICECHANGER_TYPE_1 = 1;
    private static final int AUDIO_VOICECHANGER_TYPE_2 = 2;
    private static final int AUDIO_VOICECHANGER_TYPE_3 = 3;
    private static final int AUDIO_VOICECHANGER_TYPE_4 = 4;
    private static final int AUDIO_VOICECHANGER_TYPE_5 = 5;
    private static final int AUDIO_VOICECHANGER_TYPE_6 = 6;
    private static final int AUDIO_VOICECHANGER_TYPE_7 = 7;
    private static final int AUDIO_VOICECHANGER_TYPE_8 = 8;
    private static final int AUDIO_VOICECHANGER_TYPE_9 = 9;
    private static final int AUDIO_VOICECHANGER_TYPE_10 = 10;
    private static final int AUDIO_VOICECHANGER_TYPE_11 = 11;

    private Context mContext;
    private Button    mBtnSelectedSong;
    private ImageView mIvSelectedSong;
    private RecyclerView           mRVAuidoChangeType;
    private RecyclerView           mRVAudioReverbType;
    private RecyclerView           mRVAudioBGM;
    private SeekBar mSbMicVolume;
    private SeekBar mSbBGMVolume;
    private SeekBar mSbPitchLevel;
    private RecyclerViewAdapter    mChangerRVAdapter;
    private RecyclerViewAdapter    mReverbRVAdapter;
    private BGMRecyclerViewAdapter mBGMRVAdapter;
    private List<ItemEntity> mChangerItemEntityList;
    private List<ItemEntity> mReverbItemEntityList;
    private TextView mTVBGMBack;
    private LinearLayout mMainAudioEffectPanel;
    private LinearLayout mBGMPanel;
    private List<BGMItemEntity> mBGMItemEntityList;
    private TextView mTvBGMVolume;
    private TextView mTvPitchLevel;
    private TextView mTvMicVolume;
    private TextView mTvStartTime;
    private TextView mTvTotalTime;
    private TextView mTvBGM;
    private TextView mTvActor;
    private TextView mMusicDescription;
    private View mMusicVolumeGroup;
    private View mMusicToneGroup;
    private SwitchCompat mSwitchMusiceAudiction;
    private LinearLayout mLayoutSelectBGM;
    private LinearLayout mMainPanel;
    private ImageButton mImgbtnBGMPlay;
    private TXAudioEffectManager mAudioEffectManager;
    private BGMListener mBGMPlayListenr;
    private static final String ONLINE_BGM_FIRST = "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3";
    private static final String ONLINE_BGM_SECOND = "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3";
    private static final String ONLINE_BGM_THIRD = "https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3";

    private int     mBGMId     = -1;
    private float   mPitch     = 0;
    private boolean mIsPlaying = false;
    private boolean mIsPause   = false;
    private boolean mIsPlayEnd = false;

    private int     mBGMVolume = 100;

    private int mVoiceChangerPosition = 0;
    private int mVoiceReverbPosition = 0;

    private BottomSheetBehavior mBottomSheetBehavior;


    public AudioEffectPanel(@NonNull Context context) {
        super(context, R.style.TRTCVoiceRoomDialogTheme);
        setContentView(R.layout.trtcvoiceroom_audio_effect_panel);
        mContext = context;
        initView();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setLayout(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Override
    protected void onStart() {
        super.onStart();
        getBottomSheetBehavior();
        mBottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
    }

    private BottomSheetBehavior getBottomSheetBehavior() {
        if (mBottomSheetBehavior != null) {
            return mBottomSheetBehavior;
        }

        View view = getWindow().findViewById(android.support.design.R.id.design_bottom_sheet);
        if (view == null) {
            return null;
        }
        mBottomSheetBehavior = BottomSheetBehavior.from(view);
        return mBottomSheetBehavior;
    }

    public void hideManagerView() {
        mLayoutSelectBGM.setVisibility(GONE);
        mMusicVolumeGroup.setVisibility(GONE);
        mMusicToneGroup.setVisibility(GONE);
    }

    private void initView() {
        mMainPanel = (LinearLayout) findViewById(R.id.ll_panel);
        mSwitchMusiceAudiction = (SwitchCompat) findViewById(R.id.switch_music_audition);
        mTvBGMVolume =  (TextView) findViewById(R.id.tv_bgm_volume);
        mTvMicVolume = (TextView) findViewById(R.id.tv_mic_volume);
        mTvPitchLevel = (TextView) findViewById(R.id.tv_pitch_level);
        mTvActor = (TextView) findViewById(R.id.tv_actor);
        mTvStartTime = (TextView) findViewById(R.id.tv_bgm_start_time);
        mTvTotalTime = (TextView) findViewById(R.id.tv_bgm_end_time);
        mMusicDescription = (TextView) findViewById(R.id.music_description);
        mImgbtnBGMPlay = (ImageButton) findViewById(R.id.ib_audio_bgm_play);
        mTvBGM = (TextView) findViewById(R.id.tv_bgm);
        mMusicVolumeGroup = findViewById(R.id.ll_music_volume_change);
        mMusicToneGroup = findViewById(R.id.ll_music_tone_change);
        mLayoutSelectBGM = (LinearLayout) findViewById(R.id.ll_select_bgm);
        mLayoutSelectBGM.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMainAudioEffectPanel.setVisibility(GONE);
                mBGMPanel.setVisibility(VISIBLE);
            }
        });
        mBtnSelectedSong = (Button) findViewById(R.id.audio_btn_select_song);
        mIvSelectedSong = (ImageView) findViewById(R.id.iv_select_song);
        mBtnSelectedSong.setOnClickListener(new View.OnClickListener() {
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
                mBGMVolume = progress;
                if (mAudioEffectManager != null && mBGMId != -1) {
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
                mPitch = pitch;
                if (mAudioEffectManager != null && mBGMId != -1) {
                    Log.d(TAG, "setMusicPitch: mBGMId -> " + mBGMId + ", pitch -> " + pitch);
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

        mTVBGMBack = (TextView) findViewById(R.id.tv_back);
        mTVBGMBack.setOnClickListener(new View.OnClickListener() {
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
                mChangerItemEntityList.get(position).mIsSelected = true;
                mChangerItemEntityList.get(mVoiceChangerPosition).mIsSelected = false;
                mVoiceChangerPosition = position;
                mChangerRVAdapter.notifyDataSetChanged();
            }
        });
        mChangerItemEntityList.get(0).mIsSelected = true;
        mChangerRVAdapter.notifyDataSetChanged();
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
                mReverbItemEntityList.get(position).mIsSelected = true;
                mReverbItemEntityList.get(mVoiceReverbPosition).mIsSelected = false;
                mVoiceReverbPosition = position;
                mReverbRVAdapter.notifyDataSetChanged();
            }
        });
        mReverbItemEntityList.get(0).mIsSelected = true;
        mReverbRVAdapter.notifyDataSetChanged();
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
        mSwitchMusiceAudiction.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                EarMonitorInstance.getInstance().updateEarMonitorState(isChecked);
            }
        });

        findViewById(R.id.link_music).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://cloud.tencent.com/product/ame"));
                mContext.startActivity(intent);
            }
        });
        if (!isZh(mContext)) {
            mMusicDescription.setTextSize(TypedValue.COMPLEX_UNIT_SP, 11);
        }
    }

    private TXAudioEffectManager.TXVoiceChangerType translateChangerType(int type) {
        TXAudioEffectManager.TXVoiceChangerType changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
        switch (type) {
            case AUDIO_VOICECHANGER_TYPE_0:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_0;
                break;
            case AUDIO_VOICECHANGER_TYPE_1:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_1;
                break;
            case AUDIO_VOICECHANGER_TYPE_2:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_2;
                break;
            case AUDIO_VOICECHANGER_TYPE_3:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_3;
                break;
            case AUDIO_VOICECHANGER_TYPE_4:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_4;
                break;
            case AUDIO_VOICECHANGER_TYPE_5:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_5;
                break;
            case AUDIO_VOICECHANGER_TYPE_6:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_6;
                break;
            case AUDIO_VOICECHANGER_TYPE_7:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_7;
                break;
            case AUDIO_VOICECHANGER_TYPE_8:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_8;
                break;
            case AUDIO_VOICECHANGER_TYPE_9:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_9;
                break;
            case AUDIO_VOICECHANGER_TYPE_10:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_10;
                break;
            case AUDIO_VOICECHANGER_TYPE_11:
                changerType = TXAudioEffectManager.TXVoiceChangerType.TXLiveVoiceChangerType_11;
                break;
        }
        return changerType;
    }

    private TXAudioEffectManager.TXVoiceReverbType translateReverbType(int type) {
        TXAudioEffectManager.TXVoiceReverbType reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
        switch (type) {
            case AUDIO_REVERB_TYPE_0:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_0;
                break;
            case AUDIO_REVERB_TYPE_1:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_1;
                break;
            case AUDIO_REVERB_TYPE_2:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_2;
                break;
            case AUDIO_REVERB_TYPE_3:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_3;
                break;
            case AUDIO_REVERB_TYPE_4:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_4;
                break;
            case AUDIO_REVERB_TYPE_5:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_5;
                break;
            case AUDIO_REVERB_TYPE_6:
                reverbType = TXAudioEffectManager.TXVoiceReverbType.TXLiveVoiceReverbType_6;
                break;
            case AUDIO_REVERB_TYPE_7:
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
        mIsPause = false;
        mIsPlayEnd = false;
        mBGMPlayListenr = null;
    }

    @Override
    public void show() {
        super.show();
        boolean isOpen = EarMonitorInstance.getInstance().ismEarMonitorOpen();
        mSwitchMusiceAudiction.setChecked(isOpen);
    }

    public void stopPlay() {
        if (mAudioEffectManager != null) {
            mAudioEffectManager.stopPlayMusic(mBGMId);
        }
    }

    private List<ItemEntity> createAudioChangeItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_origin), R.drawable.trtcvoiceroom_no_select_normal, R.drawable.trtcvoiceroom_no_select_hover, AUDIO_VOICECHANGER_TYPE_0));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_child), R.drawable.trtcvoiceroom_changetype_child_normal,  R.drawable.trtcvoiceroom_changetype_child_hover, AUDIO_VOICECHANGER_TYPE_1));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_luoli), R.drawable.trtcvoiceroom_changetype_luoli_normal, R.drawable.trtcvoiceroom_changetype_luoli_hover, AUDIO_VOICECHANGER_TYPE_2));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_dashu), R.drawable.trtcvoiceroom_changetype_dashu_normal, R.drawable.trtcvoiceroom_changetype_dashu_hover, AUDIO_VOICECHANGER_TYPE_3));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_changetype_kongling), R.drawable.trtcvoiceroom_reverbtype_kongling_normal, R.drawable.trtcvoiceroom_reverbtype_kongling_hover, AUDIO_VOICECHANGER_TYPE_11));
        return list;
    }

    private List<ItemEntity> createReverbItems() {
        List<ItemEntity> list = new ArrayList<>();
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_origin), R.drawable.trtcvoiceroom_no_select_normal, R.drawable.trtcvoiceroom_no_select_hover, AUDIO_REVERB_TYPE_0));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_ktv), R.drawable.trtcvoiceroom_reverbtype_ktv_normal, R.drawable.trtcvoiceroom_reverbtype_ktv_hover, AUDIO_REVERB_TYPE_1));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_lowdeep), R.drawable.trtcvoiceroom_reverbtype_lowdeep_normal, R.drawable.trtcvoiceroom_reverbtype_lowdeep_hover, AUDIO_REVERB_TYPE_4));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_heavymetal), R.drawable.trtcvoiceroom_reverbtype_heavymetal_normal, R.drawable.trtcvoiceroom_reverbtype_heavymetal_hover, AUDIO_REVERB_TYPE_6));
        list.add(new ItemEntity(mContext.getResources().getString(R.string.audio_effect_setting_reverbtype_hongliang), R.drawable.trtcvoiceroom_reverbtype_hongliang_normal, R.drawable.trtcvoiceroom_reverbtype_hongliang_hover, AUDIO_REVERB_TYPE_5));
        return list;
    }

    public class ItemEntity {
        public String mTitle;
        public int    mIconId;
        public int    mSelectIconId;
        public int    mType;
        public boolean mIsSelected = false;

        public ItemEntity(String title, int iconId, int selectIconId, int type) {
            mTitle = title;
            mIconId = iconId;
            mSelectIconId = selectIconId;
            mType = type;
        }
    }

    public class RecyclerViewAdapter extends
            RecyclerView.Adapter<RecyclerViewAdapter.ViewHolder> {

        private Context context;
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
                    mItemImg.setImageResource(model.mSelectIconId);
                    mTitleTv.setTextColor(mContext.getResources().getColor(R.color.trtcvoiceroom_color_blue));
                } else {
                    mItemImg.setImageResource(model.mIconId);
                    mTitleTv.setTextColor(mContext.getResources().getColor(R.color.trtcvoiceroom_dark_black));
                }
                itemView.setOnClickListener(new View.OnClickListener() {
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
            Context context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.trtcvoiceroom_audio_main_entry_item, parent, false);
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
        list.add(new BGMItemEntity(mContext.getString(R.string.trtcvoiceroom_bg_music_positive_happy), ONLINE_BGM_FIRST));
        list.add(new BGMItemEntity(mContext.getString(R.string.trtcvoiceroom_bg_music_sad_cinematic_piano), ONLINE_BGM_SECOND));
        list.add(new BGMItemEntity(mContext.getString(R.string.trtcvoiceroom_bg_music_wonder_world), ONLINE_BGM_THIRD));
        return list;
    }

    public class BGMItemEntity {
        public String mTitle;
        public String mPath;

        public BGMItemEntity(String title, String path) {
            mTitle = title;
            mPath = path;
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
            private Button mItemImg;
            private TextView mTitleTv;
            private TextView mTextActor;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final BGMItemEntity model, final int positon,
                             final OnItemClickListener listener) {
                mTitleTv.setText(model.mTitle);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        handleBGM(positon, model);
                    }
                });
            }

            private void initView(final View itemView) {
                mTitleTv = (TextView) itemView.findViewById(R.id.tv_bgm_title);
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View view = inflater.inflate(R.layout.trtcvoiceroom_audio_bgm_entry_item, parent, false);
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
        public void onStart(int i, int i1) {

        }

        @Override
        public void onPlayProgress(int id, final long curPtsMS, long durationMS) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mTvStartTime.setText(Utils.formattedTime(curPtsMS /1000) + "");
                }
            });
        }

        @Override
        public void onComplete(int id, int i1) {
            Log.d(TAG, "onMusicPlayFinish id " + id);
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    // 播放完成更新状态
                    mImgbtnBGMPlay.setVisibility(VISIBLE);
                    mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_play);
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

    public void reset() {
        mAudioEffectManager.stopPlayMusic(mBGMId);
        mBGMId = -1;
        mIsPlaying = false;
        mIsPause = false;
        mIsPlayEnd = false;

        mSbMicVolume.setProgress(100);
        mTvMicVolume.setText("100");

        mBGMVolume = 100;
        mSbBGMVolume.setProgress(mBGMVolume);
        mTvBGMVolume.setText(mBGMVolume + "");

        mPitch = 0;
        mSbPitchLevel.setProgress(50);
        mTvPitchLevel.setText("50");

        mBtnSelectedSong.setVisibility(VISIBLE);
        mIvSelectedSong.setVisibility(VISIBLE);
        mTvBGM.setVisibility(VISIBLE);
        mTvStartTime.setVisibility(GONE);
        mTvTotalTime.setVisibility(GONE);
        mImgbtnBGMPlay.setVisibility(GONE);

        mChangerItemEntityList.get(mVoiceChangerPosition).mIsSelected = false;
        mChangerRVAdapter.notifyDataSetChanged();
        mVoiceChangerPosition = 0;

        mReverbItemEntityList.get(mVoiceReverbPosition).mIsSelected = false;
        mReverbRVAdapter.notifyDataSetChanged();
        mVoiceReverbPosition = 0;

        if (mAudioEffectManager != null) {
            Log.d(TAG, "select changer type1 " + translateChangerType(mVoiceChangerPosition));
            mAudioEffectManager.setVoiceChangerType(translateChangerType(mVoiceChangerPosition));
            mAudioEffectManager.setVoiceReverbType(translateReverbType(mVoiceReverbPosition));
        }
    }

    public void pauseBGM() {
        if (!mIsPlaying) {
            return;
        }
        mAudioEffectManager.pausePlayMusic(mBGMId);
        mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_play);
        mIsPlaying = false;
    }

    public void resumeBGM() {
        Log.i(TAG, "resumeBGM: mIsPlayEnd -> " + mIsPlayEnd + ", mIsPlaying -> " + mIsPlaying);
        if (!mIsPlayEnd && !mIsPlaying && !mIsPause) {
            mAudioEffectManager.resumePlayMusic(mBGMId);
            mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_pause);
            mIsPlaying = true;
        }
    }

    private void handleBGM(int position, final BGMItemEntity model) {
        Log.d(TAG, "handleBGM position " + position + ", mAudioEffectManager " + mAudioEffectManager);
        if (mAudioEffectManager == null) {
            return;
        }
        if (mBGMId != -1) { // 已开始播放音乐，需要先停止上一次正在播放的音乐
            mAudioEffectManager.stopPlayMusic(mBGMId);
        }
        mBGMId = position;
        // 开始播放音乐时，无论是否首次均需重新设置变调和音量，因为音乐id发生了变化
        mAudioEffectManager.setMusicPitch(position, mPitch);
        mAudioEffectManager.setMusicPlayoutVolume(position, mBGMVolume);
        mAudioEffectManager.setMusicPublishVolume(position, mBGMVolume);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mBGMPanel.setVisibility(GONE);
                mMainAudioEffectPanel.setVisibility(VISIBLE);
                mTvBGM.setVisibility(GONE);
                mBtnSelectedSong.setVisibility(GONE);
                mIvSelectedSong.setVisibility(GONE);
                mTvActor.setVisibility(VISIBLE);
                mTvActor.setText(model.mTitle);
                mTvStartTime.setVisibility(VISIBLE);
                mTvTotalTime.setVisibility(VISIBLE);
                mTvTotalTime.setText("/" + Utils.formattedTime(mAudioEffectManager.getMusicDurationInMS(model.mPath)/1000) + "");
                mImgbtnBGMPlay.setVisibility(VISIBLE);
                mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_pause);
            }
        });
        final TXAudioEffectManager.AudioMusicParam audioMusicParam = new TXAudioEffectManager.AudioMusicParam(position, model.mPath);
        audioMusicParam.publish = true; //上行
        mAudioEffectManager.startPlayMusic(audioMusicParam);
        mBGMPlayListenr = new BGMListener();
        mAudioEffectManager.setMusicObserver(mBGMId, mBGMPlayListenr);
        mIsPlaying = true;
        mIsPause = false;

        mImgbtnBGMPlay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIsPlayEnd) {
                    mAudioEffectManager.startPlayMusic(audioMusicParam);
                    mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_pause);
                    mIsPlayEnd = false;
                    mIsPlaying = true;
                    mIsPause = false;
                } else if (mIsPlaying) {
                    mAudioEffectManager.pausePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_play);
                    mIsPlaying = false;
                    mIsPause = true;
                } else {
                    mAudioEffectManager.resumePlayMusic(mBGMId);
                    mImgbtnBGMPlay.setImageResource(R.drawable.trtcvoiceroom_bgm_pause);
                    mIsPlaying = true;
                    mIsPause = false;
                }
            }
        });
    }

    public boolean isZh(Context context) {
        Locale locale = context.getResources().getConfiguration().locale;
        String language = locale.getLanguage();
        if (language.endsWith("zh"))
            return true;
        else
            return false;
    }

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private OnAudioEffectPanelHideListener mAudioEffectPanelHideListener;

    public void setOnAudioEffectPanelHideListener(OnAudioEffectPanelHideListener listener) {
        mAudioEffectPanelHideListener = listener;
    }

    public interface OnAudioEffectPanelHideListener {
        void onClosePanel();
    }

    public void setPanelBackgroundColor(int color) {
        mMainPanel.setBackgroundColor(color);
    }

    public void setPanelBackgroundResource(int resId) {
        mMainPanel.setBackgroundResource(resId);
    }

    public void setPanelBackgroundDrawable(Drawable drawable) {
        mMainPanel.setBackground(drawable);
    }

    public void initPanelDefaultBackground() {
        mMainPanel.setBackground(mContext.getResources().getDrawable(R.drawable.audio_effect_setting_bg_gradient));
    }
}
