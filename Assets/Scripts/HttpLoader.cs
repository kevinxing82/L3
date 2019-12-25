using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;

public class HttpLoader
{
    public System.Object downloadLock = new System.Object();
    public Queue<DownloadInfo> _downloadQueue;
    public int downloaded = 0;
    private DateTime startTime = new DateTime();
    private DateTime endTime = new DateTime();
    private System.Object startLock=new System.Object();
    private System.Object logLock = new System.Object();
    private List<Thread> _threadList = new List<Thread>();
    private int _workNum;
    private Action<string> _logCallback;
    private Action _completeCallback;
    private string _savePath;
    private string _tempSaveExt = ".downloading";
    private int _totalDownloadCount;

    public HttpLoader(int workNum)
    {
        _workNum = workNum;
        System.Net.ServicePointManager.DefaultConnectionLimit = 200;
        for (int i = 0; i < _workNum; i++)
        {
            Thread thread = new Thread(OnThread);
            _threadList.Add(thread);
        }
    }

    public void SetLogCallback(Action<string> logCallback)
    {
        _logCallback = logCallback;
    }

    public void SetCompleteCallback(Action completeCallback)
    {
        _completeCallback = completeCallback;
    }

    public void load(Queue<DownloadInfo> downloadList,string savePath)
    {
        startTime = DateTime.Now;
        _savePath = savePath;
        _downloadQueue = downloadList;
        _totalDownloadCount = downloadList.Count;
        Log("Start download ab files:" + downloadList.Count);
        foreach (var thread in _threadList)
        {
            thread.Start();
        }
    }

    public void Stop()
    {
        for (int i = 0; i < _workNum; i++)
        {
            _threadList[i].Abort();
        }
    }

    private void Log(string log)
    {
        lock (logLock)
        {
            if (_logCallback!=null)
            {
                _logCallback(log);
            }
        }
    }

    public void OnThread()
    {
        while (true)
        {
            lock (_downloadQueue)
            {
                if (_downloadQueue.Count==0)
                {
                    if(endTime.Year==1)
                    {
                        endTime = DateTime.Now;
                        float t = (float)(endTime - startTime).TotalSeconds;
                        Log("Download Complete last :" + t);
                    }
                    if(_totalDownloadCount==downloaded)
                    {
                        if (_completeCallback != null)
                        {
                            _completeCallback();
                        }
                    }
                    return;
                }
            }

            System.GC.Collect();

            HttpWebRequest request = null;
            HttpWebResponse response = null;
            Stream stream = null;
            FileStream fs = null;
            int timeout = 10 * 1000;
            DownloadInfo downloadInfo;
            lock (_downloadQueue)
            {
                downloadInfo = _downloadQueue.Dequeue();
            }
            Log("Start download :" + downloadInfo.name);
            try
            {
                string path = Path.Combine(_savePath, downloadInfo.name);
                string tmpPath = Path.Combine(_savePath, downloadInfo.name + _tempSaveExt);

                request = WebRequest.Create(Path.Combine(Path.Combine("http://47.111.1.169/t3/xueli.bzcs.android.game_0628/ABWorld", downloadInfo.name))) as HttpWebRequest;
                request.Timeout = timeout;
                request.KeepAlive = false;
                request.ServicePoint.Expect100Continue = false;
                request.ServicePoint.UseNagleAlgorithm = false;
                request.AllowWriteStreamBuffering = false;

                response = request.GetResponse() as HttpWebResponse;
                stream = response.GetResponseStream();

                if (stream.CanTimeout)
                {
                    stream.ReadTimeout = timeout;
                }

                fs = new FileStream(tmpPath, FileMode.Create, FileAccess.Write);

                byte[] buff = new byte[4096];
                int length = 0;
                while ((length = stream.Read(buff, 0, buff.Length)) > 0)
                {
                    fs.Write(buff, 0, length);
                }

                stream.Close();
                stream.Dispose();
                stream = null;

                long downloadSize  = fs.Length;
                long contentLength = response.ContentLength;

                if (fs != null)
                {
                    fs.Close();
                    fs.Dispose();
                    fs = null;
                }

                if (downloadSize != contentLength)
                {
                    throw new Exception(string.Format("url={0} fileLength={1} contentLength={2}", downloadInfo.name, downloadSize, contentLength));
                }

                if (File.Exists(path))
                {
                    File.Delete(path);
                }
                File.Move(tmpPath, path);

                lock (downloadLock)
                {
                    downloaded++;
                    Log("Download complete:" + downloaded);
                }

                response.Close();
                response.Dispose();
                response = null;

                request.Abort();
                request = null;
            }
            catch (Exception e)
            {
                Log(e.ToString());
                lock (_downloadQueue)
                {
                    _downloadQueue.Enqueue(downloadInfo);
                }

                if (response != null)
                {
                    response.Close();
                    response.Dispose();
                    response = null;
                }

                if (request != null)
                {
                    request.Abort();
                    request = null;
                }

                if (fs != null)
                {
                    fs.Close();
                    fs.Dispose();
                    fs = null;
                }
            }
        }
    }
}
