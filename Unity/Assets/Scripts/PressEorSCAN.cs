using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PressEorSCAN : MonoBehaviour
{
    // Start is called before the first frame update
    public Button button; // Reference to your button

    void Update()
    {
        // Check if the 'E' key is pressed
        if (Input.GetKeyDown(KeyCode.E))
        {
            if (button != null && button.interactable) // Ensure the button is not null or disabled
            {
                button.onClick.Invoke(); // Trigger the button click event
            }
        }
    }
}
