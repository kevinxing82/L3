using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

public class VersionInfo
{
    private string _version;
    private string _framework;
    private string _assetbundle;
    public string frameworkVersion
    {
        get
        {
            return _framework;
        }
    }

    public string assetbundleVersion
    {
        get
        {
            return _assetbundle;
        }
    }

    public string version
    {
        get
        {
            return _version;
        }
    }

    public bool isValid()
    {
        return !string.IsNullOrEmpty(_version);
    }

    public VersionInfo(string version)
    {
        _version = version;
        if (string.IsNullOrEmpty(version))
        {
            _framework = string.Empty;
            _assetbundle = string.Empty;
        }
        else
        {
            string[] strs = version.Split('|');
            _framework = strs[0].Trim().ToLower();
            _assetbundle = strs[1].Trim().ToLower();
        }
    }
}

public class FileHash
{
    public string md5;
    public long size;

    public FileHash(string md5, long size)
    {
        this.md5 = md5;
        this.size = size;
    }
}
public class VersionManager : MonoBehaviour
{
    public bool useABResource;
    public bool useABLua;

    GameObject installer;

    const string filesTxt = "files.txt";
    const string versionFileName = "version.txt";
    public const string ABWorld = "ABWorld";

    private string externalStorage;

    int installerStepCounter = 0;
    int installerStepCount = 4;

    private VersionInfo installedVersion;
    private VersionInfo workVersion;
    private VersionInfo remoteVersion;

    private PackageManager packageManager;

    private bool isCheckVersionEnd;
    public VoidCallback completeCallback;

    void Awake()
    {
        installer = GameObject.Find("Canvas/Installer");
        installer.transform.SetAsLastSibling();

        packageManager = gameObject.GetComponent<PackageManager>();
    }

    string Byte2MB(long bytes)
    {
        return (bytes / 1024f / 1024f).ToString("f2");
    }

    public void StartCheckVersion()
    {
        isCheckVersionEnd = false;
        StartCoroutine(CheckVersion());
    }

    IEnumerator CheckVersion()
    {
        VersionInfo localversion;
        Debug.Log("Check Version...");
        installer.transform.Find("progress/Text").GetComponent<Text>().text = "";
        installer.transform.Find("hint").GetComponent<Text>().text = "";

        Debug.Log("Check Network Connection...");
        yield return StartCoroutine(CheckNetworkConnection());

        ClearDownloadingFiles();

        installer.transform.Find("hint").GetComponent<Text>().text = "检查版本更新中, 请您稍后...";

        if (useABResource)
        {
            //read installed version file 
            yield return StartCoroutine(ReadTextFileInternalStorage(versionFileName, delegate (string txt)
            {
                installedVersion = new VersionInfo(txt);
            }));

            if (!installedVersion.isValid())
            {
                installer.transform.Find("hint").GetComponent<Text>().text = "获取本地游戏框架版本失败";
                yield break;
            }

            Debug.Log("ReadWorkVersion");
            ReadWorkVersion(out localversion);
            yield return null;

            Debug.Log("ReadRemoteVersion");
            yield return StartCoroutine(ReadRemoteVersion(delegate(string txt)
            {
                Debug.Log("Read Remote Version Complete!");
                remoteVersion = new VersionInfo(txt);
            }));

            Debug.Log("ReadLocalFilesCnfg");
            string files = ReadLocalFilesCnfg();
            yield return null;

            if (localversion.frameworkVersion==remoteVersion.frameworkVersion)
            {
                if(localversion.assetbundleVersion==remoteVersion.assetbundleVersion)
                {
                    //Don't need update,check version complete
                    Debug.Log("Asset Newest");
                    installer.transform.Find("hint").GetComponent<Text>().text = "本地游戏资源已更新到最新";
                    StartCoroutine(EndCheckVersion());
                }
                else
                {
                    Debug.Log("Asset Old");
                    packageManager.StartUpdatePackage(files);
                    packageManager.completeCallback = OnPackageUpdateComplete;
                }
            }
            else
            {
                //need update apk if counld
                Debug.Log("[ERROR] Package Old");
#if UNITY_ANDROID && !UNITY_EDITOR
                yield return StartCoroutine(InstallApk());
#else
                installer.transform.Find("hint").GetComponent<Text>().text = "游戏安装包过期，请下载最新的安装包";
#endif
            }
        }
        else
        {
            StartCoroutine(EndCheckVersion());
        }
    }

    private void ClearExternalStorage()
    {
        string[] files = Directory.GetFiles(GameConst.ExternalStoragePrefix);
        foreach (var file in files)
        {
            File.Delete(file);
        }
    }

    private void ClearDownloadingFiles()
    {
        string[] files = Directory.GetFiles(GameConst.ExternalStoragePrefix, "*.downloading");
        foreach(var file in files)
        {
            File.Delete(file);
        }
    }

    private void OnPackageUpdateComplete()
    {
        //write remote version to local
        File.WriteAllText(GameConst.ExternalStoragePrefix + "/" + versionFileName, remoteVersion.version);

        StartCoroutine(EndCheckVersion());
    }

    private void ReadWorkVersion(out VersionInfo localversion)
    {
        //read work version file
        workVersion = new VersionInfo(ReadTextFileExtenralStorage(versionFileName));
        string version = string.Empty;
        if (workVersion.isValid())
        {
            localversion = workVersion;
        }
        else
        {
            localversion = installedVersion;
        }
        installer.transform.Find("version").GetComponent<Text>().text = "Version " + localversion.version;
        InstallerProgressBar(1f * (++installerStepCounter) / installerStepCount);
    }

    IEnumerator ReadRemoteVersion(Action<string> loadCallback)
    {
        string txtContent = string.Empty;
        externalStorage = GameConst.ExternalStoragePrefix;
        yield return StartCoroutine(VersionFileDownload(delegate (string txt)
        {
            txtContent = txt;
        }));
        loadCallback(txtContent);
        InstallerProgressBar(1f * (++installerStepCounter) / installerStepCount);
    }

    private string ReadLocalFilesCnfg()
    {
        string files = ReadTextFileExtenralStorage(filesTxt);
        if (string.IsNullOrEmpty(files))
        {
            StartCoroutine(ReadTextFileInternalStorage(filesTxt, delegate (string txt)
            {
                files = txt;
            }));
        }
        InstallerProgressBar(1f * (++installerStepCounter) / installerStepCount);
        return files;
    }

    IEnumerator CheckNetworkConnection()
    {
        installer.transform.Find("hint").GetComponent<Text>().text = "检查网络连接";

        Debug.Log("CheckNetworkConnection begin=" + Application.internetReachability);
        while (Application.internetReachability == NetworkReachability.NotReachable)
        {
            installer.transform.Find("hint").GetComponent<Text>().text = "网络连接不上";
            yield return new WaitForSeconds(1);
        }
        Debug.Log("CheckNetworkConnection end=" + Application.internetReachability);
        installer.transform.Find("hint").GetComponent<Text>().text = "网络连接正常";
    }

    IEnumerator EndCheckVersion()
    {
        yield return new WaitForEndOfFrame();
        isCheckVersionEnd = true;
        installer.SetActive(false);
        completeCallback();
    }

    IEnumerator ReadTextFileInternalStorage(string fileName, Action<string> callback)
    {
        string path =Path.Combine(GameConst.InternalStoragePrefix,fileName);

#if UNITY_ANDROID && !UNITY_EDITOR
        UnityWebRequest www = UnityWebRequest.Get(path);
        yield return www.SendWebRequest();
        callback(www.downloadHandler.text);
#else
        callback(File.ReadAllText(path));
        yield break;
#endif
    }

    string ReadTextFileExtenralStorage(string fileName)
    {
        string path = Path.Combine(GameConst.ExternalStoragePrefix, fileName);
        if(File.Exists(path))
        {
            return File.ReadAllText(path);
        }
        return string.Empty;
    }

    void InstallerProgressSpeed(string downloadName, long downloadSize, long downloadSpeed)
    {
        var text = string.Format("{0} 更新{1}MB 下载速度{2}MB/S", downloadName, Byte2MB(downloadSize), Byte2MB(downloadSpeed));
        installer.transform.Find("hint").GetComponent<Text>().text = text;
    }

    void InstallerProgressBar(float downloadPercent)
    {
        installer.transform.Find("progress/Image").GetComponent<Image>().fillAmount = downloadPercent;
        installer.transform.Find("progress/Text").GetComponent<Text>().text = Math.Floor(downloadPercent * 100) + "%";
    }

    IEnumerator InstallApk()
    {
        yield break;
    }

    bool isTextDownloadSuccess = false;
    string versionFileContent = string.Empty;

    IEnumerator VersionFileDownload(Action<string> callback)
    {
        isTextDownloadSuccess = false;
        versionFileContent = string.Empty;

        VersionFileDownloadCompleted(false, versionFileName, null);

        while (!isTextDownloadSuccess)
        {
            yield return null;
        }
        callback(versionFileContent);
    }

    private void VersionFileDownloadCompleted(bool isSuccess, string fileName, string content)
    {
        if (isCheckVersionEnd)
        {
            return;
        }

        if (isSuccess)
        {
            isTextDownloadSuccess = true;
           versionFileContent = content;
        }
        else
        {
            var local = externalStorage + "/";
            var remote = GameConst.WebServer + "/";
            HttpDownloader downloader = new HttpDownloader(remote, local, fileName, null, VersionFileDownloadCompleted);
        }
    }
}
