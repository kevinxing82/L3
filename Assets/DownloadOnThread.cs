using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

public class DownloadOnThread : MonoBehaviour
{
    private int downloaded = 0;
    private int downloading = 0;
    // Start is called before the first frame update
    private float startTime = 0f;
    private HttpLoader loader;
    private int _workerNum= 0;
    private string _log = "";
    private bool isRunning = false;
    Queue<DownloadInfo> _downloadList = new Queue<DownloadInfo>();
    Queue<DownloadInfo> _checkList = new Queue<DownloadInfo>();
    private string storagePath;
    void Start()
    {
        storagePath = Application.persistentDataPath.ToString();
    }

    public string log
    {
        get
        {
            return _log;
        }
    }

    public void SetWorkNum(int num)
    {
        _workerNum = num;
    }

    public void Run()
    {
        isRunning = true;
        StartCoroutine(GetTextCnfg());
    }

    public void Stop()
    {
        isRunning = false;
        loader.Stop();
    }

    IEnumerator GetTextCnfg()
    {
        UnityWebRequest www = UnityWebRequest.Get("http://47.111.1.169/t3/xueli.bzcs.android.game_0628/files.txt");
        yield return www.SendWebRequest();

        if (www.isNetworkError || www.isHttpError)
        {
            Log(www.error);
        }
        else
        {
            Log("Download cnfg");
            // Show results as text
            string cnfg = www.downloadHandler.text;

            string[] lines = cnfg.Split(new char[] { '\r', '\n' });

            Queue<DownloadInfo> urlList = new Queue<DownloadInfo>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (!string.IsNullOrEmpty(lines[i]))
                {
                    string[] cut = lines[i].Split('|');
                    string name = string.Empty;
                    string md5 = string.Empty;
                    long size = 0L;

                    DownloadInfo data = new DownloadInfo();
                    data.name = cut[0];
                    data.md5 = cut[1];
                    data.size = long.Parse(cut[2]);

                    urlList.Enqueue(data);
                }
            }

            _downloadList = new Queue<DownloadInfo>();
            for(int i=0;i<100;i++)
            {
                DownloadInfo info = urlList.Dequeue();
                _downloadList.Enqueue(info);
                DownloadInfo info2 = new DownloadInfo();
                info2.Clone(info);
                _checkList.Enqueue(info2);
            }
           
            
            loader = new HttpLoader(_workerNum);
            loader.SetLogCallback((s) => { Log(s); });
            loader.SetCompleteCallback(checkDownloadFile);
            loader.load(_downloadList, storagePath);
            yield break;
        }
    }

    private void checkDownloadFile()
    {
        int errorCount = 0;
        Log("Check Download File");
        int index = 0;
        foreach(var info in _checkList)
        {
            Log("Process......"+index++);
            string path = Path.Combine(storagePath,info.name);
            if(!File.Exists(path))
            {
                Log(path + " do not exist");
                errorCount++;
                continue;
            }
            string md5 = MD5file(path);
            if(md5.Equals(info.md5))
            {
                continue;
            }
            else
            {
                Log(info.name + " is not correct file data");
                errorCount++;
            }
        }
        if(errorCount==0)
        {
            Log("Load Success!");
        }
        else
        {
            Log("Load Faild! Error:"+errorCount);
        }
    }

    private void Log(string log)
    {
        Debug.Log(log);
        _log += log + "\n";
    }
    private void OnDestroy()
    {
        if(loader!=null)
        {
            loader.Stop();
        }
    }

    public  string MD5file(string file)
    {
        FileStream fs = new FileStream(file, FileMode.Open);
        System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] retVal = md5.ComputeHash(fs);
        fs.Close();

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < retVal.Length; i++)
        {
            sb.Append(retVal[i].ToString("x2"));
        }
        return sb.ToString();
    }
}
