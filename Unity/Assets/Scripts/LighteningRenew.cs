using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LighteningRenew : MonoBehaviour
{
    
    void Start()
    {
        //、

        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    void OnDestroy()
    {
        // 
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    // 
    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        Debug.Log($"Scene Loaded: {scene.name}");
        StartCoroutine(UpdateLightingAfterDelay());
        //DynamicGI.UpdateEnvironment(); // Force refresh of global illumination
    }

    private IEnumerator UpdateLightingAfterDelay()
    {
        yield return new WaitForSeconds(0.1f); // 延迟0.1秒，确保场景完全加载
        DynamicGI.UpdateEnvironment(); // 刷新全局光照
    }
}