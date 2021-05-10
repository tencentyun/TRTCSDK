package com.tencent.trtc.pushcdn;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

/**
 * TRTC CDN发布角色选择页
 *
 * - 可以选择：
 * - 1.以主播身份进房进行推流和CDN发布{@link PushCDNAnchorActivity}
 * - 2.以观众身份输入CDN地址直接播放观看{@link PushCDNAudienceActivity}
 */

/**
 * Role Selection for CDN Publish/Playback
 *
 * - A user can:
 * - 1. Enter the room as an anchor and push streams via CDNs: {@link PushCDNAnchorActivity
 * - 2. Enter a CDN address as audience to play back streams: {@link PushCDNAudienceActivity}
 */
public class PushCDNSelectRoleActivity extends AppCompatActivity {

    private TextView    mTextAnchorChoice;
    private TextView    mTextAudienceChoice;
    private Button      mButtonConfirm;

    private static final int ROLE_ANCHOR = 1;
    private static final int ROLE_AUDIENCE = 2;

    private int mCurrentRole = ROLE_ANCHOR;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getSupportActionBar().hide();
        setContentView(R.layout.pushcdn_activity_select_role);
        initView();
    }

    private void initView() {
        mTextAnchorChoice = findViewById(R.id.tv_pushcdn_anchor_choice);
        mTextAnchorChoice.setOnClickListener(mOnTextAnchorChoiceClickListener);
        mTextAudienceChoice = findViewById(R.id.tv_pushcdn_audience_choice);
        mTextAudienceChoice.setOnClickListener(mOnTextAudienceChoiceClickListener);
        mButtonConfirm = findViewById(R.id.btn_push_cdn_select_role_choice_confirm);
        mButtonConfirm.setOnClickListener(mOnButtonChoiceConfirmClickListener);

    }

    private final View.OnClickListener mOnTextAnchorChoiceClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            mCurrentRole = ROLE_ANCHOR;
            mTextAnchorChoice.setBackground(getResources().getDrawable(R.drawable.pushcdn_selectrole_bg_circle_green));
            mTextAudienceChoice.setBackground(getResources().getDrawable(R.drawable.pushcdn_selectrole_bg_circle_gray));
        }
    };

    private final View.OnClickListener mOnTextAudienceChoiceClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            mCurrentRole = ROLE_AUDIENCE;
            mTextAudienceChoice.setBackground(getResources().getDrawable(R.drawable.pushcdn_selectrole_bg_circle_green));
            mTextAnchorChoice.setBackground(getResources().getDrawable(R.drawable.pushcdn_selectrole_bg_circle_gray));
        }
    };

    private final View.OnClickListener mOnButtonChoiceConfirmClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            dealWithChoiceConfirm(mCurrentRole);
        }
    };

    private void dealWithChoiceConfirm(int currentRole) {
        if(currentRole == ROLE_ANCHOR) {
            Intent intent = new Intent(this, PushCDNAnchorActivity.class);
            startActivity(intent);
        } else if (currentRole == ROLE_AUDIENCE) {
            Intent intent = new Intent(this, PushCDNAudienceActivity.class);
            startActivity(intent);
        }
    }
}