let mtaH5 = {
  reportSDKAppID: function (sdkappid) {
    if (window.MtaH5) {
      window.MtaH5.clickStat('sdkappid',{'sdkappid':sdkappid});
    }
  }
};
export default mtaH5;