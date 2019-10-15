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

// fix jquery touchstart event warn in chrome M76
jQuery.event.special.touchstart = {
  setup: function(_, ns, handle) {
    if (ns.includes('noPreventDefault')) {
      this.addEventListener('touchstart', handle, { passive: false });
    } else {
      this.addEventListener('touchstart', handle, { passive: true });
    }
  }
};
jQuery.event.special.touchmove = {
  setup: function(_, ns, handle) {
    if (ns.includes('noPreventDefault')) {
      this.addEventListener('touchmove', handle, { passive: false });
    } else {
      this.addEventListener('touchmove', handle, { passive: true });
    }
  }
};

const Toast = {
  info: function(msg) {
    Toastify({
      text: msg,
      duration: 3000,
      gravity: 'top', // `top` or `bottom`
      position: 'right', // `left`, `center` or `right`
      backgroundColor: '#4F85FF'
    }).showToast();
  },
  notify: function(msg) {
    Toastify({
      text: msg,
      duration: 3000,
      gravity: 'top', // `top` or `bottom`
      position: 'right', // `left`, `center` or `right`
      backgroundColor: '#2FC259'
    }).showToast();
  },
  error: function(msg) {
    Toastify({
      text: msg,
      duration: 3000,
      gravity: 'top', // `top` or `bottom`
      position: 'right', // `left`, `center` or `right`
      backgroundColor: '#FF310A'
    }).showToast();
  }
};
