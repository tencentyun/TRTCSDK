package com.tencent.trtc.pushcdn;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.example.basic.TRTCBaseActivity;
import com.tencent.rtmp.ITXLivePlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXLivePlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtc.debug.Constant;
import com.tencent.trtc.debug.GenerateTestUserSig;

/**
 * TRTC CDN发布观众页
 *
 * - 可以直接输入stream id进行播放{@link TXLivePlayer#startPlay(String, int)}
 * - 播放器API见<a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXLivePlayer__android.html">TXLivePlayer</a>
 */

/**
 * CDN Playback
 *
 * - Enter the stream ID to play back streams: {@link TXLivePlayer#startPlay(String, int)}
 * - To learn about player APIs, see <a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TXLivePlayer__android.html">TXLivePlayer</a>.
 */
public class PushCDNAudienceActivity extends TRTCBaseActivity {

    private static final String TAG = "PushCDNAudienceActivity";

    private TXLivePlayer        mTXLivePlayer;
    private TXCloudVideoView    mTXCVideoView;
    private Button              mButtonStartStop;
    private EditText            mEditStreamId;

    private boolean mIsPlaying;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getSupportActionBar().hide();
        setContentView(R.layout.pushcdn_activity_audience);
        init();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        release();
    }

    private void init() {
        initView();
        initModule();
    }

    private void release() {
        if(mTXLivePlayer != null) {
            if(mIsPlaying) {
                mTXLivePlayer.stopPlay(true);
            }
        }
    }

    private void initView() {
        mTXCVideoView = findViewById(R.id.videoview_pushcdn_audience);
        mButtonStartStop = findViewById(R.id.btn_pushcdn_audience_play_cdn_stream);
        mEditStreamId = findViewById(R.id.et_pushcdn_audience_stream_id);
        mButtonStartStop.setOnClickListener(mOnStartStopClickListener);
    }

    private void initModule() {
        mTXLivePlayer = new TXLivePlayer(this);
        mTXLivePlayer.setPlayerView(mTXCVideoView);
        mTXLivePlayer.setRenderMode(TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION);
        mTXLivePlayer.setPlayListener(mPlayListener);
    }

    private View.OnClickListener mOnStartStopClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if(mIsPlaying) {
                mTXLivePlayer.stopPlay(true);
                mButtonStartStop.setText(R.string.pushcdn_audience_start_play);
                mIsPlaying = false;
            } else {
                if(TextUtils.isEmpty(mEditStreamId.getText())) {
                    Toast.makeText(PushCDNAudienceActivity.this, R.string.pushcdn_audience_empty_stream_id_tip, Toast.LENGTH_SHORT).show();
                } else {
                    String streamId = mEditStreamId.getText().toString().trim();
                    /**
                     * 需要首先开启CDN旁路直播，再将URL_PLACEHOLDER替换成您的播放域名
                     * 具体可参考：https://cloud.tencent.com/document/product/647/16826
                     */
                    String playUrl = "http://" + GenerateTestUserSig.CDN_DOMAIN_NAME+ "/live/" + streamId + ".flv";
                    mTXLivePlayer.startPlay(playUrl, TXLivePlayer.PLAY_TYPE_LIVE_FLV);
                }
            }
        }
    };

    private ITXLivePlayListener mPlayListener = new ITXLivePlayListener() {
        @Override
        public void onPlayEvent(int event, Bundle bundle) {
            switch (event) {
                case TXLiveConstants.PLAY_EVT_PLAY_BEGIN: {
                    mIsPlaying = true;
                    mButtonStartStop.setText(R.string.pushcdn_audience_stop_play);
                    break;
                }
                default: {
                    break;
                }
            }
        }

        @Override
        public void onNetStatus(Bundle bundle) {

        }
    };

    @Override
    protected void onPermissionGranted() {

    }
}