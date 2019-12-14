using System;
using System.Net;
using System.Threading;
using System.IO;

public class HttpDownloader {

    string url;
    string savePath;
    string savePathDownloading;
    string fileName;
    int timeout = 10 * 1000;
    bool isWriteFile = false;
    DownloadProgressCallback downloadProgressCallback = null;
    DownloadEndCallback downloadEndCallback = null;
    DownloadEndCallbackWithContent downloadEndCallbackWithContent = null;
    byte[] content;
    public static string downloadingFileExt = ".downloading";

    public delegate void DownloadProgressCallback(float progress, int speed, string fileName);
    public delegate void DownloadEndCallback(bool isSuccess, string fileName);
    public delegate void DownloadEndCallbackWithContent(bool isSuccess, string fileName, string content);

    public HttpDownloader(string url, string savePath, string fileName, DownloadProgressCallback downloadProgressCallback, DownloadEndCallback downloadEndCallback)
    {
        this.url = url + fileName;
        this.savePath = savePath + fileName;
        this.savePathDownloading = savePath + fileName + downloadingFileExt;
        this.fileName = fileName;
        this.isWriteFile = true;
        this.downloadProgressCallback = downloadProgressCallback;
        this.downloadEndCallback = downloadEndCallback;

        Thread thread = new Thread(OnThread);
        thread.IsBackground = true;
        thread.Start(this.url);
    }

    public HttpDownloader(string url, string savePath, string fileName, DownloadProgressCallback downloadProgressCallback, DownloadEndCallbackWithContent downloadEndCallbackWithContent)
    {
        this.url = url + fileName;
        this.savePath = savePath + fileName;
        this.savePathDownloading = savePath + fileName + downloadingFileExt;
        this.fileName = fileName;
        this.isWriteFile = false;
        this.downloadProgressCallback = downloadProgressCallback;
        this.downloadEndCallbackWithContent = downloadEndCallbackWithContent;

        Thread thread = new Thread(OnThread);
        thread.IsBackground = true;
        thread.Start(this.url);
    }

    void OnThread(object arg)
    {
        HttpWebRequest request = null;
        HttpWebResponse response = null;
        Stream stream = null;
        FileStream fs = null;

        try {
            request = WebRequest.Create (this.url) as HttpWebRequest;
            request.Timeout = this.timeout;
            request.KeepAlive = false;
            request.ServicePoint.Expect100Continue = false;
            request.ServicePoint.UseNagleAlgorithm = false;
            request.AllowWriteStreamBuffering = false; 

            response = request.GetResponse() as HttpWebResponse;
            stream = response.GetResponseStream();
            if (stream.CanTimeout) {
                stream.ReadTimeout = this.timeout;
            }

            if (isWriteFile) {
                fs = new FileStream (this.savePathDownloading, FileMode.Create, FileAccess.Write);
            }
            else {
                content = new byte[response.ContentLength];
            }

            // long fileLength = fs.Length;

            byte[] buff = new byte[4096];
            int length = 0;
            int destinationIndex = 0;
            while ((length = stream.Read(buff, 0, buff.Length)) > 0) {
                if (isWriteFile) {
                    fs.Write(buff, 0, length);
                }
                else {
                    Array.Copy(buff, 0, content, destinationIndex, length);
                    destinationIndex += length;
                }

                if (downloadProgressCallback != null) {
                    downloadProgressCallback(0, length, this.fileName);
                }
            } 


            stream.Close();
            stream.Dispose();
            stream = null;

            long fileLength = 0;

            if (isWriteFile) {
                fileLength = fs.Length;
            }

            long contentLength = response.ContentLength;

            if (fs != null) {
                fs.Close();
                fs.Dispose();
                fs = null;
            }

            response.Close();
            response.Dispose();
            response = null;

            request.Abort();
            request = null;

            if (isWriteFile) {
                if (fileLength != contentLength) {
                    throw new Exception(string.Format("url={0} fileLength={1} contentLength={2}", this.url, fileLength, contentLength));
                }

                if (File.Exists(this.savePath)) {
                    File.Delete(this.savePath);
                }
                File.Move(this.savePathDownloading, this.savePath);

                this.downloadEndCallback(true, this.fileName);
            }
            else {
                string str = System.Text.Encoding.Default.GetString(content);
                this.downloadEndCallbackWithContent(true, this.fileName, str);
            }
        } catch (Exception e) {
            if (stream != null) {
                stream.Close();
                stream.Dispose();
                stream = null;
            }

            if (fs != null) {
                fs.Close();
                fs.Dispose();
                fs = null;
            }

            if (File.Exists(this.savePathDownloading)) {
                File.Delete(this.savePathDownloading);
            }

            if (response != null)
            {
                response.Close();
                response.Dispose();
                response = null;
            }

            if (request != null) {
                request.Abort();
                request = null;
            }

            if (isWriteFile) {
                this.downloadEndCallback(false, this.fileName);
            }
            else {
                this.downloadEndCallbackWithContent(false, this.fileName, null);
            }
        }
    }
}
