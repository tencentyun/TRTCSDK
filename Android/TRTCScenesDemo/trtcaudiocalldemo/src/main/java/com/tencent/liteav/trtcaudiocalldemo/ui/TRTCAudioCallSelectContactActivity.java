package com.tencent.liteav.trtcaudiocalldemo.ui;

import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.blankj.utilcode.util.CollectionUtils;
import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.SPUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.google.android.flexbox.FlexboxItemDecoration;
import com.google.android.flexbox.FlexboxLayoutManager;
import com.google.gson.reflect.TypeToken;
import com.tencent.liteav.login.model.ProfileManager;
import com.tencent.liteav.login.model.UserModel;
import com.tencent.liteav.trtcaudiocalldemo.R;
import com.tencent.liteav.trtcaudiocalldemo.ui.adapter.SearchContactAdapter;
import com.tencent.liteav.trtcaudiocalldemo.ui.adapter.SelectedContactAdapter;

import java.util.ArrayList;
import java.util.List;

/**
 * 联系人选择Activity，可以通过此界面搜索已注册用户，并发起通话，支持多选；
 */
public class TRTCAudioCallSelectContactActivity extends BaseActivity {
    private static final String TAG = "SelectContactActivity";

    private static final String SEARCH_PER_NAME = "search_contact";        //保存信息的SharedPreferences名称
    private static final String SEARCH_USER_KEY = "search_user_model";     //SharedPreferences中"最近搜索联系人"的Key

    private Button                  mButtonComplete;                //导航栏中的完成按钮
    private Toolbar                 mNavigationBar;                 //导航栏，主要负责监听导航栏返回按钮
    private EditText                mEditSearchUser;                //输入手机号码的编辑文本框
    private TextView                mTextSearchUser;                //开始搜索用户的按钮
    private RecyclerView            mRecyclerRecentSearch;          //显示最近搜索过的联系人列表控件
    private RecyclerView            mRecyclerSelectedContacts;      //显示当前选中联系人的列表控件
    private ConstraintLayout        mLayoutTips;                    //显示搜索提示信息
    private TextView                mTextRecentSearchTitle;         //显示最近搜索的标题信息
    private ImageView               mImageClearSearch;              //清除搜索框文本按钮
    private UserModel               mSelfModel;                     //表示当前用户的UserModel
    private SearchContactAdapter    mSearchContactAdapter;          //mRecentSearchRecycler的适配器
    private SelectedContactAdapter  mSelectedContactAdapter;        //mSelectedContactsRecycler的适配器

    private List<UserModel>         mSelectedContactsList = new ArrayList<>();      //保存当前选中的联系人
    private List<ContactsEntity>    mRecentSearchList = new ArrayList<>();          //保存最近搜索过的联系人

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trtcaudiocall_activity_select_contact);
        initView();

        mSelfModel = ProfileManager.getInstance().getUserModel();
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateSearchRecycler();
    }

    private void initView() {
        mLayoutTips = (ConstraintLayout) findViewById(R.id.cl_tips);
        mTextRecentSearchTitle = (TextView) findViewById(R.id.tv_search_tag);

        initNavigationBar();
        initCompleteText();
        initSearchUserEdit();
        initSearchUserText();
        initRecentSearchRecycler();
        initSelectedContactsRecycler();
        initClearSearchImage();
    }

    private void initSelectedContactsRecycler() {
        mRecyclerSelectedContacts = (RecyclerView) findViewById(R.id.rv_selected_contacts);

        FlexboxLayoutManager flexboxLayoutManager = new FlexboxLayoutManager(this);
        FlexboxItemDecoration flexboxItemDecoration = new FlexboxItemDecoration(this);
        flexboxItemDecoration.setDrawable(getResources().getDrawable(R.drawable.trtcaudiocall_bg_divider));

        mRecyclerSelectedContacts.addItemDecoration(flexboxItemDecoration);
        mRecyclerSelectedContacts.setLayoutManager(flexboxLayoutManager);

        mSelectedContactAdapter = new SelectedContactAdapter(this, mSelectedContactsList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (position < mSelectedContactsList.size() && position >= 0) {
                    UserModel userModel = mSelectedContactsList.get(position);
                    removeSelectedContacts(userModel.userId);
                }
                completeBtnEnable();
            }
        });
        mRecyclerSelectedContacts.setAdapter(mSelectedContactAdapter);
    }

    private void initRecentSearchRecycler() {
        mRecyclerRecentSearch = (RecyclerView) findViewById(R.id.rv_recent_search);

        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        mRecyclerRecentSearch.setLayoutManager(linearLayoutManager);

        mSearchContactAdapter = new SearchContactAdapter(this, mRecentSearchList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (position < mRecentSearchList.size() && position >= 0) {
                    ContactsEntity entity = mRecentSearchList.get(position);
                    if (!entity.isSelected) {
                        addSelectedContacts(entity);
                    } else {
                        removeSelectedContacts(entity.userModel.userId);
                    }
                    completeBtnEnable();
                }
            }
        });
        mRecyclerRecentSearch.setAdapter(mSearchContactAdapter);

    }

    private void initSearchUserEdit() {
        mEditSearchUser = (EditText) findViewById(R.id.et_search_user);

        mEditSearchUser.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    searchContactsByPhone(v.getText().toString());
                    return true;
                }
                return false;
            }
        });

        mEditSearchUser.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence text, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence text, int start, int before, int count) {
                if (text.length() == 0) {
                    updateRecentSearchRecycler();
                } else {
                    mImageClearSearch.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }

    private void initSearchUserText() {
        mTextSearchUser = (TextView) findViewById(R.id.tv_search);

        mTextSearchUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchContactsByPhone(mEditSearchUser.getText().toString());
            }
        });
    }

    private void initCompleteText() {
        mButtonComplete = (Button) findViewById(R.id.btn_complete);
        mButtonComplete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (CollectionUtils.isEmpty(mSelectedContactsList)) {
                    ToastUtils.showShort(R.string.trtcaudiocall_toast_select_contact);
                    return;
                }
                TRTCAudioCallActivity.startCallSomeone(TRTCAudioCallSelectContactActivity.this, mSelectedContactsList);
            }
        });
        completeBtnEnable();

    }

    private void initNavigationBar() {
        mNavigationBar = (Toolbar) findViewById(R.id.toolbar);
        mNavigationBar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    private void initClearSearchImage(){
        mImageClearSearch = (ImageView) findViewById(R.id.iv_clear_search);
        mImageClearSearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mEditSearchUser.setText("");
            }
        });
    }

    private void handleViewVisibility(){

        if(mEditSearchUser.length()!=0 ){
            mImageClearSearch.setVisibility(View.VISIBLE);
        } else {
            mImageClearSearch.setVisibility(View.GONE);
        }

        if(mRecentSearchList.size()!=0){
            mTextRecentSearchTitle.setVisibility(View.VISIBLE);
        } else {
            mTextRecentSearchTitle.setVisibility(View.GONE);
        }

        if (mEditSearchUser.length()==0 && mRecentSearchList.size()==0){
            mLayoutTips.setVisibility(View.VISIBLE);
        } else {
            mLayoutTips.setVisibility(View.GONE);
        }
    }

    private void updateSearchResultRecycler(){
        ContactsEntity entity = mRecentSearchList.get(0);
        if (getUserModel(mSelectedContactsList, entity.userModel.userId) == null) {
            entity.isSelected = false;
        } else {
            entity.isSelected = true;
        }
        mSearchContactAdapter.notifyDataSetChanged();
        handleViewVisibility();
        mTextRecentSearchTitle.setText(R.string.trtcaudiocall_title_search_result);
    }

    private void updateRecentSearchRecycler(){
        mRecentSearchList.clear();

        String userJson = SPUtils.getInstance(SEARCH_PER_NAME).getString(SEARCH_USER_KEY);
        List<UserModel> userModels = GsonUtils.fromJson(userJson, new TypeToken<List<UserModel>>() {
        }.getType());

        if (userModels == null) {
            handleViewVisibility();
            return;
        }

        for (UserModel userModel : userModels) {
            ContactsEntity entity = new ContactsEntity();
            /** 刷新最近搜索联系人列表时，判断当前是否在选中列表中，
             * 如果在就勾选列表前的选中框，不过不在则不勾选
             * */
            if (getUserModel(mSelectedContactsList, userModel.userId) == null) {
                entity.isSelected = false;
            } else {
                entity.isSelected = true;
            }
            entity.userModel = userModel;
            mRecentSearchList.add(entity);
        }

        mSearchContactAdapter.notifyDataSetChanged();
        handleViewVisibility();
        mTextRecentSearchTitle.setText(R.string.trtcaudiocall_title_recent_search);
    }

    /**
     * 整个搜索列表有两种状态：
     *  - 显示当前手机号的搜索结果，此时列表中仅有一个用户；
     *  - 显示最近搜索的用户列表，此时列表中为多个用户
     * */
    private void updateSearchRecycler() {
        if (mEditSearchUser.length() != 0 && mRecentSearchList.size() == 1) {
            updateSearchResultRecycler();
            return;
        }
        updateRecentSearchRecycler();
    }

    private void searchContactsByPhone(String phoneNumber) {
        if (TextUtils.isEmpty(phoneNumber)) {
            return;
        }

        ProfileManager.getInstance().getUserInfoByPhone(phoneNumber, new ProfileManager.GetUserInfoCallback() {
            @Override
            public void onSuccess(UserModel model) {
                mRecentSearchList.clear();

                ContactsEntity entity = new ContactsEntity();
                UserModel oldUserModel = getUserModel(mSelectedContactsList, model.userId);
                if (oldUserModel != null) {
                    oldUserModel.userAvatar = model.userAvatar;
                    oldUserModel.userName = model.userName;
                    entity.isSelected = true;
                    entity.userModel = oldUserModel;
                } else {
                    entity.isSelected = false;
                    entity.userModel = model;
                }

                saveSearchResult(entity);
                mRecentSearchList.add(entity);

                updateSearchResultRecycler();
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong(getString(R.string.trtcaudiocall_toast_search_fail, msg));
            }
        });
    }

    private void saveSearchResult(ContactsEntity entity) {
        String userJson = SPUtils.getInstance(SEARCH_PER_NAME).getString(SEARCH_USER_KEY);
        List<UserModel> userModels = GsonUtils.fromJson(userJson, new TypeToken<List<UserModel>>() {
        }.getType());

        if (userModels == null) {
            userModels = new ArrayList<>();
        }
        // 在保存到SharedPreferences之前，判断是否已经存在；
        if (getUserModel(userModels, entity.userModel.userId) != null) {
            return;
        }
        userModels.add(entity.userModel);
        String json = GsonUtils.toJson(userModels);
        SPUtils.getInstance(SEARCH_PER_NAME).put(SEARCH_USER_KEY, json);
    }

    private void addSelectedContacts(ContactsEntity entity) {
        String userId = entity.userModel.userId;

        if (userId.equals(mSelfModel.userId)) {
            ToastUtils.showLong(R.string.trtcaudiocall_toast_not_add_self);
            return;
        }

        if (getUserModel(mSelectedContactsList, userId) == null) {
            mSelectedContactsList.add(entity.userModel);
        }
        updateSearchRecycler();
        mSelectedContactAdapter.notifyDataSetChanged();
    }

    private void removeSelectedContacts(String userId) {
        UserModel userModel = getUserModel(mSelectedContactsList, userId);
        if (userModel != null) {
            mSelectedContactsList.remove(userModel);
        }
        updateSearchRecycler();
        mSelectedContactAdapter.notifyDataSetChanged();
    }

    private void completeBtnEnable() {
        mButtonComplete.setEnabled(!mSelectedContactsList.isEmpty());
    }

    private UserModel getUserModel(List<UserModel> userModels, String userId) {
        if (userModels == null) {
            return null;
        }

        for (UserModel userModel : userModels) {
            if (userModel.userId.equals(userId)) {
                return userModel;
            }
        }
        return null;
    }

    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    public static class ContactsEntity {
        public UserModel userModel;
        public boolean isSelected;
    }
}
