<template>
  <div class="audio-call-section">
    <div
      class="audio-call-section-header"
    >Welcome {{loginUserInfo && (loginUserInfo.name || loginUserInfo.userId)}}</div>
    <div class="audio-call-section-title">语音通话</div>
    <search-user  :callFlag="callFlag" :cancelFlag="cancelFlag" @callUser="handleCallUser" @cancelCallUser="handleCancelCallUser"></search-user>
    <div :class="{ 'audio-conference': true, 'is-show': isShowAudioCall }">
      <div class="audio-conference-header">语音通话区域</div>

      <div class="audio-conference-list">
        <div
          v-for="userId in meetingUserIdList"
          :key="`audio-${userId}`"
          :class="{'user-audio-container': true, 'is-me': userId === loginUserInfo.userId}"
        >
          <div class="user-status">
            <div
              :class="{'user-audio-status': true, 'is-mute': isUserMute(muteAudioUserIdList, userId)}"
            ></div>
          </div>
          <div class="audio-item-username">{{userId2User[userId] && userId2User[userId].name}}</div>
        </div>
      </div>
      <div class="audio-conference-action">
        <el-button
          class="action-btn"
          type="success"
          @click="toggleAudio"
        >{{isAudioOn ? '关闭麦克风' : '打开麦克风'}}</el-button>

        <el-button class="action-btn" type="danger" @click="handleHangup">挂断</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import SearchUser from "../search-user";
import { getUserDetailInfoByUserid } from "../../service";

export default {
  name: "AudioCall",
  components: {
    SearchUser
  },
  computed: {
    ...mapState({
      loginUserInfo: state => state.loginUserInfo,
      callStatus: state => state.callStatus,
      isInviter: state => state.isInviter,
      meetingUserIdList: state => state.meetingUserIdList,
      muteAudioUserIdList: state => state.muteAudioUserIdList
    })
  },
  data() {
    return {
      isShowAudioCall: false,
      isAudioOn: true,
      userId2User: {},
      callFlag: false,
      cancelFlag: false,
    };
  },
  mounted() {
    if (this.callStatus === "connected" && !this.isInviter) {
      this.startMeeting();
      this.updateUserId2UserInfo(this.meetingUserIdList);
    }
  },
  destroyed() {
    this.$store.commit("updateMuteVideoUserIdList", []);
    this.$store.commit("updateMuteAudioUserIdList", []);
    if (this.callStatus === "connected") {
      this.$trtcCalling.hangup();
      this.$store.commit("updateCallStatus", "idle");
    }
  },
  watch: {
    callStatus: function(newStatus, oldStatus) {
      // 建立通话连接
      if (newStatus !== oldStatus && newStatus === "connected") {
        this.startMeeting();
        this.updateUserId2UserInfo(this.meetingUserIdList);
      }
    },
    meetingUserIdList: function(newList, oldList) {
      if (newList !== oldList || newList.length !== oldList.length) {
        this.updateUserId2UserInfo(newList);
      }
    }
  },
  methods: {
    handleCallUser: function({ param }) {
      this.callFlag = true
      this.$trtcCalling.call({
        userID: param,
        type: this.TrtcCalling.CALL_TYPE.AUDIO_CALL
      }).then(()=>{
        this.callFlag = false
        this.$store.commit("userJoinMeeting", this.loginUserInfo.userId);
        this.$store.commit("updateCallStatus", "calling");
        this.$store.commit("updateIsInviter", true);
      })
      
    },
    handleCancelCallUser: function() {
      this.cancelFlag = true
      this.$trtcCalling.hangup().then(()=>{
        this.cancelFlag = false
        this.$store.commit("dissolveMeeting");
        this.$store.commit("updateCallStatus", "idle");
      })
    },
    toggleAudio: function() {
      this.isAudioOn = !this.isAudioOn;
      this.$trtcCalling.setMicMute(!this.isAudioOn);
      if (this.isAudioOn) {
        const muteUserList = this.muteAudioUserIdList.filter(
          userId => userId !== this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      } else {
        const muteUserList = this.muteAudioUserIdList.concat(
          this.loginUserInfo.userId
        );
        this.$store.commit("updateMuteAudioUserIdList", muteUserList);
      }
    },
    handleHangup: function() {
      this.$trtcCalling.hangup();
      this.isShowVideoCall = false;
      this.$store.commit("updateCallStatus", "idle");
      this.$router.push("/");
    },
    isUserMute: function(muteUserList, userId) {
      return muteUserList.indexOf(userId) !== -1;
    },
    startMeeting: function() {
      this.isShowAudioCall = true;
    },
    updateUserId2UserInfo: async function(userIdList) {
      let userId2UserInfo = {};
      let loginUserId = this.loginUserInfo.userId;
      for (let i = 0; i < userIdList.length; i++) {
        const userId = userIdList[i];
        const userInfo = await getUserDetailInfoByUserid(userId);
        userId2UserInfo[userId] = userInfo;
        if (loginUserId === userId) {
          userId2UserInfo[userId].name += "(me)";
        }
      }
      this.userId2User = {
        ...this.userId2User,
        ...userId2UserInfo
      };
    },
    goto: function(path) {
      this.$router.push(path);
    }
  }
};
</script>

<style scoped>
.audio-call-section {
  padding-top: 50px;
  width: 800px;
  margin: 0 auto;
}
.audio-call-section-header {
  font-size: 24px;
}
.audio-call-section-title {
  margin-top: 30px;
  font-size: 20px;
}
.audio-conference {
  display: none;
  margin-top: 20px;
}
.audio-conference.is-show {
  display: block;
}

.audio-conference-list {
  display: flex;
  flex-direction: row;
  margin-top: 10px;
  justify-content: center;
}

.user-audio-container {
  background-color: #333;
  position: relative;
  text-align: left;
  width: 360px;
  height: 240px;
  margin-right: 10px;
  background: black;
}

.audio-conference-action {
  margin-top: 10px;
}

.user-audio-status {
  position: absolute;
  right: 20px;
  bottom: 20px;
  width: 22px;
  height: 27px;
  z-index: 10;
  background-image: url("../../assets/mic-on.png");
  background-size: cover;
}

.audio-item-avatar-wrapper {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translateX(-50%) translateY(-50%);
  width: 80px;
  height: 80px;
  z-index: 20;
}

.audio-item-avatar-wrapper img {
  width: 80px;
  height: 80px;
}

.user-audio-status.is-mute {
  background-image: url("../../assets/mic-off.png");
}

.audio-item-username {
  position: absolute;
  top: 20px;
  left: 20px;
  z-index: 10;
  color: #ffffff;
}
@media screen and (max-width: 767px) {
  .audio-call-section {
    width: 100%;
  }
  .audio-conference-list {
    padding: 0 10px;
  }
  .user-audio-container {
    margin: 5px;
    width: 180px;
    height: 120px;
  }
}
</style>
