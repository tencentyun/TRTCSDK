/* eslint-disable*/
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

TRTC.Logger.setLogLevel(TRTC.Logger.LogLevel.DEBUG);

// init device
initDevice();

// check current environment is supported TRTC or not
TRTC.checkSystemRequirements().then((checkResult) => {
	if (!checkResult.result) {
		console.log('checkResult', checkResult.result, 'checkDetail', checkResult.detail);
		alert('Your browser does not supported TRTC!');
		window.location.href = 'https://web.sdk.qcloud.com/trtc/webrtc/demo/detect/index.html';
	}
})


function initParams() {
	sdkAppId = parseInt(document.getElementById('sdkAppId').value);
	secretKey = document.getElementById('secretKey').value;
	roomId = parseInt(document.getElementById('roomId').value);
	userId = document.getElementById('userId').value;
	shareUserId = 'share_' + userId;
	cameraId = document.getElementById('camera-select').value;
	microphoneId = document.getElementById('microphone-select').value;
	
	
	aegis.reportEvent({
		name: 'loaded',
		ext1: 'loaded-success',
		ext2: DEMOKEY,
		ext3: sdkAppId,
	});
	
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
		reportSuccessEvent('joinRoom', sdkAppId)
		publish();
		refreshLink()
		invite.style.display = 'flex';
	} catch (error) {
		console.log('joinRoom error', error);
		reportFailedEvent({
			name: 'joinRoom', // 必填
			sdkAppId,
			roomId,
			error
		})
	}
}

async function leaveRoom() {
	invite.style.display = 'none';
	if (client) {
		try {
			await client.leave();
			reportSuccessEvent('leaveRoom', sdkAppId)
		} catch (error) {
			reportFailedEvent({
				name: 'leaveRoom', // 必填
				sdkAppId,
				roomId,
				error,
			})
		}
	}
}

async function publish() {
	if (client) {
		try {
			await client.publish();
			reportSuccessEvent('publish', sdkAppId)
		} catch (error) {
			reportFailedEvent({
				name: 'publish', // 必填
				sdkAppId,
				roomId,
				error,
			})
		}
	}
}

async function unpublish() {
	if (client) {
		try {
			await client.unpublish();
			reportSuccessEvent('unpublish', sdkAppId)
		} catch (error) {
			reportFailedEvent({
				name: 'unpublish', // 必填
				sdkAppId,
				roomId,
				error,
			})
		}
	}
}

async function startShare() {
	initParams()
	shareClient = new ShareClient({ sdkAppId, userId: shareUserId, roomId, secretKey, cameraId, microphoneId })
	try {
		await shareClient.join();
		await shareClient.publish();
		reportSuccessEvent('startScreenShare', sdkAppId)
	} catch (error) {
		console.log('startShare error', error);
		reportFailedEvent({
			name: 'startScreenShare', // 必填
			sdkAppId,
			roomId,
			error,
			type: 'share'
		})
	}
}

async function stopShare() {
	try {
		await shareClient.unpublish();
		await shareClient.leave();
		reportSuccessEvent('stopScreenShare', sdkAppId)
	} catch (error) {
		console.log('stopShare error', error);
		reportFailedEvent({
			name: 'startScreenShare', // 必填
			sdkAppId,
			roomId,
			error,
			type: 'share'
		})
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
		navigator.mediaDevices.addEventListener('devicechange', async () => {
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
