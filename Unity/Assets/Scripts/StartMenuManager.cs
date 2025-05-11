using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CreditsMenuManager : MonoBehaviour
{
    public Button StartButton; 
    public Button CreditButton; 

    void Start()
    {

        // Add button listeners
        StartButton.onClick.AddListener(StartGame);
        CreditButton.onClick.AddListener(Credits);
    }

    void DisplayWinner()
    {

    }

    void StartGame()
    {
        SceneManager.LoadScene("TutorialFinal"); // Reload the current scene
    }

    void Credits()
    {

        SceneManager.LoadScene("CreditPage");
    }
}
