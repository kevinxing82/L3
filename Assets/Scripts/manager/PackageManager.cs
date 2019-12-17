using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

public class PackageManager : MonoBehaviour
{
    const string filesTxt = "files.txt";
    const string dlcTxt = "dlc.txt";

    GameObject installer;

    private Dictionary<string, FileHash> localFilesHash = new Dictionary<string, FileHash>();
    private Dictionary<string, FileHash> remoteFilesHash = new Dictionary<string, FileHash>();
    private Dictionary<string, FileHash> dlcFilesHash = new Dictionary<string, FileHash>();

    private int diffStep = 0;

    private bool isUpdatePackageEnd;
    private Queue<string> downloadQueue;
    private System.Object downloadSpeedLock = new System.Object();
    private long downloadSpeed =0L;

    private int downloadRequestCount = 0;
    private System.Object completedCountLock = new System.Object();
    private int completedRequestCount = 0;
    private float downloadInterval = 0f;
    private long downloadSize = 0L;

    private string externalStorge = "";

    public VoidCallback completeCallback;
    void Awake()
    {
        installer = GameObject.Find("Canvas/Installer");
    }
    public void  StartUpdatePackage(string localFilesCnfg)
    {
        isUpdatePackageEnd = false;
        localFilesHash = GetFilesHash(localFilesCnfg);

        StartCoroutine(UpdatePackage());
    }

    IEnumerator UpdatePackage()
    {
        installer.transform.Find("hint").GetComponent<Text>().text = "开始更新游戏资源";

        InstallerProgressBar(1f / 2);
        yield return UpdateFilesCnfg();

        InstallerProgressBar(2f / 2);
        yield return UpdateDLCCnfg();

        installer.transform.Find("hint").GetComponent<Text>().text = "正在校验资源文件";
        StartCoroutine(UpdateDiffList());
        while(downloadQueue==null)
        {
            InstallerProgressBar(1f * (diffStep) / remoteFilesHash.Count);
            yield return null;
        }
        
        //download assetbunlde
        installer.transform.Find("hint").GetComponent<Text>().text = "开始下载资源文件";
        externalStorge = GameConst.ExternalStoragePrefix;
        yield return null;
        if (downloadQueue.Count > 0)
        {
            yield return StartCoroutine(DownloadNewPackage());
        }

        installer.transform.Find("hint").GetComponent<Text>().text = "下载资源文件完成";
        yield return null;

        isUpdatePackageEnd = true;
        completeCallback();
    }

    //read remote files.txt
    IEnumerator UpdateFilesCnfg()
    {
        string remoteFilesCnfg = string.Empty;
        yield return StartCoroutine(FilesCnfgDownload(delegate (string txt)
        {
            remoteFilesCnfg = txt;
        }));
        if (!string.IsNullOrEmpty(remoteFilesCnfg))
        {
            remoteFilesHash = GetFilesHash(remoteFilesCnfg);
        }
    }

    //read remote dlc.txt
    IEnumerator UpdateDLCCnfg()
    {
        string remoteDLCCnfg = string.Empty;
        yield return StartCoroutine(DLCCnfgDownload(delegate (string txt)
        {
            remoteDLCCnfg = txt;
        }));
        if (!string.IsNullOrEmpty(remoteDLCCnfg))
        {
            dlcFilesHash = GetFilesHash(remoteDLCCnfg);
        }
    }
    
    IEnumerator UpdateDiffList()
    {
        Debug.Log("Update diff list");
        List<string> diffList = new List<string>();
        float diffMD5Timer = 0;
        diffStep = 0;

        foreach (var kv in remoteFilesHash)
        {
            diffStep++;

            string fileName = kv.Key;
            string externalFileUrl = Path.Combine(GameConst.ExternalStoragePrefix, fileName);

            diffMD5Timer += Time.deltaTime;
            if (diffMD5Timer >= 1)
            {
                diffMD5Timer = 0;
                yield return null;
            }

            if (dlcFilesHash.ContainsKey(fileName))
            {
                if (File.Exists(externalFileUrl))
                {
                    if (MD5file(externalFileUrl) != remoteFilesHash[fileName].md5)
                    {
                        File.Delete(externalFileUrl);
                    }
                }
                continue;
            }
            if(File.Exists(externalFileUrl))
            {
                if(MD5file(externalFileUrl)!=remoteFilesHash[fileName].md5)
                {
                    diffList.Add(fileName);
                }
            }
            else if (localFilesHash.ContainsKey(fileName))
            {
                if(localFilesHash[fileName].md5!=remoteFilesHash[fileName].md5)
                {
                    diffList.Add(fileName); 
                }
            }
            else
            {
                diffList.Add(fileName);
            }
        }
        downloadQueue = new Queue<string>(diffList);
    }

    public static string MD5file(string file)
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

    private Dictionary<string, FileHash> GetFilesHash(string txt)
    {
        string[] lines = txt.Split(new char[] { '\r', '\n' });
        Dictionary<string, FileHash> hash = new Dictionary<string, FileHash>();
        for (int i = 0; i < lines.Length; ++i)
        {
            if (!string.IsNullOrEmpty(lines[i]))
            {
                //Debug.Log("package line=" + lines[i]);
                string[] cut = lines[i].Split('|');
                string name=string.Empty;
                string md5=string.Empty;
                long size = 0L;
                if (cut.Length == 1)
                {
                    name = cut[0];
                }
                else
                {
                    name = cut[0];
                    md5 = cut[1];
                    size = long.Parse(cut[2]);
                }
                
                hash[name] = new FileHash(md5, size);
            }
        }
        return hash;
    }

    bool isTextDownloadSuccess = false;
    string filesTxtContent = string.Empty;
    string DLCTxtContent = string.Empty;

    IEnumerator FilesCnfgDownload(Action<string> callback)
    {
        isTextDownloadSuccess = false;

        FilesCnfgDownloadCompleted(false, filesTxt, null);

        if (!isTextDownloadSuccess)
        {
            yield return null;
        }
        callback(filesTxtContent);
    }

    IEnumerator DLCCnfgDownload(Action<string> callback)
    {
        isTextDownloadSuccess = false;

        DLCCnfgDownloadCompleted(false, dlcTxt, null);

        if (!isTextDownloadSuccess)
        {
            yield return null;
        }
        callback(DLCTxtContent);
    }

    private void FilesCnfgDownloadCompleted(bool isSuccess, string fileName, string content)
    {
        if (isUpdatePackageEnd)
        {
            return;
        }

        if (isSuccess)
        {
            isTextDownloadSuccess = true;
            filesTxtContent = content;
        }
        else
        {
            var local = externalStorge + "/";
            var remote = GameConst.WebServer + "/";
            HttpDownloader downloader = new HttpDownloader(remote, local, fileName, null, FilesCnfgDownloadCompleted);
        }
    }

    private void DLCCnfgDownloadCompleted(bool isSuccess, string fileName, string content)
    {
        if (isUpdatePackageEnd)
        {
            return;
        }

        if (isSuccess)
        {
            isTextDownloadSuccess = true;
            DLCTxtContent = content;
        }
        else
        {
            var local = externalStorge + "/";
            var remote = GameConst.WebServer + "/";
            HttpDownloader downloader = new HttpDownloader(remote, local, fileName, null, DLCCnfgDownloadCompleted);
        }
    }


    IEnumerator DownloadNewPackage()
    {
        downloadRequestCount = downloadQueue.Count;
        completedRequestCount = 0;
        int downloadThreadNum = Mathf.Min(8, downloadQueue.Count);
        for(int i=0;i<downloadThreadNum;i++)
        {
            NewPackageDownloadComplete(false, null);
        }

        while (true)
        {
            downloadInterval += Time.deltaTime;
            if(downloadInterval > 1.0f)
            {
                var text = string.Format("本次更新{0}MB, 下载速度{1}MB/S", Byte2MB(downloadSize), Byte2MB(downloadSpeed));
                installer.transform.Find("hint").GetComponent<Text>().text = text;

                lock (downloadSpeedLock)
                {
                    downloadSpeed = 0;
                }

                downloadInterval = 0;
            }
            
            float fillAmount = (float)(completedRequestCount) / downloadRequestCount;
            installer.transform.Find("progress/Image").GetComponent<Image>().fillAmount = fillAmount;
            installer.transform.Find("progress/Text").GetComponent<Text>().text = Math.Floor(fillAmount * 100).ToString() + "%";

            if (completedRequestCount==downloadRequestCount)
            {
                break;
            }
            yield return null;

            installer.transform.Find("hint").GetComponent<Text>().text = "更新完成";
        }
    }

    private void NewPackageDownloadComplete(bool isSuccess, string fileName)
    {
        if(isUpdatePackageEnd)
        {
            return;
        }
        if (isSuccess)
        {
            lock(completedCountLock)
            {
                completedRequestCount++;
            }
        }
        else
        {
            if(!string.IsNullOrEmpty(fileName))
            {
                downloadQueue.Enqueue(fileName);
            }
        }

        lock(downloadQueue)
        {
            if(downloadQueue.Count>0)
            {
                string name = downloadQueue.Dequeue();
                string url = GameConst.WebServer + "/ABWorld/";
                string local = externalStorge + "/";
                HttpDownloader loader = new HttpDownloader(url, local, name, NewPackageDownloadProgressCallback, NewPackageDownloadComplete);
            }
        }
    }

    private void NewPackageDownloadProgressCallback(float progress, int speed, string fileName)
    {
        lock (downloadSpeedLock)
        {
            downloadSpeed += speed;
        }
    }

    void InstallerProgressBar(float downloadPercent)
    {
        installer.transform.Find("progress/Image").GetComponent<Image>().fillAmount = downloadPercent;
        installer.transform.Find("progress/Text").GetComponent<Text>().text = Math.Floor(downloadPercent * 100) + "%";
    }

    string Byte2MB(long bytes)
    {
        return (bytes / 1024f / 1024f).ToString("f2");
    }
}
