using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class ToEnding : MonoBehaviour
{
    public string endingSceneName = "EndingScene";


    // Update is called once per frame
    private void OnTriggerEnter(Collider other)
    {
        // 
        if (other.CompareTag("Player"))
        {
            Debug.Log($"{other.name} ");
            // 
            SwitchSceneWithDelay(endingSceneName, 1f);
        }
    }

    private void SwitchSceneWithDelay(string sceneName, float delay)
    {
        if (!string.IsNullOrEmpty(sceneName))
        {
            Debug.Log($"Scene switch to {sceneName} will occur in {delay} seconds.");
            StartCoroutine(SwitchSceneCoroutine(sceneName, delay));
        }
        else
        {
            Debug.LogError("Scene name is invalid or empty!");
        }
    }

    private IEnumerator SwitchSceneCoroutine(string sceneName, float delay)
    {
        yield return new WaitForSeconds(delay); //
        SceneManager.LoadScene(sceneName); // 
    }
}
