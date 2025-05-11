using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FinalChoice : MonoBehaviour
{
    public Button leaveButton;  // Assign in Inspector
    public Button forgiveButton;  // Assign in Inspector
    public Sprite leaveSprite;  // Assign in Inspector
    public Sprite forgiveSprite;  // Assign in Inspector
    public Image displayImage;  // Assign in Inspector
    public GameObject previous;

    void Start()
    {
        // Ensure the display image is initially not visible
        displayImage.gameObject.SetActive(false);

        // Assign button click listeners
        leaveButton.onClick.AddListener(HandleLeaveChoice);
        forgiveButton.onClick.AddListener(HandleForgiveChoice);
    }

    void HandleLeaveChoice()
    {
        previous.gameObject.SetActive(false);
        leaveButton.gameObject.SetActive(false);
        forgiveButton.gameObject.SetActive(false);
        // Show the Leave sprite
        displayImage.sprite = leaveSprite;
        displayImage.gameObject.SetActive(true);

        // Optionally, handle any other logic specific to the "Leave" choice
        Debug.Log("Player chose to leave.");
    }

    void HandleForgiveChoice()
    {
        previous.gameObject.SetActive(false);
        leaveButton.gameObject.SetActive(false);
        forgiveButton.gameObject.SetActive(false);
        // Show the Forgive sprite
        displayImage.sprite = forgiveSprite;
        displayImage.gameObject.SetActive(true);

        // Optionally, handle any other logic specific to the "Forgive" choice
        Debug.Log("Player chose to forgive.");
    }
}
