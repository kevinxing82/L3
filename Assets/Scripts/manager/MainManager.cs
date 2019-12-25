using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public delegate void VoidCallback();
public delegate void ObjectCallback(Object obj);
public class MainManager : MonoBehaviour
{
    private VersionManager version;
    private PackageManager package;

    private VoidCallback onFixedUpdate;
    private VoidCallback onUpdate;
    void Awake()
    {
        Init();
    }

    private void Init()
    {
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Application.targetFrameRate = 30;

        CanvasScaler canvasScaler = GameObject.Find("Canvas").GetComponent<CanvasScaler>();
        float targetWidth = canvasScaler.referenceResolution.x;
        float targetHeight = canvasScaler.referenceResolution.y;
        int deviceWidth = Screen.width;
        int deviceHeight = Screen.height;
        float targetRatio = (float)targetWidth / targetHeight;
        float deviceRatio = (float)deviceWidth / deviceHeight;

        if (deviceRatio < targetRatio)
        {
            canvasScaler.matchWidthOrHeight = 0;
        }
        else
        {
            canvasScaler.matchWidthOrHeight = 1;
        }

        StartCoroutine(RunOnNextFrame());
    }

    IEnumerator RunOnNextFrame()
    {
        version = gameObject.AddComponent<VersionManager>();
        version.completeCallback = CheckVersionCallback;
        package = gameObject.gameObject.AddComponent<PackageManager>();

        yield return new WaitForEndOfFrame();

        version.StartCheckVersion();
    }

    void CheckVersionCallback()
    {
        Debug.Log("CheckVersionCallback");
        InitWorld();
    }

    private void InitWorld()
    {
        gameObject.AddComponent<LuaClient>();
        SocketManager.init();
    }

    public void OnFixedUpdateCallback(LuaInterface.LuaFunction callback)
    {
        onFixedUpdate = () =>
        {
            callback.Call();
        };
    }

    public  void OnUpdateCallback(LuaInterface.LuaFunction callback)
    {
        onUpdate = () =>
          {
              callback.Call();
          };
    }

    void FixedUpdate()
    {
        SocketManager.update();
        onFixedUpdate?.Invoke();
    }

    void onExternalInterface(string jsonStr)
    {
        LuaClient.GetMainState().GetFunction("onExternalInterface").Call(jsonStr);
    }

    void OnDestroy()
    {
        SocketManager.destroy();
    }
    private void OnApplicationQuit()
    {
        OnDestroy();

#if UNITY_EDITOR
        UnityEditor.EditorUtility.UnloadUnusedAssetsImmediate(true);
#endif
        Application.Unload();
        System.GC.Collect();
    }

    // Update is called once per frame
    void Update()
    {
        onUpdate?.Invoke();
    }
}
