const initConfigUtil = {
  storeLocalUserId: function(localUserId) {
    window.globalUserId = localUserId;
    window.localStorage.setItem('localUserId', localUserId);
  },
  loadLocalUserId: function() {
    return window.localStorage.getItem('localUserId') || '';
  },
  storeRoomId: function(roomId) {
    let rId = window.parseInt(roomId, 10);
    if (isNaN(rId)) {
      rId = 0;
    }
    window.globalRoomId = rId;
    window.localStorage.setItem('roomId', rId);
  },
  loadRoomId: function() {
    return window.localStorage.getItem('roomId') || 0;
  },
  removeRoomId() {
    window.localStorage.removeItem('roomId');
  }
}

export default initConfigUtil
