<template>
  <div class="header-nav">
    <div class="header-nav-left">
      <div class="header-nav-title">腾讯云TRTC实时互动</div>
      <div class="header-nav-homepage" @click="gotoHomePage">首页</div>
    </div>
    <div class="header-nav-help">
      <el-dropdown @command="handleCommand">
        <span class="el-dropdown-link">
          更多
          <i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item command="command-detect">设备检测</el-dropdown-item>
          <el-dropdown-item command="command-logout">登出</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { setUserLoginInfo } from "../../utils";
export default {
  name: "HeaderNav",
  methods: {
    handleCommand: function(command) {
      if (command === "command-detect") {
        window.open(
          "https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html",
          "__blank"
        );
        return;
      }

      if (command === "command-logout") {
        this.$trtcCalling.logout();
        this.$store.commit("userLogoutSuccess");
        setUserLoginInfo({
          token: "",
          phoneNum: ""
        });
      }
    },
    gotoHomePage: function() {
      if (this.$router.currentRoute.fullPath !== "/") {
        this.$router.push("/");
      }
    }
  }
};
</script>

<style scoped>
.header-nav {
  background: #231f20;
  height: 80px;
  display: flex;
  padding: 0 20%;
  justify-content: space-around;
  color: #ffffff;
}
.header-nav-left {
  display: flex;
  flex-direction: row;
}
.header-nav-title {
  font-size: 20px;
  display: flex;
  align-items: center;
}
.header-nav-homepage {
  margin-left: 50px;
  font-size: 20px;
  display: flex;
  align-items: center;
  cursor: pointer;
}
.header-nav-help {
  font-size: 20px;
  display: flex;
  align-items: center;
}
.el-dropdown-link {
  color: #ffffff;
  font-size: 20px;
  cursor: pointer;
}
@media screen and (max-width: 767px) {
  .header-nav {
    padding: 0;
  }
  .header-nav-left {
    justify-content: space-around;
    width: 75%;
  }
  .header-nav-title,
  .el-dropdown-link {
    font-size: 18px;
  }
  .header-nav-homepage {
    font-size: 18px;
    margin-left: 10px;
  }
}
</style>
