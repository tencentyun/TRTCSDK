<template>
  <div class="search-user-container" v-if="callStatus !== 'connected'">
    <div class="search-section">
      <el-input class="inline-input" v-model="searchInput" maxlength="11" placeholder="请输入用户ID"></el-input>
    </div>

    <div v-show="callStatus !== 'connected'" class="search-user-list">
      <div v-if="callStatus === 'calling' && isInviter" class="calling-user-footer">
        <el-button class="user-item-join-btn calling">呼叫中...</el-button>
        <el-button class="user-item-cancel-join-btn" :disabled="cancel" :loading="cancel" @click="handleCancelCallBtnClick">取消</el-button>
      </div>
      <el-button v-else @click="handleCallBtnClick(searchInput)" :disabled="call" class="user-item-join-btn">呼叫</el-button>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import { getSearchHistory } from "../../utils";

export default {
  name: "SearchUser",
  props:{
    callFlag: {
      type: Boolean
    },
    cancelFlag:{
      type: Boolean
    },
  },
  data() {
    return {
      searchInput: "",
      callUserId: "",
      searchResultList: [],
      searchHistoryUser: getSearchHistory(),
      call: false,
      cancel: false
    };
  },
  computed: {
    ...mapState({
      loginUserInfo: state => state.loginUserInfo,
      meetingUserIdList: state => state.meetingUserIdList,
      callStatus: state => state.callStatus,
      isAccepted: state => state.isAccepted,
      isInviter: state => state.isInviter
    }),
    userList: function() {
      if (this.searchInput === "" && this.searchHistoryUser.length !== 0) {
        return this.searchHistoryUser;
      }
      return this.searchResultList;
    }
  },
  watch: {
    callStatus: function(newStatus, oldStatus) {
      if (newStatus !== oldStatus && newStatus === "connected") {
        this.searchInput = "";
        this.searchResultList = [];
      }
      if (newStatus === "idle") {
        this.callUserId = "";
      }
    },
    callFlag(newVal) {
      this.call = newVal
    },
    cancelFlag(newVal) {
      this.cancel = newVal
    }
  },
  methods: {
    handleCallBtnClick: function(param) {
      if (param === this.loginUserInfo.userId) {
        this.$message("请输入正确用户ID");
        return;
      }
      this.call = true
      this.callUserId = param;
      this.$emit("callUser", { param });
    },
    handleCancelCallBtnClick: function() {
      // 对方刚接受邀请，但进房未成功
      this.cancel = true
      this.$emit("cancelCallUser");
    }
  }
};
</script>

<style scoped>
.search-user-container {
  width: 400px;
  margin: 10px auto 0;
}
.search-section {
  display: flex;
  flex-direction: row;
}
.search-user-btn {
  margin-left: 10px;
}
.search-user-list {
  padding-top: 20px;
}
.search-user-list-title {
  margin-top: 20px;
  font-size: 18px;
  text-align: left;
}
.user-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
}
.user-item-info {
  display: flex;
  flex-direction: row;
  align-items: center;
}
.user-item-avatar-wrapper img {
  width: 50px;
  height: 50px;
  border-radius: 50%;
}
.user-item-username {
  margin-left: 20px;
}
@media screen and (max-width: 767px) {
  .search-user-container {
    width: 90%;
  }
}
</style>
