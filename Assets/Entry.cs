using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public struct DownloadInfo
{
    public string name;
    public string md5;
    public long size;

    public void Clone(DownloadInfo info)
    {
        this.name = info.name;
        this.md5 = info.md5;
        this.size = info.size;
    }
}

public class Entry : MonoBehaviour
{
    private Toggle _useThreadButton;
    private Toggle _useCorotineButton;
    private int _workerNum;
    private InputField _workerInputField;
    private Button _actionButton;
    private Text _logText;
    private Text _actionButtonText;
    private ScrollRect _scrollview;

    private DownloadOnCoroutine downloadOnCoroutine;
    private DownloadOnThread downloadOnThread;

    private bool _isRunning = false;
    // Start is called before the first frame update
    void Start()
    {
        var root = GameObject.Find("Canvas");
        _useThreadButton = root.transform.Find("Tog/Tog_Thread").GetComponent<Toggle>();
        _useCorotineButton = root.transform.Find("Tog/Tog_Cortoine").GetComponent<Toggle>();
        _workerInputField = root.transform.Find("InputField").GetComponent<InputField>();
        _actionButton = root.transform.Find("Button").GetComponent<Button>();
        _actionButtonText = root.transform.Find("Button/Text").GetComponent<Text>();
       _logText = root.transform.Find("ScrollView/Viewport/Content").GetComponent<Text>();
        _scrollview = root.transform.Find("ScrollView").GetComponent<ScrollRect>();

        _actionButton.onClick.AddListener(OnActionClick);
        _useThreadButton.onValueChanged.AddListener(OnThreadToggleClick);
        _useCorotineButton.onValueChanged.AddListener(OnCoroutineToggleClick);

        downloadOnCoroutine = GameObject.Find("DownloadObj").GetComponent<DownloadOnCoroutine>();
        downloadOnThread = GameObject.Find("DownloadObj").GetComponent<DownloadOnThread>();
    }

    private void OnActionClick()
    {
        string numTxt = _workerInputField.text;
        int num ;
        if (string.IsNullOrEmpty(numTxt))
        {
            num = 0;
        }
        else
        {
            num = int.Parse(numTxt);
        }
        
        if(_isRunning)
        {
            if (_useThreadButton.isOn)
            {
                downloadOnThread.Stop();
            }
            else
            {
                downloadOnCoroutine.Stop();
            }
            _actionButtonText.text = "Start";
            _isRunning = false;
        }
        else
        {
            if (_useThreadButton.isOn)
            {
                downloadOnThread.SetWorkNum(num);
                downloadOnThread.Run();
            }
            else
            {
                downloadOnCoroutine.SetWorkNum(num);
                downloadOnCoroutine.Run();
            }
            _actionButtonText.text = "Stop";
            _isRunning = true;
        }
    }

    private void OnThreadToggleClick(bool action)
    {
        if(action)
        {
            downloadOnCoroutine.enabled = false;
            downloadOnThread.enabled = true;
        }
    }

    private void OnCoroutineToggleClick(bool action)
    {
        if(action)
        {
            downloadOnCoroutine.enabled = true;
            downloadOnThread.enabled = false;
        }
    }

    private void Update()
    {
        if(_isRunning)
        {
            string cache = "";
            if (_useThreadButton.isOn)
            {
                cache = downloadOnThread.log;
            }
            else
            {
                cache = downloadOnCoroutine.log;
            }

            if (cache.Length < 10000)
            {
                _logText.text = cache;
            }
            else
            {
                _logText.text = cache.Substring(cache.Length - 10000, 10000);
            }
            _scrollview. verticalNormalizedPosition = 0f;
        }
    }

    // Update is called once per frame
}
