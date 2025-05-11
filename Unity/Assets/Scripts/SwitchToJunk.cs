using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;
using Febucci.UI.Examples;

public class SwitchToJunk : MonoBehaviour
{
    private ExampleEvents exampleEvents;
    public string junkyardSceneName = "JunkyardFinal";
    public float delay = 3f;
    public int index;

    void Start()
    {
        // 
        exampleEvents = GetComponent<ExampleEvents>();
        if (exampleEvents == null)
        {
            Debug.LogError("Failed to get ExampleEvents!");
            return;
        }
    }

    void Update()
    {
        // 
        Debug.Log($"currentindex= {index} ");
        if (exampleEvents.CurrentDialogueIndex == index)
        {
            
            Debug.Log("Currently displaying the fourth dialogue!");
            SwitchSceneWithDelay(junkyardSceneName, delay);
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



