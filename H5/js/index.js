/* eslint-disable require-jsdoc */

// initialize userId/roomId
$('#userId').val('user_' + parseInt(Math.random() * 100000000));
$('#roomId').val('889988');

let rtc = null;

$('#join').on('click', function(e) {
  e.preventDefault();
  console.log('join');
  if (rtc) return;
  const userId = $('#userId').val();
  const roomId = $('#roomId').val();
  const config = genTestUserSig(userId);
  rtc = new RtcClient({
    userId,
    roomId,
    sdkAppId: config.sdkAppId,
    userSig: config.userSig
  });
  rtc.join();
});

$('#publish').on('click', function(e) {
  e.preventDefault();
  console.log('publish');
  if (!rtc) {
    Toast.error('请先加入房间！');
    return;
  }
  rtc.publish();
});

$('#unpublish').on('click', function(e) {
  e.preventDefault();
  console.log('unpublish');
  if (!rtc) {
    Toast.error('请先加入房间！');
    return;
  }
  rtc.unpublish();
});

$('#leave').on('click', function(e) {
  e.preventDefault();
  console.log('leave');
  if (!rtc) {
    Toast.error('请先加入房间！');
    return;
  }
  rtc.leave();
  rtc = null;
});

$('#settings').on('click', function(e) {
  e.preventDefault();
  $('#settings').toggleClass('btn-raised');
  $('#setting-collapse').collapse();
});
