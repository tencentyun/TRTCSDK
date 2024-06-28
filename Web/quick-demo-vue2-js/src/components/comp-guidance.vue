<!--
 * @Description: 指引组件
 * @Date: 2022-03-14 16:56:36
 * @LastEditTime: 2022-03-29 15:27:22
-->
<template>
	<div class="guidance-container">
		<el-collapse v-model="activeNames">
			<el-collapse-item name="1">
				<template slot="title">
					<span v-if="isEnLang" class="collapse-title">Step 1 :  Check Current Environment</span>
					<span v-if="isZhLang" class="collapse-title">步骤 1 : 判断当前环境是否满足条件</span>
				</template>
        <ul class="collapse-content">
          <li v-if="isEnLang">Determine if the current browser environment is suitable for using TRTC，You can visit <a
            target="_blank" href="https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html">TRTC Detect Page</a></li>
          <li v-if="isZhLang">判断当前浏览器环境是否满足使用 TRTC，您可以访问 <a
            target="_blank" href="https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html">TRTC 检测页面</a></li>
        </ul>
			</el-collapse-item>
			<el-collapse-item name="2">
				<template slot="title">
					<span v-if="isEnLang" class="collapse-title">Step 2 : Create New Application</span>
					<span v-if="isZhLang" class="collapse-title">步骤 2 : 创建新的应用</span>
				</template>
        <ul v-if="isEnLang" class="collapse-content">
					<li>Login <a target="_blank" href="https://console.cloud.tencent.com/trtc">TRTC Console</a>, choose Development Assistance > <a
						target="_blank" href="https://console.cloud.tencent.com/trtc/quickstart">Demo Quick Run</a></li>
					<li>Click New, enter a name for the application, such as TestTRTC.
            If you have already created an application, click Existing.</li>
					<li>Add or edit tags according to actual needs, click Create.</li>
					<img src="@/assets/image/step1-en.png" alt="Create App" style="width: 400px"/>
				</ul>
				<ul v-if="isZhLang" class="collapse-content">
					<li>登录<a target="_blank" href="https://console.cloud.tencent.com/trtc">实时音视频控制台</a>，选择【开发辅助】 > 【<a
						target="_blank" href="https://console.cloud.tencent.com/trtc/quickstart">快速跑通Demo</a>】</li>
					<li>单击【新建应用】输入应用名称，例如 TestTRTC；若您已创建应用可单击选择已有应用。</li>
					<li>根据实际业务需求添加或编辑标签，单击【创建】。</li>
					<img src="@/assets/image/step1.png" alt="创建应用" style="width: 400px"/>
				</ul>
			</el-collapse-item>
			<el-collapse-item name="3">
				<template slot="title">
					<span v-if="isEnLang" class="collapse-title">Step 3 : Get SDKAppID and SecretKey</span>
					<span v-if="isZhLang" class="collapse-title">步骤 3 : 获取 SDKAppID 和 密钥 SecretKey</span>
				</template>
        <ul v-if="isEnLang" class="collapse-content">
					<li>Copy the SDKAppId and SecretKey into the input box</li>
					<img src="@/assets/image/step2-en.png" alt="SDKAppId" style="width: 400px"/>
				</ul>
				<ul v-if="isZhLang" class="collapse-content">
					<li>复制 SDKAppId 和密钥（secretKey）填入输入框</li>
					<img src="@/assets/image/step2.png" alt="SDKAppId" style="width: 400px"/>
				</ul>
			</el-collapse-item>
			<el-collapse-item name="4">
				<template slot="title">
          <span v-if="isEnLang" class="collapse-title">Step 4 : Start Video Call</span>
					<span v-if="isZhLang" class="collapse-title">步骤 4 : 开始视频通话</span>
				</template>
        <ul v-if="isEnLang" class="collapse-content">
					<li>Input userId and roomId</li>
          <li>Click Join Room to enter the room</li>
          <li>Click Publish to publish LocalStream</li>
          <li>Click Unpublish to unpublish LocalStream</li>
          <li>Click Leave Room to leave the room</li>
          <li>Click Start Share Screen to publish screen stream</li>
          <li>Click Stop Share Screen to unpublish screen stream</li>
				</ul>
				<ul v-if="isZhLang" class="collapse-content">
					<li>输入 userId 和 roomId</li>
					<li>点击【进入房间】按钮进入房间</li>
					<li>点击【发布流】按钮发布音视频</li>
					<li>点击【取消发布流】按钮取消发布音视频</li>
					<li>点击【离开房间】按钮离开房间</li>
					<li>点击【开始共享屏幕】按钮布屏幕分享</li>
					<li>点击【停止共享屏幕】按钮取消发布屏幕分享</li>
				</ul>
			</el-collapse-item>
	</el-collapse>
	</div>
</template>

<script>
export default {
  name: 'compGuidance',
  data() {
    return {
      activeNames: ['1', '4'],
    };
  },
  computed: {
    isEnLang() {
      return this.$i18n.locale === 'en';
    },
    isZhLang() {
      return this.$i18n.locale === 'zh';
    },
  },
};
</script>

<style lang="scss" scoped>
.guidance-container {
	width: 100%;
	border: 1px solid #DDDDDD;
	border-radius: 4px;
	padding: 0 10px;
	margin-top: 20px;
	text-align: left;
	.collapse-title {
		font-size: 16px;
		font-weight: bold;
    line-height: 18px;
	}
	.collapse-content {
		font-size: 14px;
    padding-left: 20px;
    font-weight: 400;
    margin-top: 10px;
	}
}
</style>
