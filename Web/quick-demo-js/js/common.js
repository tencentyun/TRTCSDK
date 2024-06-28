/* eslint-disable*/

function getLanguageKey () {
	let lang = (navigator.language || navigator.userLanguage).toLowerCase();
	if (lang.indexOf('zh') > -1) {
		lang = 'zh-cn';
	} else {
		lang = 'en';
	}
	return lang;
}
window.lang_ = getLanguageKey();

const VISIBLE = document.visibilityState === 'visible'

let playerContainer = document.getElementById('remote-container');
let logContainer = document.getElementById('log');
let language = document.getElementById('language');

let consoleBtn = document.getElementById('console')
let joinBtn = document.getElementById('join')
let leaveBtn = document.getElementById('leave')
let publishBtn = document.getElementById('publish')
let unpublishBtn = document.getElementById('unpublish')
let startShareBtn = document.getElementById('startShare')
let stopShareBtn = document.getElementById('stopShare')
let cameraSelect = document.getElementById('camera-select');
let microphoneSelect = document.getElementById('microphone-select');
let invite = document.getElementById('invite')
let inviteUrl = document.getElementById('inviteUrl')
let github = document.getElementById('github')

github.addEventListener('click', () => {
	aegis.reportEvent({
		name: 'jumpGithub',
		ext1: 'jumpGithub',
		ext2: 'webrtcQuickDemoJs',
		ext3: sdkAppId,
	});
})

language.addEventListener('click', () => {
	if (window.lang_ === 'zh-cn') {
		const zhList = document.querySelectorAll('.zh-cn');
		for (const item of zhList) {
			item.style.display = 'none';
		}
		const enList = document.querySelectorAll('.en');
		for (const item of enList) {
			item.style.display = 'block';
		}
		window.lang_ = 'en'
	} else if (window.lang_ === 'en') {
		const zhList = document.querySelectorAll('.zh-cn');
		for (const item of zhList) {
			item.style.display = 'block';
		}
		const enList = document.querySelectorAll('.en');
		for (const item of enList) {
			item.style.display = 'none';
		}
		window.lang_ = 'zh-cn';
	}
})

function addStreamView(remoteId) {
	let remoteDiv = document.getElementById(remoteId);
	if (!remoteDiv) {
		remoteDiv = document.createElement('div');
		remoteDiv.setAttribute('id', remoteId);
		remoteDiv.setAttribute('class', 'remote');
		playerContainer.appendChild(remoteDiv);
	}
}

function removeStreamView(remoteId) {
	const remoteDiv = document.getElementById(remoteId);
	if (remoteDiv) {
		playerContainer.removeChild(remoteDiv);
	}
}

function addSuccessLog(log) {
	const logItem = document.createElement('div');
	
	const success = document.createElement('span');
	success.setAttribute('class', 'success');
	success.innerText = '🟩 ';
	
	const logDiv = document.createElement('span');
	logDiv.innerText = log;
	
	logItem.appendChild(success);
	logItem.appendChild(logDiv);
	
	logContainer.appendChild(logItem);
	logContainer.scrollTop = logContainer.scrollHeight;
}

function addFailedLog(log) {
	const logItem = document.createElement('div');
	
	const success = document.createElement('span');
	success.innerText = '🟥 '
	
	const logDiv = document.createElement('span');
	logDiv.innerText = log;
	
	logItem.appendChild(success);
	logItem.appendChild(logDiv);
	
	logContainer.appendChild(logItem);
	logContainer.scrollTop = logContainer.scrollHeight;
}

function getQueryString(name) {
	var reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)', 'i');
	var r = window.location.search.substr(1).match(reg);
	if (r != null) {
		return unescape(r[2]);
	}
	return null;
}

const DEMOKEY = 'webrtcQuickDemoJs';
const isProd = location.origin === 'https://web.sdk.qcloud.com';
const AEGIS_ID = {
	dev: 'iHWefAYqvXVdajviap',
	prod: 'iHWefAYqpBFdmIMeDi',
};

const aegis = new Aegis({
	id: isProd ? AEGIS_ID.prod : AEGIS_ID.dev,
	uin: '', // 用户唯一 ID（可选）
	reportApiSpeed: true, // 接口测速
	reportAssetSpeed: true // 静态资源测速
})


function reportSuccessEvent(name, sdkAppId) {
	aegis.reportEvent({
		name,
		ext1: `${name}-success`,
		ext2: DEMOKEY,
		ext3: sdkAppId,
	});
}

function reportFailedEvent({name, error, type = 'rtc', sdkAppId, roomId}) {
	aegis.reportEvent({
		name,
		ext1: `${name}-failed#${roomId}*${type}*${error.message}`,
		ext2: DEMOKEY,
		ext3: sdkAppId,
	});
}
