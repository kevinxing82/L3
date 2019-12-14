using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class AppConst
{
    public static string WebServer
    {
        get
        {
            return "http://localhost/cdn/bm/";
        }
        
    }
    public static string ExternalStoragePrefix
    {
        get
        {
            return Application.persistentDataPath;
        }
    }
    public static string InternalStoragePrefix
    {
        get
        {
            return Application.streamingAssetsPath;
        }
    }
}
