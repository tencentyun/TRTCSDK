let isCamOn = true;
let isMicOn = true;
let isScreenOn = false;
let isJoined = true;
let rtc = null;
let share = null;
let shareUserId = '';
let cameraId = '';
let micId = '';

function login() {
    if ($('#userId').val()=='') {
        alert('用户名不能为空！');
        return ;
    }
    if ($('#roomId').val()=='') {
        alert('房间号不能为空！');
        return ;
    }
    presetting.login(false, options => {
        rtc = new RtcClient(options);
        join();
    });
    presetting.login(true, options => {
        shareUserId = options.userId;
        share = new ShareClient(options);
    });
}

function join() {
    rtc.join();
    $('#login-root').hide();
    $('#room-root').show();
    $('#header-roomId').html('房间号: ' + $('#roomId').val());
    $('#member-me').find('.member-id').html($('#userId').val() + '(我)');
}

function leave() {
    $('#mask_main').appendTo($('#main-video'));
    rtc.leave();
    share.leave();
}

function publish() {
    rtc.publish();
}

function unpublish() {
    rtc.unpublish();
}

function muteAudio() {
    rtc.muteLocalAudio();
}

function unmuteAudio() {
    rtc.unmuteLocalAudio();
}

function muteVideo() {
    $('#mask_main').show();
    rtc.muteLocalVideo();
}

function unmuteVideo() {
    rtc.unmuteLocalVideo();
    $('#mask_main').hide();
}

function startSharing() {
    share.join();
}

function stopSharing() {
    share.leave();
}

function setBtnClickFuc() {
    //userid roomid规格
    //$('#userId').on('input', function(e) {
    //    e.preventDefault();
    //    console.log('userId input ' + e.target.value);
    //    let val = $('#userId').val().slice(5);
    //    $('#userId').val('user_'+val.replace(/[^\d]/g,''));
    //});
    $('#roomId').on('input', function(e) {
        e.preventDefault();
        console.log('roomId input ' + e.target.value);
        let val = $('#roomId').val();
        $('#roomId').val(val.replace(/[^\d]/g,''));
    });
    //login
    $('#login-btn').click(() => {
        login();
    });
    //open or close camera
    $('#video-btn').on('click', () => {
        if (isCamOn) {
            $('#video-btn').attr('src', './img/big-camera-off.png');
            $('#video-btn').attr('title', '打开摄像头');
            $('#member-me').find('.member-video-btn').attr('src', 'img/camera-off.png');
            isCamOn = false;
            muteVideo();
        } else {
            $('#video-btn').attr('src', './img/big-camera-on.png');
            $('#video-btn').attr('title', '关闭摄像头');
            $('#member-me').find('.member-video-btn').attr('src', 'img/camera-on.png');
            isCamOn = true;
            unmuteVideo();
        }
    });
    //open or close microphone
    $('#mic-btn').on('click', () => {
        if (isMicOn) {
            $('#mic-btn').attr('src', './img/big-mic-off.png');
            $('#mic-btn').attr('title', '打开麦克风');
            $('#member-me').find('.member-audio-btn').attr('src', 'img/mic-off.png');
            isMicOn = false;
            muteAudio();
        } else {
            $('#mic-btn').attr('src', './img/big-mic-on.png');
            $('#mic-btn').attr('title', '关闭麦克风');
            $('#member-me').find('.member-audio-btn').attr('src', 'img/mic-on.png');
            isMicOn = true;
            unmuteAudio();
        }
    });
    //share screen or not
    $('#screen-btn').on('click', 
        throttle(() => {
            if (!TRTC.isScreenShareSupported()) {
                alert('当前浏览器不支持屏幕分享！');
                return;
            }
            if ($('#screen-btn').attr('src') == './img/screen-on.png') {
                $('#screen-btn').attr('src', './img/screen-off.png');
                stopSharing();
                isScreenOn = false;
            } else {
                $('#screen-btn').attr('src', './img/screen-on.png');
                startSharing();
                isScreenOn = true;
            }
        }, 2000)
    );
    //logout
    $('#logout-btn').on('click', () => {
        leave();
        $('#room-root').hide();
        $('#login-root').show();
    });
    //switch main video
    $('#main-video').on('click', () => {
        let mainVideo = $('.video-box').first();
        if ($('#main-video').is(mainVideo)) {
            return;
        }
        //释放main-video grid-area
        mainVideo.css('grid-area', 'auto/auto/auto/auto');
        exchangeView($('#main-video'), mainVideo);
        //将video-grid中第一个div设为main-video
        $('.video-box').first().css('grid-area', '1/1/3/4');
        //chromeM71以下会自动暂停，手动唤醒
        if (getBroswer().broswer=='Chrome' && getBroswer().version<'72') {
            rtc.resumeStreams();
        }
    });

    //chrome60以下不支持popover，防止error
    if (getBroswer().broswer=='Chrome' && getBroswer().version<'60')
        return;
    //开启popover
    $(function () {
        $('[data-toggle="popover"]').popover()
    })
    $('#camera').popover({
        html: true,
        content: () => {
            return $('#camera-option').html();
        }
    });
    $('#microphone').popover({
        html: true,
        content: () => {
            return $('#mic-option').html();
        }
    });

    $('#camera').on('click', () => {
        $('#microphone').popover('hide');
        $('.popover-body').find('div').attr('onclick', 'setCameraId(this)');
    });

    $('#microphone').on('click', () => {
        $('#camera').popover('hide');
        $('.popover-body').find('div').attr('onclick', 'setMicId(this)');
    });

    //点击body关闭popover
    $('body').click(() => {
        $('#camera').popover('hide');
        $('#microphone').popover('hide');
    });

    //popover事件
    $('#camera').on('show.bs.popover', () => {
        $('#camera').attr('src', './img/camera-on.png');
    });
    $('#camera').on('hide.bs.popover', () => {
        $('#camera').attr('src', './img/camera.png');
    });

    $('#microphone').on('show.bs.popover', () => {
        $('#microphone').attr('src', './img/mic-on.png');
    });
    $('#microphone').on('hide.bs.popover', () => {
        $('#microphone').attr('src', './img/mic.png');
    });
}

function setCameraId(thisDiv) {
    cameraId = $(thisDiv).attr('id');
    console.log('setCameraId: ' + cameraId);
}

function setMicId(thisDiv) {
    micId = $(thisDiv).attr('id');
    console.log('setMicId: ' + micId);
}

function addVideoView(id, isLocal = false) {
    let div = $('<div/>', {
        id: id,
        class: 'video-box',
        style: 'justify-content: center'
    });
    div.appendTo('#video-grid');
    //设置监听
    div.click(() => {
        let mainVideo = $('.video-box').first();
        if (div.is(mainVideo)) {
            return;
        }
        //释放main-video grid-area
        mainVideo.css('grid-area', 'auto/auto/auto/auto');
        exchangeView(div, mainVideo);
        //将video-grid中第一个div设为main-video
        $('.video-box').first().css('grid-area', '1/1/3/4');
        //chromeM71以下会自动暂停，手动唤醒
        if (getBroswer().broswer=='Chrome' && getBroswer().version<'72') {
            rtc.resumeStreams();
        }
    });
}

function addMemberView(id) {
    let memberElm = $('#member-me').clone();
    memberElm.attr('id', id);
    memberElm.find('div.member-id').html(id);
    memberElm.css('display', 'flex');
    memberElm.appendTo($('#member-list'));
}

function removeView(id) {
    if ($('#' + id)[0]) {
        $('#' + id).remove();
        //将video-grid中第一个div设为main-video
        $('.video-box').first().css('grid-area', '1/1/3/4');
    }
}

function exchangeView(a, b) {
    var $div1 = $(a);
    var $div3 = $(b);
    var $temobj1 = $("<div></div>");
    var $temobj2 = $("<div></div>");
    $temobj1.insertBefore($div1);
    $temobj2.insertBefore($div3);
    $div1.insertAfter($temobj2);
    $div3.insertAfter($temobj1);
    $temobj1.remove();
    $temobj2.remove();
}

function isPC() {
    var userAgentInfo = navigator.userAgent;
    var Agents = new Array('Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod');
    var flag = true;
    for (var v = 0; v < Agents.length; v++) {
        if (userAgentInfo.indexOf(Agents[v]) > 0) {
            flag = false;
            break;
        }
    }
    return flag;
}

function getCameraId() {
    console.log('selected cameraId: ' + cameraId);
    return cameraId;
}

function getMicrophoneId() {
    console.log('selected microphoneId: ' + micId);
    return micId;
}

function throttle(func, delay) {
    var timer = null;
    var startTime = Date.now();
    return function () {
        var curTime = Date.now();
        var remaining = delay - (curTime - startTime);
        var context = this;
        var args = arguments;
        clearTimeout(timer);
        if (remaining <= 0) {
            func.apply(context, args);
            startTime = Date.now();
        } else {
            timer = setTimeout(() => {
                console.log('duplicate click');
            }, remaining);
        }
    };
}

function resetView() {
    isCamOn = true;
    isMicOn = true;
    isScreenOn = false;
    isJoined = true;
    $('#main-video-btns').hide();
    $('#video-btn').attr('src', './img/big-camera-on.png');
    $('#mic-btn').attr('src', './img/big-mic-on.png');
    $('#screen-btn').attr('src', './img/screen-off.png');
    $('#member-me').find('.member-video-btn').attr('src', 'img/camera-on.png');
    $('#member-me').find('.member-audio-btn').attr('src', 'img/mic-on.png');
    $('.mask').hide();
    //清空member-list
    if ($('#member-list')) {
        $('#member-list')
            .find('.member')
            .each((index, element) => {
                if ($(element).parent().attr('id') != 'member-me') {
                    $(element).parent().remove();
                }
            });
    }
}

function getBroswer(){
    var sys = {};
    var ua = navigator.userAgent.toLowerCase();
    var s;
    (s = ua.match(/edge\/([\d.]+)/)) ? sys.edge = s[1] :
    (s = ua.match(/rv:([\d.]+)\) like gecko/)) ? sys.ie = s[1] :
    (s = ua.match(/msie ([\d.]+)/)) ? sys.ie = s[1] :
    (s = ua.match(/firefox\/([\d.]+)/)) ? sys.firefox = s[1] :
    (s = ua.match(/chrome\/([\d.]+)/)) ? sys.chrome = s[1] :
    (s = ua.match(/opera.([\d.]+)/)) ? sys.opera = s[1] :
    (s = ua.match(/version\/([\d.]+).*safari/)) ? sys.safari = s[1] : 0;

    if (sys.edge) return { broswer : "Edge", version : sys.edge };
    if (sys.ie) return { broswer : "IE", version : sys.ie };
    if (sys.firefox) return { broswer : "Firefox", version : sys.firefox };
    if (sys.chrome) return { broswer : "Chrome", version : sys.chrome };
    if (sys.opera) return { broswer : "Opera", version : sys.opera };
    if (sys.safari) return { broswer : "Safari", version : sys.safari };
    
    return { broswer : "", version : "0" };
}

function isHidden() {
    var hidden, visibilityChange; 
    if (typeof document.hidden !== "undefined") {
        hidden = "hidden";
        visibilityChange = "visibilitychange";
    } else if (typeof document.msHidden !== "undefined") {
        hidden = "msHidden";
        visibilityChange = "msvisibilitychange";
    } else if (typeof document.webkitHidden !== "undefined") {
        hidden = "webkitHidden";
        visibilityChange = "webkitvisibilitychange";
    }
    return document[hidden];
}
