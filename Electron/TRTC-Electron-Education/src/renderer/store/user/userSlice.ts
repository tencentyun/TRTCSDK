import { createSlice } from '@reduxjs/toolkit';

const prelog = '[user-slice]';

export const userSlice = createSlice({
  name: 'user',
  initialState: {
    name: '',
    userID: '',
    role: 'teacher',
    isLogin: false,
    roomID: Math.floor(Math.random() * 10000000),
    classType: 'education',
    // scene: '',
    isCameraStarted: true,
    isCameraMuted: false,
    isMicStarted: true,
    isMicMuted: false,
    sharingScreenInfo: {},
    currentCamera: null,
    currentMic: null,
    currentSpeaker: null,
    isAllStudentMuted: false,
    isMutedByTeacher: false,
    isHandUpConfirmed: false,
    isLocal: true,
    platform: '',
    enterRoomTime: 0,
    callRollTime: 0,
    isRolled: false,
  },
  reducers: {
    toggleLogin: (state, action) => {
      state.isLogin = action.payload;
    },
    updateName: (state, action) => {
      console.warn(`${prelog}.updateName state:`, JSON.stringify(state));
      state.name = action.payload;
      state.userID = action.payload;
    },
    updateUserID: (state, action) => {
      console.warn(`${prelog}.updateUserID state:`, JSON.stringify(state));
      state.name = action.payload;
      state.userID = action.payload;
    },
    updateRole: (state, action) => {
      console.warn(`${prelog}.updateRole state:`, JSON.stringify(state));
      state.role = action.payload;
    },
    updateRoomID: (state, action) => {
      console.warn(`${prelog}.updateRoomID state:`, JSON.stringify(state));
      state.roomID = action.payload;
    },
    updateClassType: (state, action) => {
      console.warn(`${prelog}.updateClassType state:`, JSON.stringify(state));
      state.classType = action.payload;
    },
    // updateScene: (state, action) => {
    //   state.scene = action.payload;
    // },
    updateDeviceState: (state, action) => {
      console.warn(
        `${prelog}.updateDeviceState state:`,
        JSON.stringify(state),
        action
      );
      if (action.payload.isCameraStarted !== undefined) {
        state.isCameraStarted = action.payload.isCameraStarted;
      }
      if (action.payload.isCameraMuted !== undefined) {
        state.isCameraMuted = action.payload.isCameraMuted;
      }
      if (action.payload.isMicStarted !== undefined) {
        state.isMicStarted = action.payload.isMicStarted;
      }
      if (action.payload.isMicMuted !== undefined) {
        state.isMicMuted = action.payload.isMicMuted;
      }
    },
    updateCurrentDevice: (state, action) => {
      console.warn(
        `${prelog}.updateCurrentDevice state:`,
        JSON.stringify(state),
        action
      );
      if (action.payload.currentCamera) {
        state.currentCamera = action.payload.currentCamera;
      }
      if (action.payload.currentMic) {
        state.currentMic = action.payload.currentMic;
      }
      if (action.payload.currentSpeaker) {
        state.currentSpeaker = action.payload.currentSpeaker;
      }
    },
    updateShareScreenInfo: (state, action) => {
      console.warn(
        `${prelog}.updateShareScreenInfo state:`,
        JSON.stringify(state),
        action.payload
      );

      if (action.payload) {
        Object.entries(action.payload).forEach(([key, value]) => {
          // @ts-ignore
          state.sharingScreenInfo[key] = value;
        });
      }
    },
    updateAllStudentMuteState: (state, action) => {
      console.warn(
        `${prelog}.updateAllStudentMuteState state:`,
        JSON.stringify(state),
        action.payload
      );
      state.isAllStudentMuted = action.payload; // 或许这个就是对应传入的值？不太了解redux！
    },
    updateAllStudentRollState: (state, action) => {
      console.warn(
        `${prelog}.updateAllStudentRollState state:`,
        JSON.stringify(state),
        action.payload
      );
      state.callRollTime = action.payload;
    },
    updateRollState: (state, action) => {
      console.warn(
        `${prelog}.updateAllStudentRollState state:`,
        JSON.stringify(state),
        action.payload
      );
      state.isRolled = action.payload;
    },
    updateIsMutedByTeacher: (state, action) => {
      console.warn(
        `${prelog}.updateIsMutedByTeacher state:`,
        JSON.stringify(state),
        action.payload
      );
      state.isMutedByTeacher = action.payload;
      if (action.payload) {
        state.isHandUpConfirmed = false; // 被老师禁麦后，举手后被允许发言状态改成 false
      }
    },
    updateIsHandUpConfirmed: (state, action) => {
      console.warn(
        `${prelog}.updateIsHandUpConfirmed state:`,
        JSON.stringify(state),
        action.payload
      );
      state.isHandUpConfirmed = action.payload;
    },
    updatePlatform: (state, action) => {
      state.platform = action.payload;
    },
    updateEnterRoomTime: (state, action) => {
      state.enterRoomTime = action.payload;
    },
  },
});

export const {
  toggleLogin,
  updateName,
  updateUserID,
  updateRole,
  updateRoomID,
  updateClassType,
  // updateScene,
  updateDeviceState,
  updateCurrentDevice,
  updateShareScreenInfo,
  updateAllStudentMuteState,
  updateIsMutedByTeacher,
  updateIsHandUpConfirmed,
  updatePlatform,
  updateEnterRoomTime,
  updateAllStudentRollState,
  updateRollState,
} = userSlice.actions;

export default userSlice.reducer;
