interface LocalUser {
  roomID?: string;
  userID?: string;
  role?: string;
  isCameraStarted?: boolean;
  isCameraMuted?: boolean;
  isMicStarted?: boolean;
  isMicMuted?: boolean;
  isSpeakerStarted?: boolean;
  isSpeakerMuted?: boolean;
  currentCamera?: any;
  currentMic?: any;
  currentSpeaker?: any;
  sharingScreenInfo?: any;
  isAllStudentMuted?: boolean;
  platform?: string;
  enterRoomTime?: number;
  callRollTime?: number;
  isRolled?: boolean;
}

interface StoreType {
  currentUser: LocalUser;
  messages: Array<any>;
  videoAvailableUserSet: Set<string>;
}

const store: StoreType = {
  currentUser: {
    platform: process.platform,
  },
  messages: [],
  videoAvailableUserSet: new Set(),
};

export function clearStore() {
  store.currentUser = {
    platform: process.platform,
  };
  store.messages = [];
  store.videoAvailableUserSet.clear();
}

export default store;
