import { genTestUserSig } from '../../public/debug/GenerateTestUserSig'
const SDKAPPID = genTestUserSig('').sdkAppID;
export default {
  SDKAppID: SDKAPPID,
  CallTimeout: 30
}
