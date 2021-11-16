import TrtcElectronEducation from './TRTCElectronEducation';

interface TrtcUtil {
  trtcEducation: TrtcElectronEducation | null;
}

export const trtcUtil: TrtcUtil = {
  trtcEducation: new TrtcElectronEducation(),
};

export function initTRTCEducation(config: any) {
  // trtcUtil.trtcEducation = new TrtcElectronEducation(config);
}
