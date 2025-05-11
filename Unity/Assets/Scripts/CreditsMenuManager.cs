using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CreditMenuManager : MonoBehaviour
{
    public Button StartButton; 
    public Button CreditButton; 

    void Start()
    {

        // Add button listeners
        StartButton.onClick.AddListener(StartGame);
        CreditButton.onClick.AddListener(Quit);
    }

    void DisplayWinner()
    {

    }

    void StartGame()
    {
        SceneManager.LoadScene("TutorialFinal"); // Reload the current scene
    }

    void Quit()
    {
#if UNITY_EDITOR
        // If running in the Unity Editor, stop play mode
        UnityEditor.EditorApplication.isPlaying = false;
#else
            // If running as a build, quit the application
            Application.Quit();
#endif

        Debug.Log("Game has quit."); // Optional log for debugging
    }
}
