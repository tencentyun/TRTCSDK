/* eslint-disable require-jsdoc */

function addView(id) {
  if (!$('#' + id)[0]) {
    $('<div/>', {
      id,
      class: 'video-view'
    }).appendTo('#video_grid');
  }
}

function removeView(id) {
  if ($('#' + id)[0]) {
    $('#' + id).remove();
  }
}

// populate camera options
TRTC.getCameras().then(devices => {
  devices.forEach(device => {
    $('<option/>', {
      value: device.deviceId,
      text: device.label
    }).appendTo('#cameraId');
  });
});

// populate microphone options
TRTC.getMicrophones().then(devices => {
  devices.forEach(device => {
    $('<option/>', {
      value: device.deviceId,
      text: device.label
    }).appendTo('#microphoneId');
  });
});

function getCameraId() {
  const selector = document.getElementById('cameraId');
  const cameraId = selector[selector.selectedIndex].value;
  console.log('selected cameraId: ' + cameraId);
  return cameraId;
}

function getMicrophoneId() {
  const selector = document.getElementById('microphoneId');
  const microphoneId = selector[selector.selectedIndex].value;
  console.log('selected microphoneId: ' + microphoneId);
  return microphoneId;
}
