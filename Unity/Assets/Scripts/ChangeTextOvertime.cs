using System.Collections;
using UnityEngine;
using TMPro;

public class ChangeTextOvertime : MonoBehaviour
{
    public TMP_Text textMeshProObject; // Assign your TextMeshPro object in the Inspector
    public string firstMessage = "Welcome to your new home, boy! It’s been a while since I’ve had company."; // Set the first message
    public string secondMessage = "Why don’t we test your abilities?"; // Set the second message
    public string thirdMessage = "Here, can you fetch me a basketball?";

    void Start()
    {
        if (textMeshProObject != null)
        {
            StartCoroutine(ChangeTextCoroutine());
        }
        else
        {
            Debug.LogError("TextMeshPro object is not assigned!");
        }
    }

    IEnumerator ChangeTextCoroutine()
    {
        textMeshProObject.text = firstMessage; // Set the first message
        yield return new WaitForSeconds(3f);  // Wait for 3 seconds
        textMeshProObject.text = secondMessage; // Change to the second message
        yield return new WaitForSeconds(3f);  // Wait for 3 seconds
        textMeshProObject.text = thirdMessage; // Change to the second message
    }
}
