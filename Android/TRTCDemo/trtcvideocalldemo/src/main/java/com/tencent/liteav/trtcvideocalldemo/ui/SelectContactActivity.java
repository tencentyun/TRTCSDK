package com.tencent.liteav.trtcvideocalldemo.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
import com.squareup.picasso.Picasso;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.trtcvideocalldemo.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用于选择联系人
 * @author guanyifeng
 */
public class SelectContactActivity extends AppCompatActivity {
    private static final String PER_SEARCH = "search_contact";
    private static final String PER_MODEL  = "search_user_model";

    private TextView                     mCompleteBtn;
    private Toolbar                      mToolbar;
    private EditText                     mSearchEt;
    private RecyclerView                 mSelectedContactRv;
    private SelectedContactAdapter       mSelectedContactAdapter;
    private List<UserModel>              mContactList        = new ArrayList<>();
    private Map<String, UserModel>       mUserModelMap       = new HashMap<>();
    private RecyclerView                 mSearchRv;
    private SearchContactAdapter         mSearchContactAdapter;
    private List<ContactEntity>          mSearchEntityList   = new ArrayList<>();
    private ProfileManager.NetworkAction mSearchCall;
    private Map<String, ContactEntity>   mRecentSearchResult = new HashMap<>();
    private UserModel                    mSelfModel;

    public static void start(Context context) {
        Intent starter = new Intent(context, SelectContactActivity.class);
        context.startActivity(starter);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.videocall_activity_select_contact);
        initView();
        mSelfModel = ProfileManager.getInstance().getUserModel();
        loadRecentSearch();
        mSearchEntityList.addAll(mRecentSearchResult.values());
        mSearchContactAdapter.notifyDataSetChanged();
    }

    private void initView() {
        mCompleteBtn = (TextView) findViewById(R.id.btn_complete);
        mToolbar = (Toolbar) findViewById(R.id.toolbar);
        mSearchEt = (EditText) findViewById(R.id.et_search);
        // 设置已经选中的用户列表
        mSelectedContactRv = (RecyclerView) findViewById(R.id.rv_selected_contact);
        FlexboxLayoutManager  manager        = new FlexboxLayoutManager(this);
        FlexboxItemDecoration itemDecoration = new FlexboxItemDecoration(this);
        itemDecoration.setDrawable(getResources().getDrawable(R.drawable.bg_divider));
        mSelectedContactRv.addItemDecoration(itemDecoration);
        mSelectedContactRv.setLayoutManager(manager);
        mSelectedContactAdapter = new SelectedContactAdapter(this, mContactList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (position < mContactList.size() && position >= 0) {
                    UserModel userModel = mContactList.get(position);
                    removeContact(userModel.userId);
                }
                completeBtnEnable();
            }
        });
        mSelectedContactRv.setAdapter(mSelectedContactAdapter);
        // 设置底部搜索界面列表
        mSearchRv = (RecyclerView) findViewById(R.id.rv_search);
        LinearLayoutManager   layoutManager         = new LinearLayoutManager(this);
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        mSearchRv.addItemDecoration(dividerItemDecoration);
        mSearchRv.setLayoutManager(layoutManager);
        mSearchContactAdapter = new SearchContactAdapter(this, mSearchEntityList, new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                if (position < mSearchEntityList.size() && position >= 0) {
                    ContactEntity entity = mSearchEntityList.get(position);
                    if (!entity.isSelected) {
                        //之前没有被添加过
                        addContact(entity);
                    } else {
                        removeContact(entity.mUserModel.userId);
                    }
                    completeBtnEnable();
                }
            }
        });
        mSearchRv.setAdapter(mSearchContactAdapter);

        mSearchEt.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    //开始搜索
                    search(v.getText().toString());
                    return true;
                }
                return false;
            }
        });
        mSearchEt.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() == 0) {
                    search("");
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        mCompleteBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (CollectionUtils.isEmpty(mContactList)) {
                    ToastUtils.showShort("请先选择通话用户");
                    return;
                }
                TRTCVideoCallActivity.startCallSomeone(SelectContactActivity.this, mContactList);
            }
        });
        completeBtnEnable();

        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    @Override
    protected void onStop() {
        super.onStop();
        saveRecentSearch();
    }

    private void loadRecentSearch() {
        try {
            String json = SPUtils.getInstance(PER_SEARCH).getString(PER_MODEL);
            if (TextUtils.isEmpty(json)) {
                return;
            }
            List<UserModel> models = GsonUtils.fromJson(json, new TypeToken<List<UserModel>>() {
            }.getType());
            for (UserModel userModel : models) {
                ContactEntity entity = new ContactEntity();
                entity.isSelected = false;
                entity.mUserModel = userModel;
                mRecentSearchResult.put(entity.mUserModel.userId, entity);
            }
        } catch (Exception e) {
        }
    }

    private void saveRecentSearch() {
        List<UserModel> models = new ArrayList<>();
        for (ContactEntity entity : mRecentSearchResult.values()) {
            models.add(entity.mUserModel);
        }
        String json = GsonUtils.toJson(models);
        SPUtils.getInstance(PER_SEARCH).put(PER_MODEL, json);
    }

    private void search(String phone) {
        if (mSearchCall != null) {
            mSearchCall.cancel();
        }
        if (TextUtils.isEmpty(phone)) {
            mSearchEntityList.clear();
            mSearchEntityList.addAll(mRecentSearchResult.values());
            mSearchContactAdapter.notifyDataSetChanged();
            return;
        }
        mSearchCall = ProfileManager.getInstance().getUserInfoByPhone(phone, new ProfileManager.GetUserInfoCallback() {
            @Override
            public void onSuccess(UserModel model) {
                mSearchEntityList.clear();
                ContactEntity entity = new ContactEntity();
                if (mUserModelMap.containsKey(model.userId)) {
                    UserModel oldUserModel = mUserModelMap.get(model.userId);
                    oldUserModel.userAvatar = model.userAvatar;
                    oldUserModel.userName = model.userName;
                    entity.isSelected = true;
                    entity.mUserModel = oldUserModel;
                } else {
                    entity.isSelected = false;
                    entity.mUserModel = model;
                }
                mSearchEntityList.add(entity);
                mRecentSearchResult.put(model.userId, entity);
                mSearchContactAdapter.notifyDataSetChanged();
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtils.showLong("搜索失败:" + msg);
            }
        });
    }

    private void removeContact(String userId) {
        //1. 删除在map中的model
        if (mUserModelMap.containsKey(userId)) {
            UserModel model = mUserModelMap.remove(userId);
            mContactList.remove(model);
            ContactEntity recentEntity = mRecentSearchResult.get(userId);
            if (recentEntity != null) {
                recentEntity.isSelected = false;
            }
            for (ContactEntity entity : mSearchEntityList) {
                if (entity.mUserModel.userId.equals(userId)) {
                    entity.isSelected = false;
                    break;
                }
            }
        }
        //2. 通知界面刷新
        mSearchContactAdapter.notifyDataSetChanged();
        mSelectedContactAdapter.notifyDataSetChanged();
    }

    private void completeBtnEnable() {
        mCompleteBtn.setEnabled(!mContactList.isEmpty());
    }

    private void addContact(ContactEntity entity) {
        //1. 把对应的model增加到map中
        String userId = entity.mUserModel.userId;
        //1.1 判断这个contact是不是自己
        if (userId.equals(mSelfModel.userId)) {
            ToastUtils.showLong("不能添加自己");
            return;
        }
        if (!mUserModelMap.containsKey(userId)) {
            mUserModelMap.put(userId, entity.mUserModel);
            mContactList.add(entity.mUserModel);
        }
        entity.isSelected = true;
        //2. 通知界面刷新
        mSearchContactAdapter.notifyDataSetChanged();
        mSelectedContactAdapter.notifyDataSetChanged();
    }

    public static class SelectedContactAdapter extends
            RecyclerView.Adapter<SelectedContactAdapter.ViewHolder> {
        private static final String              TAG = SelectedContactAdapter.class.getSimpleName();
        private              Context             context;
        private              List<UserModel>     list;
        private              OnItemClickListener onItemClickListener;

        public SelectedContactAdapter(Context context, List<UserModel> list,
                                      OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View           view     = inflater.inflate(R.layout.videocall_item_selected_contact, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            UserModel item = list.get(position);
            holder.bind(item, onItemClickListener);
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        public static class ViewHolder extends RecyclerView.ViewHolder {
            private ImageView mAvatarImg;

            public ViewHolder(View itemView) {
                super(itemView);
                initView(itemView);
            }

            public void bind(final UserModel model,
                             final OnItemClickListener listener) {
                Picasso.get().load(model.userAvatar).into(mAvatarImg);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }

            private void initView(@NonNull final View itemView) {
                mAvatarImg = (ImageView) itemView.findViewById(R.id.img_avatar);
            }
        }
    }


    public static class SearchContactAdapter extends
            RecyclerView.Adapter<SearchContactAdapter.ViewHolder> {
        private static final String TAG = SearchContactAdapter.class.getSimpleName();

        private Context                                   context;
        private List<SelectContactActivity.ContactEntity> list;
        private OnItemClickListener                       onItemClickListener;

        public SearchContactAdapter(Context context, List<SelectContactActivity.ContactEntity> list,
                                    OnItemClickListener onItemClickListener) {
            this.context = context;
            this.list = list;
            this.onItemClickListener = onItemClickListener;
        }

        public static class ViewHolder extends RecyclerView.ViewHolder {
            private Button    mContactCb;
            private ImageView mAvatarImg;
            private TextView  mUserNameTv;

            public ViewHolder(View itemView) {
                super(itemView);
                mContactCb = (Button) itemView.findViewById(R.id.cb_contact);
                mAvatarImg = (ImageView) itemView.findViewById(R.id.img_avatar);
                mUserNameTv = (TextView) itemView.findViewById(R.id.tv_user_name);
            }

            public void bind(final SelectContactActivity.ContactEntity model,
                             final OnItemClickListener listener) {
                Picasso.get().load(model.mUserModel.userAvatar).into(mAvatarImg);
                mUserNameTv.setText(model.mUserModel.userName);
                if (model.isSelected) {
                    mContactCb.setActivated(true);
                } else {
                    mContactCb.setActivated(false);
                }
                mContactCb.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        listener.onItemClick(getLayoutPosition());
                    }
                });
            }
        }

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            Context        context  = parent.getContext();
            LayoutInflater inflater = LayoutInflater.from(context);
            View           view     = inflater.inflate(R.layout.videocall_item_select_contact, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            SelectContactActivity.ContactEntity item = list.get(position);
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

    public static class ContactEntity {
        public UserModel mUserModel;
        public boolean   isSelected;
    }
}
