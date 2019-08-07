using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.IO;
using System.Diagnostics;

namespace TRTCCSharpDemo.Common
{
    class HttpClient
    {
        private string mUserAgent = null;
        private HttpWebRequest mRequest = null;

        public HttpClient(string userAgent)
        {
            mUserAgent = userAgent;
        }

        ~HttpClient()
        {
            Close();
        }

        public void Close()
        {
            if (null != mRequest)
            {
                mRequest.Abort();
                mRequest = null;
            }
        }

        public string Get(string url, int timeout)
        {
            if (string.IsNullOrEmpty(url))
            {
                return "";
            }

            mRequest = WebRequest.Create(url) as HttpWebRequest;
            mRequest.Method = "GET";
            mRequest.UserAgent = mUserAgent;
            mRequest.Timeout = timeout;

            HttpWebResponse response = mRequest.GetResponse() as HttpWebResponse;
            Stream dataStream = response.GetResponseStream();
            StreamReader reader = new StreamReader(dataStream);

            string respData = reader.ReadToEnd();

            reader.Close();
            dataStream.Close();
            response.Close();

            return respData;
        }

        public string Post(string url, byte[] body, int timeout)
        {
            if (string.IsNullOrEmpty(url))
            {
                return "";
            }

            mRequest = WebRequest.Create(url) as HttpWebRequest;
            mRequest.Method = "POST";
            mRequest.UserAgent = mUserAgent;
            mRequest.Timeout = timeout;

            if (null != body)
            {
                mRequest.ContentLength = body.Length;
                mRequest.ContentType = "application/json; charset=utf-8";

                Stream requestStream = mRequest.GetRequestStream();
                if (null != requestStream)
                {
                    requestStream.Write(body, 0, body.Length);
                    requestStream.Close();
                }
            }

            HttpWebResponse response = mRequest.GetResponse() as HttpWebResponse;
            Stream dataStream = response.GetResponseStream();
            StreamReader reader = new StreamReader(dataStream);

            string respData = reader.ReadToEnd();

            reader.Close();
            dataStream.Close();
            response.Close();

            return respData;
        }
    }
}
