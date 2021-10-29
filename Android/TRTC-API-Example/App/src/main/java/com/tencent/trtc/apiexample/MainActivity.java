package com.tencent.trtc.apiexample;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.trtc.audiocall.AudioCallingEnterActivity;
import com.tencent.trtc.audioeffect.SetAudioEffectActivity;
import com.tencent.trtc.audioquality.SetAudioQualityActivity;
import com.tencent.trtc.bgm.SetBGMActivity;
import com.tencent.trtc.pk.RoomPKActivity;
import com.tencent.trtc.customcamera.CustomCameraActivity;
import com.tencent.trtc.joinmultipleroom.JoinMultipleRoomActivity;
import com.tencent.trtc.live.LiveEnterActivity;
import com.tencent.trtc.localrecord.LocalRecordActivity;
import com.tencent.trtc.mediashare.LocalVideoShareActivity;
import com.tencent.trtc.pushcdn.PushCDNSelectRoleActivity;
import com.tencent.trtc.renderparams.SetRenderParamsActivity;
import com.tencent.trtc.screenshare.ScreenEntranceActivity;
import com.tencent.trtc.seimessage.SendAndReceiveSEIMessageActivity;
import com.tencent.trtc.speedtest.SpeedTestActivity;
import com.tencent.trtc.stringroomid.StringRoomIdActivity;
import com.tencent.trtc.switchroom.SwitchRoomActivity;
import com.tencent.trtc.thirdbeauty.ThirdBeautyActivity;
import com.tencent.trtc.videocall.VideoCallingEnterActivity;
import com.tencent.trtc.videoquality.SetVideoQualityActivity;
import com.tencent.trtc.voicechatoom.VoiceChatRoomEnterActivity;
import com.tencent.trtc.thirdbeauty.ThirdBeautyEnterActivity;

/**
 * TRTC API-Example 主页面
 *
 * 其中包含
 * 基础功能模块如下：
 * - 语音通话模块{@link AudioCallingEnterActivity}
 * - 视频通话模块{@link VideoCallingEnterActivity}
 * - 视频互动直播模块{@link LiveEnterActivity}
 * - 语音互动直播模块{@link VoiceChatRoomEnterActivity}
 * - 直播分享模块{@link ScreenEntranceActivity}
 *
 * 进阶功能模块如下：
 * - 字符串房间号{@link StringRoomIdActivity}
 * - 画质设定{@link SetVideoQualityActivity}
 * - 音质设定{@link SetAudioQualityActivity}
 * - 渲染控制{@link SetRenderParamsActivity}
 * - 网络测速{@link SpeedTestActivity}
 * - CDN发布{@link PushCDNSelectRoleActivity}
 * - 自定义视频采集&渲染{@link CustomCameraActivity}
 * - 设置音效{@link SetAudioEffectActivity}
 * - 设置背景音乐{@link SetBGMActivity}
 * - 本地视频分享{@link LocalVideoShareActivity}
 * - 本地媒体录制{@link LocalRecordActivity}
 * - 加入多个房间{@link JoinMultipleRoomActivity}
 * - 收发SEI消息{@link SendAndReceiveSEIMessageActivity}
 * - 快速切换房间{@link SwitchRoomActivity}
 * - 跨房PK{@link RoomPKActivity}
 * - 第三方美颜{@link ThirdBeautyEnterActivity}
 */
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        getSupportActionBar().hide();

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                findViewById(R.id.launch_view).setVisibility(View.GONE);
            }
        }, 1000);

        findViewById(R.id.ll_audio_call).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, AudioCallingEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_video_call).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, VideoCallingEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_live).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LiveEnterActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_voice_chat_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, VoiceChatRoomEnterActivity.class);
                startActivity(intent);

            }
        });

        findViewById(R.id.ll_screen_share).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, ScreenEntranceActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_string_room_id).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, StringRoomIdActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_video_quality).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SetVideoQualityActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_audio_quality).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SetAudioQualityActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_render_params).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SetRenderParamsActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_speed_test).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SpeedTestActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_pushcdn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, PushCDNSelectRoleActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_custom_camera).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, CustomCameraActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_audio_effect).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SetAudioEffectActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_audio_bgm).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SetBGMActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_local_video_share).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LocalVideoShareActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_local_record).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, LocalRecordActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_join_multiple_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, JoinMultipleRoomActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_sei_message).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SendAndReceiveSEIMessageActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_switch_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SwitchRoomActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_connect_other_room).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, RoomPKActivity.class);
                startActivity(intent);
            }
        });

        findViewById(R.id.ll_third_beauty).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, ThirdBeautyEnterActivity.class);
                startActivity(intent);
            }
        });
    }
}
