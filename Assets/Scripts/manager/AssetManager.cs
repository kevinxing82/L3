using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.U2D;

public class AssetManager
{
    public bool isLoadAB
    {
        get
        {
#if UNITY_EIDTOR
                return VersionManager.useABResource;
#else
            return true;
#endif
        }
    }
    private static AssetManager _ins;
    private Dictionary<string, Object> _assetDic;
    private Dictionary<string, ObjectCallback> _loadDic;
    private AssetManager()
    {
        _assetDic = new Dictionary<string, Object>();
        _loadDic = new Dictionary<string, ObjectCallback>();
    }

    public static AssetManager GetIns()
    {
        if (_ins == null)
        {
            _ins = new AssetManager();
        }
        return _ins;
    }

    public void GetAssetFromAtlas(string atlasUrl, string spName, ObjectCallback completeHandler)
    {
        if (_assetDic.ContainsKey(atlasUrl))
        {
            SpriteAtlas spa = (SpriteAtlas)_assetDic[atlasUrl];
            Sprite sp = spa.GetSprite(spName);
            completeHandler(sp);
        }
     }

    public void GetAsset(string name, ObjectCallback completeHandler)
    {
        string path = isLoadAB ? Path.Combine(Application.streamingAssetsPath, name + ".ab") : name;

        if (_assetDic.ContainsKey(path))
        {
            completeHandler(_assetDic[path]);
        }
        else if (_loadDic.ContainsKey(path))
        {
            _loadDic[path] += completeHandler;
        }
        else
        {
            _loadDic[path] = completeHandler;

            ILoader loader;
            if (isLoadAB)
            {
                loader = new ABLoader(name, path, (Object obj) =>
                {
                    _assetDic[path] = obj;
                    _loadDic[path]?.Invoke(obj);
                    _loadDic.Remove(path);
                });
            }
            else
            {
                loader = new PrefabLoader(path, (Object obj) =>
                {
                    _assetDic[path] = obj;
                    _loadDic[path]?.Invoke(obj);
                    _loadDic.Remove(path);
                });
            }
            loader.Load();
        }
    }
}