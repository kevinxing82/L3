using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

public class DownloadOnCoroutine : MonoBehaviour
{
    private int downloaded = 0;
    private int downloading = 0;
    // Start is called before the first frame update
    private float startTime = 0f;

    private int _wokerNum = 0;
    private string _log = "";
    private bool _isRunning;
    void Start()
    {
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
        _wokerNum = num;
    }

    public void Run()
    {
        _isRunning = true;
        StartCoroutine(GetTextCnfg());
    }

    public void Stop()
    {
        _isRunning = false;
    }
    IEnumerator GetTextCnfg()
    {
        UnityWebRequest www = UnityWebRequest.Get("http://cdn.1677yx.com/t3/xueli.bzcs.android.game_0628/files.txt");
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
            Debug.Log(cnfg.Length);

            string[] lines = cnfg.Split(new char[] { '\r', '\n' });

            Queue<DownloadInfo> urlList = new Queue<DownloadInfo>();
            for (int i = 0; i < lines.Length; i++)
            {
                if (!string.IsNullOrEmpty(lines[i]))
                {
                    //Debug.Log("package line=" + lines[i]);
                    string[] cut = lines[i].Split('|');
                    string name = string.Empty;
                    string md5 = string.Empty;
                    long size = 0L;

                    DownloadInfo info = new DownloadInfo();
                    info.name = cut[0];
                    info.md5 = cut[1];
                    info.size = long.Parse(cut[2]);

                    urlList.Enqueue(info);
                }
            }

            Log("Start download ab files:"+lines.Length);
            startTime = Time.time;

            while (downloaded <2000)
            {
                if(downloading< _wokerNum)
                {
                    StartCoroutine(DownloadAB(urlList.Dequeue().name));
                }
                yield return null;
            }
            startTime = Time.time - startTime;
            Log("Download Complete last :" + startTime);
            yield break;
        }
    }

    IEnumerator DownloadAB(string name)
    {
        if(!_isRunning)
        {
            yield break;
        }
        Log("download :" + name);
        downloading++;
        UnityWebRequest www = UnityWebRequestAssetBundle.GetAssetBundle(Path.Combine("http://cdn.1677yx.com/t3/xueli.bzcs.android.game_0628/ABWorld", name));
        yield return www.SendWebRequest();

        if (www.isNetworkError || www.isHttpError)
        {
            Log(www.error);
        }
        else
        {
            AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(www);
            downloading--;
            downloaded++;
            Log("Download complete :" + downloaded);
        }
    }

    private void Log(string log)
    {
        Debug.Log(log);
        _log+= log + "\n";
    }
}
