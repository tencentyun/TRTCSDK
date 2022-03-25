/* eslint-disable*/
const aegis = new Aegis({
	id: 'iHWefAYqvXVdajviap', // 项目ID，即上报id
	uin: '', // 用户唯一 ID（可选）
	reportApiSpeed: true, // 接口测速
	reportAssetSpeed: true // 静态资源测速
})
// -------document events--------

document.getElementById('sdkAppId').value = getQueryString('sdkAppId');
document.getElementById('secretKey').value = getQueryString('secretKey');
document.getElementById('userId').value = getQueryString('userId') || Math.floor(Math.random() * 1000000);
document.getElementById('roomId').value = getQueryString('roomId') || Math.floor(Math.random() * 1000);
const state = { url:window.location.href.split("?")[0] };
window.history.pushState(state,'', 'index.html');

// --------global variables----------
let sdkAppId;
let secretKey;
let roomId;

let userId;
let shareUserId;

let client;
let shareClient;
let cameraId;
let microphoneId;

let cameras = [];
let microphones = [];

// 输出INFO以上日志等级
TRTC.Logger.setLogLevel(TRTC.Logger.LogLevel.INFO);

// init device
initDevice();

// check current environment is supported TRTC or not
let checkResult = await TRTC.checkSystemRequirements();
if (!checkResult.result) {
	console.log('checkResult', checkResult.result, 'checkDetail', checkResult.detail);
	alert('Your browser does not supported TRTC!');
	window.location.href = 'https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html';
}

function initParams() {
	sdkAppId = parseInt(document.getElementById('sdkAppId').value);
	secretKey = document.getElementById('secretKey').value;
	roomId = parseInt(document.getElementById('roomId').value);
	userId = document.getElementById('userId').value;
	shareUserId = 'share_' + userId;
	cameraId = document.getElementById('camera-select').value;
	microphoneId = document.getElementById('microphone-select').value;
	
	if (!(sdkAppId && secretKey && roomId && userId)) {
		if (window.lang_ === 'zh-cn') {
			alert('请检查参数 SDKAppId, secretKey, userId, roomId 是否输入正确！');
		} else if (window.lang_ === 'en') {
			alert('Please enter the correct SDKAppId, secretKey, userId, roomId！');
		}
		
		throw new Error('Please enter the correct SDKAppId, secretKey, userId, roomId');
	}
}

async function joinRoom() {
	initParams()
	client = new Client({sdkAppId, userId, roomId, secretKey, cameraId, microphoneId});
	try {
		await client.join();
		aegis.reportEvent({
			name: 'JOIN_SUCCESS', // 必填
			ext1: sdkAppId
		})
		publish();
		refreshLink()
		invite.style.display = 'flex';
	} catch (error) {
		console.log('joinRoom error', error);
		aegis.reportEvent({
			name: 'JOIN_FAILED', // 必填
			ext1: sdkAppId,
			error: error.message_
		})
	}
}

async function leaveRoom() {
	invite.style.display = 'none';
	if (client) {
		await client.leave();
	}
}

async function publish() {
	if (client) {
		try {
			await client.publish();
			aegis.reportEvent({
				name: 'PUBLISH_SUCCESS', // 必填
				ext1: sdkAppId
			})
		} catch (e) {
			aegis.reportEvent({
				name: 'PUBLISH_FAILED', // 必填
				ext1: sdkAppId,
				error: error.message_
			})
		}
	}
}

async function unpublish() {
	if (client) {
		await client.unpublish();
	}
}

async function startShare() {
	initParams()
	shareClient = new ShareClient({ sdkAppId, userId: shareUserId, roomId, secretKey, cameraId, microphoneId })
	try {
		await shareClient.join();
		await shareClient.publish();
	} catch (error) {
		console.log('startShare error', error);
	}
}

async function stopShare() {
	try {
		await shareClient.unpublish();
		await shareClient.leave();
	} catch (error) {
		console.log('stopShare error', error);
	}
}


async function initDevice() {
	try {
		try {
			const stream = await navigator.mediaDevices.getUserMedia({
				audio: true,
				video: true
			});
			stream?.getTracks().forEach(track => track.stop());
			if (!stream) {
				joinBtn.disabled = true;
			}
		} catch (error) {
			if (window.lang_ === 'en') {
				window.alert('If you do not allow the current page to access the microphone and camera permissions, you may fail when publishing a local stream.');
			} else {
				window.alert('如果不允许当前页面访问麦克风和摄像头权限，您在发布本地流的时候可能会失败。');
			}
			joinBtn.disabled = true;
		}
		const updateDevice = async () => {
			cameras = await TRTC.getCameras();
			cameras?.forEach(camera => {
				const option = document.createElement('option');
				option.value = camera.deviceId;
				option.text = camera.label;
				cameraSelect.appendChild(option);
			});
			
			microphones = await TRTC.getMicrophones();
			microphones?.forEach(microphone => {
				const option = document.createElement('option');
				option.value = microphone.deviceId;
				option.text = microphone.label;
				microphoneSelect.appendChild(option);
			});
		}
		await updateDevice();
		// 设备更新
		document.addEventListener('devicechange', async () => {
			await updateDevice();
		});
	} catch (e) {
		console.error('get device failed', e);
	}
}

consoleBtn.addEventListener('click', () => {
	window.vconsole = new VConsole();
});
joinBtn.addEventListener('click', joinRoom, false);
leaveBtn.addEventListener('click', leaveRoom, false);
publishBtn.addEventListener('click', publish, false);
unpublishBtn.addEventListener('click', unpublish, false);
startShareBtn.addEventListener('click', startShare, false);
stopShareBtn.addEventListener('click', stopShare, false);

cameraSelect.onchange = async (e) => {
	if (client) {
		try {
			await client.switchDevice({ videoId: cameraSelect.value });
		} catch (error) {
			console.log('switchDevice error', error);
		}
	}
}

microphoneSelect.onchange = async (e) => {
	if (client) {
		try {
			await client.switchDevice({ audioId: microphoneSelect.value });
		} catch (error) {
			console.log('switchDevice error', error);
		}
	}
}

function refreshLink() {
	if (client) {
		inviteUrl.value = client.createShareLink();
	}
}

let clipboard = new ClipboardJS('#inviteBtn');
clipboard.on('success', (e) => {
	refreshLink();
	showTooltip(e.trigger, 'Copied!')
});
