using UnityEngine;
using UnityEditor;

public class Packager : ScriptableObject
{
    [MenuItem("GameTools/Packager/Win")]
    static void BuildWinRes()
    {
        EditorUtility.DisplayDialog("MyTool", "Do It in C# !", "OK", "");
    }

    [MenuItem("GameTools/Packager/Android")]
    static void BuildAndroidRes()
    {
        EditorUtility.DisplayDialog("MyTool", "Do It in C# !", "OK", "");
    }

    [MenuItem("GameTools/Packager/IOS")]
    static void BuildIOSRes()
    {
        EditorUtility.DisplayDialog("MyTool", "Do It in C# !", "OK", "");
    }
}