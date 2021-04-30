package com.tencent.liteav.demo;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.tencent.liteav.demo.common.widget.ShowTipDialogFragment;
import com.tencent.liteav.login.ui.view.ModifyUserAvatarDialog;
import com.tencent.liteav.demo.common.widget.ModifyUserNameDialog;
import com.tencent.liteav.login.model.ProfileManager;

import de.hdodenhof.circleimageview.CircleImageView;

public class TRTCUserInfoFragment extends Fragment {
    private CircleImageView mIvAvatar;
    private TextView        mTvNickName;
    private TextView        mTvUserId;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_my_info, container, false);
        mIvAvatar   = (CircleImageView) rootView.findViewById(R.id.iv_avatar);
        mTvNickName = (TextView) rootView.findViewById(R.id.tv_show_name);
        mTvUserId   = (TextView) rootView.findViewById(R.id.tv_userid);
        String userId  = ProfileManager.getInstance().getUserModel().userId;
        String userName  = ProfileManager.getInstance().getUserModel().userName;
        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
        Picasso.get().load(userAvatar).into(mIvAvatar);
        mTvNickName.setText(userName);
        mTvUserId.setText(userId);
        rootView.findViewById(R.id.edit_show_name).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ModifyUserNameDialog dialog = new ModifyUserNameDialog(getActivity(), new ModifyUserNameDialog.ModifySuccessListener() {
                    @Override
                    public void onSuccess() {
                        String userName  = ProfileManager.getInstance().getUserModel().userName;
                        mTvNickName.setText(userName);
                    }
                });
                dialog.show();
            }
        });
        rootView.findViewById(R.id.iv_avatar).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ModifyUserAvatarDialog dialog = new ModifyUserAvatarDialog(getActivity(), new ModifyUserAvatarDialog.ModifySuccessListener() {
                    @Override
                    public void onSuccess() {
                        String userAvatar  = ProfileManager.getInstance().getUserModel().userAvatar;
                        Picasso.get().load(userAvatar).into(mIvAvatar);
                    }
                });
                dialog.show();
            }
        });
        rootView.findViewById(R.id.tv_about).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), AboutActivity.class);
                startActivity(intent);
            }
        });
        rootView.findViewById(R.id.tv_privacy_statement).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse("https://privacy.qq.com/yszc-m.htm"));
                startActivity(intent);
            }
        });
        rootView.findViewById(R.id.tv_statement).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showStatementDialog();
            }
        });
        return rootView;
    }

    private void showStatementDialog() {
        final ShowTipDialogFragment dialog = new ShowTipDialogFragment();
        dialog.setMessage(getString(R.string.app_statement_detail));
        dialog.show(getActivity().getFragmentManager(), "confirm_fragment");
    }
}
