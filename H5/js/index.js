// 渲染出用户
(function render() {
    var html = 'u' + Math.floor(Math.random() * 10000);
    document.getElementById('userId').value = html;
})();

function onKickout() {
    alert("on kick out!");
}

function quitRTC() {
    RTC.quit();
    $("#video-section").hide();
    $("#input-container").show();
    $("#remote-video-wrap").html("");
}

function onRelayTimeout(msg) {
    alert("onRelayTimeout!" + (msg ? JSON.stringify(msg) : ""));
}

function createVideoElement(id, isLocal) {
    var videoDiv = document.createElement("div");
    videoDiv.innerHTML = '<video id="' + id + '" autoplay ' + (isLocal ? 'muted' : '') + ' playsinline ></video>';
    document.querySelector("#remote-video-wrap").appendChild(videoDiv);
    return document.getElementById(id);
}

function onLocalStreamAdd(info) {
    if (info.stream && info.stream.active === true) {
        var id = "local";
        var video = document.getElementById(id);
        if (!video) {
            createVideoElement(id, true);
        }
        var video = document.getElementById(id)
        video.srcObject = info.stream;
        video.muted = true
        video.autoplay = true
        video.playsinline = true
    }
}

function onRemoteStreamUpdate(info) {
    console.debug(info)
    // console.debug(info)
    if (info.stream && info.stream.active === true) {
        var id = info.videoId;
        var video = document.getElementById(id);
        if (!video) {
            video = createVideoElement(id);
        }
        video.srcObject = info.stream;
    } else {
        // console.log('欢迎用户' + info.userId + '加入房间');
    }
}

function onRemoteStreamRemove(info) {
    // console.log(info.userId + ' 断开了连接');
    var videoNode = document.getElementById(info.videoId);
    if (videoNode) {
        videoNode.srcObject = null;
        document.getElementById(info.videoId).parentElement.removeChild(videoNode);
    }
}

function onWebSocketClose() {
    RTC.quit();
}

function gotStream( opt ,succ){
    RTC.getLocalStream({
        video:true,
        audio:true,
        videoDevice:opt.videoDevice,
        // 如需指定分辨率，可以在attributes中增加对width和height的约束
        // 否则将获取摄像头的默认分辨率
        // 更多配置项 请参考 接口API
        // https://cloud.tencent.com/document/product/647/17251#webrtcapi.getlocalstream
        // attributes:{
        //     width:640,
        //     height:320
        // }
    },function(info){
        var stream = info.stream;
        succ ( stream )
    });
}

function initRTC(opts) {
    window.RTC = new WebRTCAPI({
        userId: opts.userId,
        userSig: opts.userSig,
        sdkAppId: opts.sdkappid,
        accountType: opts.accountType
    }, function () {
        RTC.enterRoom({
            roomid: opts.roomid * 1,
            privateMapKey: opts.privateMapKey,
            role: "user",
        }, function (info) {
            console.warn("init succ", info)
            gotStream({
                audio:true,
                video:true
            },function(stream){
                RTC.startRTC({
                    stream: stream,
                    role: 'user'
                });
            })
        }, function (error) {
            console.error("init error", error)
        });
    }, function (error) {
        // console.warn("init error", error)
    });

    // 远端流新增/更新
    RTC.on("onRemoteStreamUpdate", onRemoteStreamUpdate)
    // 本地流新增
    RTC.on("onLocalStreamAdd", onLocalStreamAdd)
    // 远端流断开
    RTC.on("onRemoteStreamRemove", onRemoteStreamRemove)
    // 重复登录被T
    RTC.on("onKickout", onKickout)
    // 服务器超时
    RTC.on("onRelayTimeout", onRelayTimeout)

    RTC.on("onErrorNotify", function (info) {
        console.error(info)
        if (info.errorCode === RTC.getErrorCode().GET_LOCAL_CANDIDATE_FAILED) {
            // alert( info.errorMsg )
        }
    });
    RTC.on("onStreamNotify", function (info) {
        // console.warn('onStreamNotify', info)
    });
    RTC.on("onWebSocketNotify", function (info) {
        // console.warn('onWebSocketNotify', info)
    });
    RTC.on("onUserDefinedWebRTCEventNotice", function (info) {
        // console.error( 'onUserDefinedWebRTCEventNotice',info )
    });
}

function push() {
    var roomid = $('#roomid').val();
    var userId = $('#userId').val();
    var tmpObj = genTestUserSig(userId);
    var userSig = tmpObj.userSig;

    $('#c_roomid').html(roomid);
    $('#c_userid').html(userId);

    // 页面处理，显示视频流页面
    $("#video-section").show();
    $("#input-container").hide();

    initRTC({
        "userId": userId,
        "userSig": userSig,
        "sdkappid": tmpObj.sdkappid,
        "accountType": 1, // 随便传一个值，现在没有啥用处
        "roomid": roomid
    });
}

function audience() {
    login(true);
}

function stopRTC() {
    RTC.stopRTC(0, function (info) {
        // console.debug(info)
    }, function (info) {
        // console.debug(info)
    });
}

function stopWs() {
    RTC.global.websocket.close();
}

function startRTC() {
    RTC.startRTC(0, function (info) {
        console.debug('success', info)
    }, function (info) {
        console.debug('failed', info)
    });
}

function findUserToken(userid) {
    return genTestUserSig(userid);
}