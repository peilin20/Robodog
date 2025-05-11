using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Febucci.UI.Examples;

public class ButtonAppear : MonoBehaviour
{
    private ExampleEvents exampleEvents;
    public int index;
    public GameObject canvas;
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
            canvas.SetActive(true);
            
        }


    }
}
