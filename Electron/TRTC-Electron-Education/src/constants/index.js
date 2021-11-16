/**
 * 这个常量定义模块，即用于 main 目录下各个 ts 模块，也用 main/preload.js 模块，
 * 此处定义为 node.js module 格式，以上两类模块都可使用。
 *
 * 如果此处定义为 ES 6 模块（使用 import/export )，则 preload.js 模块无法使用，
 * 原因是 preload.js 文件是一个原生 node.js module 执行文件，后续如果 preload.js
 * 承担职责过多，代码复杂度较大，可以考虑使用。
 */

const USER_EVENT_NAME = {
  // App event name
  INIT_DATA: 'init-data',
  ENTER_CLASS_ROOM: 'enter-class-room',
  EXIT_CLASS_ROOM: 'exit-class-room',
  CLOSE_CLASS_ROOM: 'close-class-room',
  STUDENT_ENTER_CLASS_ROOM: 'student-enter-class-room',
  STUDENT_EXIT_CLASS_ROOM: 'student-exit-class-room',
  ENTER_SHARE_ROOM: 'enter-share-room',
  EXIT_SHARE_ROOM: 'exit-share-room',
  CHANGE_SHARE_SCREEN_WINDOW: 'change-screen-sharing',
  CONFIRM_CHANGE_SHARE: 'confirm-change-sharing',
  CANCEL_CHANGE_SHARE: 'cancel-change-sharing',
  ON_CHANGE_LOCAL_USER_STATE: 'on-local-video-available',
  ON_CHANGE_SHARE_PREVIEW_MODE: 'on-change-share-preview-mode',
  ON_WINDOW_SHOW: 'on-window-show',
  ON_MUTE_ALL_STUDENT: 'on-mute-all-student',
  ON_HANDS_UP: 'on-hands-up',
  ON_CONFIRM_HAND_UP: 'on-confirm-hand-up',
  TEACHER_GROUP_DISMISSED: 'teacher-group-dismissed',
  STUDENT_JOIN_CLASS: 'student-join-class',
  // TIM event name
  ON_MESSAGE_RECEIVED: 'on-message-received',
  // TRTC event name
  ON_REMOTE_USER_ENTER_ROOM: 'onRemoteUserEnterRoom',
  ON_REMOTE_USER_LEAVE_ROOM: 'onRemoteUserLeaveRoom',
  ON_USER_VIDEO_AVAILABLE: 'onUserVideoAvailable',
  ON_USER_AUDIO_AVAILABLE: 'onUserAudioAvailable',
  ON_USER_SUB_STREAM_AVAILABLE: 'onUserSubStreamAvailable',
  GET_GROUP_MEMBER_LIST: 'get-group-memberList',
  ON_CLASS_MEMBER_ENTER: 'on-class-member-enter',
  ON_CLASS_MEMBER_QUIT: 'on-class-member-quit',
  ON_CHAT_MESSAGE: 'on-chat-message',
  ON_CLASS_TIME: 'on-class-time',
  ON_OWNER_READY: 'on-owner-ready',
  ON_CALL_ROLL: 'call-roll',
  ON_CALL_ROLL_REPLY: 'call-roll-reply',
  ENTER_ROOM_SUCCESS: 'enter-room-success',
  LEAVE_ROOM_SUCCESS: 'leave-room-success',
  SDK_READY_SUCCESS: 'sdk-ready-success',
};

module.exports = {
  USER_EVENT_NAME,
};
