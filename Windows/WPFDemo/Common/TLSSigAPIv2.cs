using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using zlib;

namespace tencentyun
{
    public class TLSSigAPIv2
    {
        private readonly int sdkappid;
        private readonly string key;

        public TLSSigAPIv2(int sdkappid, string key)
        {
            this.sdkappid = sdkappid;
            this.key = key;
        }

        private static byte[] CompressBytes(byte[] sourceByte)
        {
            MemoryStream inputStream = new MemoryStream(sourceByte);
            Stream outStream = CompressStream(inputStream);
            byte[] outPutByteArray = new byte[outStream.Length];
            outStream.Position = 0;
            outStream.Read(outPutByteArray, 0, outPutByteArray.Length);
            return outPutByteArray;
        }

        private static Stream CompressStream(Stream sourceStream)
        {
            MemoryStream streamOut = new MemoryStream();
            ZOutputStream streamZOut = new ZOutputStream(streamOut, zlibConst.Z_DEFAULT_COMPRESSION);
            CopyStream(sourceStream, streamZOut);
            streamZOut.finish();
            return streamOut;
        }

        public static void CopyStream(System.IO.Stream input, System.IO.Stream output)
        {
            byte[] buffer = new byte[2000];
            int len;
            while ((len = input.Read(buffer, 0, 2000)) > 0)
            {
                output.Write(buffer, 0, len);
            }
            output.Flush();
        }

        private string HMACSHA256(string identifier, long currTime, int expire, string base64UserBuf, bool userBufEnabled)
        {
            string rawContentToBeSigned = "TLS.identifier:" + identifier + "\n"
                 + "TLS.sdkappid:" + sdkappid + "\n"
                 + "TLS.time:" + currTime + "\n"
                 + "TLS.expire:" + expire + "\n";
            if (true == userBufEnabled)
            {
                rawContentToBeSigned += "TLS.userbuf:" + base64UserBuf + "\n";
            }
            using (HMACSHA256 hmac = new HMACSHA256())
            {
                UTF8Encoding encoding = new UTF8Encoding();
                Byte[] textBytes = encoding.GetBytes(rawContentToBeSigned);
                Byte[] keyBytes = encoding.GetBytes(key);
                Byte[] hashBytes;
                using (HMACSHA256 hash = new HMACSHA256(keyBytes))
                    hashBytes = hash.ComputeHash(textBytes);
                return Convert.ToBase64String(hashBytes);
            }
        }

        private string GenSig(string identifier, int expire, byte[] userbuf, bool userBufEnabled)
        {
            DateTime epoch = new DateTime(1970, 1, 1); // unix 时间戳
            Int64 currTime = (Int64)(DateTime.UtcNow - epoch).TotalMilliseconds / 1000;

            string base64UserBuf;
            string jsonData;
            if (true == userBufEnabled)
            {
                base64UserBuf = Convert.ToBase64String(userbuf);
                string base64sig = HMACSHA256(identifier, currTime, expire, base64UserBuf, userBufEnabled);
                dynamic jsonObj = new JObject();
                jsonObj["TLS.ver"] = "2.0";
                jsonObj["TLS.identifier"] = identifier;
                jsonObj["TLS.sdkappid"] = sdkappid;
                jsonObj["TLS.expire"] = expire;
                jsonObj["TLS.time"] = currTime;
                jsonObj["TLS.sig"] = base64sig;
                jsonObj["TLS.userbuf"] = base64UserBuf;
                jsonData = JsonConvert.SerializeObject(jsonObj);
            }
            else
            {
                string base64sig = HMACSHA256(identifier, currTime, expire, "", false);
                dynamic jsonObj = new JObject();
                jsonObj["TLS.ver"] = "2.0";
                jsonObj["TLS.identifier"] = identifier;
                jsonObj["TLS.sdkappid"] = sdkappid;
                jsonObj["TLS.expire"] = expire;
                jsonObj["TLS.time"] = currTime;
                jsonObj["TLS.sig"] = base64sig;
                jsonData = JsonConvert.SerializeObject(jsonObj);
            }
            byte[] buffer = Encoding.UTF8.GetBytes(jsonData);
            return Convert.ToBase64String(CompressBytes(buffer))
                .Replace('+', '*').Replace('/', '-').Replace('=', '_');
        }

        public string GenSig(string identifier, int expire = 180 * 86400)
        {
            return GenSig(identifier, expire, null, false);
        }

        public string GenSigWithUserBuf(string identifier, int expire, byte[] userbuf)
        {
            return GenSig(identifier, expire, userbuf, true);
        }
    }
}
