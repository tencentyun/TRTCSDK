import { createSlice } from '@reduxjs/toolkit';

export const modalSlice = createSlice({
  name: 'modal',
  initialState: {
    isDeviceDetectOpen: false,
  },
  reducers: {
    toggleDeviceDetectModal: (state, action) => {
      state.isDeviceDetectOpen = action.payload;
    },
  },
});

export const { toggleDeviceDetectModal } = modalSlice.actions;

export default modalSlice.reducer;
