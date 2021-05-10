package com.tencent.trtc.speedtest;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.example.speedtest.R;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtc.debug.GenerateTestUserSig;

import java.util.Random;

/**
 * TRTC 网络测试
 *
 * 相关API：
 * - <a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a0dbceb18d61d99ca33e967427dd0a344">startSpeedTest (int sdkAppId, String userId, String userSig)</a>
 */

/**
 * Network Testing
 *
 * Network testing API:
 * - <a href="https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__android.html#a0dbceb18d61d99ca33e967427dd0a344">startSpeedTest (int sdkAppId, String userId, String userSig)</a>
 */
public class SpeedTestActivity extends AppCompatActivity {

    private static final String TAG = "SpeedTestActivity";

    private static final int STATE_SPEED_TEST_IDLE = 0;
    private static final int STATE_SPEED_TEST_TESTING = 1;
    private static final int STATE_SPEED_TEST_FINISHED = 2;

    private static final int SDK_APP_ID = GenerateTestUserSig.SDKAPPID;

    private TRTCCloud       mTRTCCloud;

    private TextView        mTextTestResult;
    private Button          mButtonSpeedTest;
    private EditText        mEditUserId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getSupportActionBar().hide();
        setContentView(R.layout.speedtest_activity);
        initView();
    }

    private void initView() {
        mButtonSpeedTest = findViewById(R.id.btn_speedtest_start);
        mButtonSpeedTest.setOnClickListener(mSpeedTestClickListener);
        mButtonSpeedTest.setTag(STATE_SPEED_TEST_IDLE);
        mTextTestResult = findViewById(R.id.tv_speedtest_result);
        mEditUserId = findViewById(R.id.et_speedtest_user_id);
        mEditUserId.setText(String.valueOf(generateRandomInt(Integer.MAX_VALUE)));
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        releaseModule();
    }

    private void releaseModule() {
        if(mTRTCCloud != null) {
            mTRTCCloud.stopSpeedTest();
            mTRTCCloud.setListener(null);
            mTRTCCloud = null;
            TRTCCloud.destroySharedInstance();
        }
    }

    private void initModule() {
        mTRTCCloud = TRTCCloud.sharedInstance(getApplicationContext());
        mTRTCCloud.setListener(mTRTCCloudListener);
    }

    private final View.OnClickListener mSpeedTestClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (TextUtils.isEmpty(mEditUserId.getText())) {
                Toast.makeText(SpeedTestActivity.this, getResources().getString(R.string.speedtest_input_error_tip), Toast.LENGTH_SHORT).show();
            } else {
                if (mTRTCCloud == null) {
                    initModule();
                }
                String userId = mEditUserId.getText().toString().trim();
                String userSig = GenerateTestUserSig.genTestUserSig(userId);
                handleTriggerSpeedTest(userId, userSig);
            }
        }
    };

    private void handleTriggerSpeedTest(String userId, String userSig) {
        Integer status = (Integer) mButtonSpeedTest.getTag();
        switch (status) {
            case STATE_SPEED_TEST_IDLE: {
                mTRTCCloud.startSpeedTest(SDK_APP_ID, userId, userSig);
                mButtonSpeedTest.setTag(STATE_SPEED_TEST_TESTING);
                mButtonSpeedTest.setText("0%");
                break;
            }
            case STATE_SPEED_TEST_FINISHED: {
                mTextTestResult.setText(null);
                mButtonSpeedTest.setTag(STATE_SPEED_TEST_IDLE);
                mButtonSpeedTest.setText(R.string.speedtest_start);
                break;
            }
            case STATE_SPEED_TEST_TESTING:
            default: {
                break;
            }
        }
    }

    private final TRTCCloudListener mTRTCCloudListener = new TRTCCloudListener() {
        @Override
        public void onSpeedTest(TRTCCloudDef.TRTCSpeedTestResult currentResult, int finishedCount, int totalCount) {
            int percent = finishedCount * 100 /totalCount;
            mTextTestResult.append(currentResult.toString());
            mTextTestResult.append("\n");
            if(percent == 100) {
                mButtonSpeedTest.setTag(STATE_SPEED_TEST_FINISHED);
                mButtonSpeedTest.setText(R.string.speedtest_finish);
            } else {
                mButtonSpeedTest.setTag(STATE_SPEED_TEST_TESTING);
                mButtonSpeedTest.setText(percent + "%");
            }
        }

        @Override
        public void onError(int i, String s, Bundle bundle) {
            mButtonSpeedTest.setTag(STATE_SPEED_TEST_IDLE);
            mButtonSpeedTest.setText(R.string.speedtest_fail);
        }
    };

    private static int generateRandomInt(int bound) {
        Random random = new Random();
        int result = random.nextInt(bound);
        while (result == 0) {
            result = random.nextInt(bound);
        }
        return result;
    }

}