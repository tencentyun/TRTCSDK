export interface ClientOptions {
  sdkAppId: number;
  userId: string;
  roomId: number;
  secretKey?: string;
  userSig?: string;
}
export type DeviceItem = Record<string, any>;
