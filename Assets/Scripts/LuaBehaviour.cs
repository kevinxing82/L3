using UnityEngine;
using UnityEngine.Events;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

public class LuaBehaviour : MonoBehaviour
{
    public UnityAction<LuaTable> onStart;
    public UnityAction<LuaTable> onEnable;
    public UnityAction<LuaTable> onDisable;
    public UnityAction<LuaTable> onUpdate;
    public UnityAction<LuaTable> onLateUpdate;
    public UnityAction<LuaTable> onFixedUpdate;
    public UnityAction<LuaTable> onDestroy;
    public UnityAction<LuaTable> onValueChanged;

    [HideInInspector] public string luaPath;

    public LuaTable component;

    void Awake()
    {
        var bind = LuaClient.GetMainState().GetFunction("bind");
        bind.Call(this);
        bind.Dispose();
        bind = null;
    }
    void Start() { if (onStart != null) onStart(component); }
    void OnEnable() { if (onEnable != null) onEnable(component); }
    void OnDisable() { if (onDisable != null && LuaClient.Instance != null) onDisable(component); }
    void Update() { if (onUpdate != null) onUpdate(component); }
    void LateUpdate() { if (onLateUpdate != null) onLateUpdate(component); }
    void FixedUpdate() { if (onFixedUpdate != null) onFixedUpdate(component); }

    void OnDestroy()
    {
        if (onDestroy != null && LuaClient.Instance != null) onDestroy(component);
        if (component != null)
        {
            component.Dispose();
            component = null;
        }
    }
}