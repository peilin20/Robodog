using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using MalbersAnimations.Events;
using MalbersAnimations.Scriptables;
using MalbersAnimations.Utilities;
using MalbersAnimations.Controller;
using UnityEngine.SceneManagement;

public class UseObject : MonoBehaviour
{
    private Dictionary<string, Action> useActions = new Dictionary<string, Action>();
    public MAnimal animal;
    public GameObject airwall;
    public GameObject light;
    public GameObject tutorialFence1;
    public GameObject tutorialFence2;
    private float delay = 5f;
    private string madOwnerSceneName = "MadOwnerScene";
    private string rainbowSceneName = "EscapeJunkyard";
    // Start is called before the first frame update
    private AudioSource audioSource;

    void Start()
    {
        
        audioSource = GetComponent<AudioSource>();
        if (animal == null)
        {
            Debug.LogError("MAnimal instance not found!");
        }
        
        useActions.Add("Patch_obj", UsePatch);
        useActions.Add("Battery_obj", UseBattery);
        useActions.Add("Hole_obj", UseHole);
        useActions.Add("Basketball_obj", UseBasketball);
        useActions.Add("Sneaker_obj", UseSneaker);
        useActions.Add("Donut_obj", UseDonut);
    }

    // Update is called once per frame
    public void Use(string itemName)
    {
        if (useActions.ContainsKey(itemName))
        {
            useActions[itemName].Invoke(); // 
            audioSource.Play();
        }
        else
        {
            Debug.LogWarning($"No use logic found for item: {itemName}");
        }
    }

    private void UsePatch()
    {
        Debug.Log("Using Patch, speed & climb");
        EnableLedgeGrab();
        //ModifyTrotVerticalSpeed(2.5f);
        airwall.SetActive(false);
    }

    private void UseBattery()
    {
        Debug.Log("Using Battery, setting light transparency");

        // Get the Renderer component
        Renderer lightRenderer = light.GetComponent<Renderer>();
        if (lightRenderer != null)
        {
            // Access the material
            Material lightMaterial = lightRenderer.material;

            // Check if the material has a property for light color
            if (lightMaterial.HasProperty("_LightColor")) // Replace with actual property name from the shader
            {
                // Get the current color
                Color lightColor = lightMaterial.GetColor("_LightColor");

                // Modify the alpha (transparency)
                lightColor.a = 75f / 255f; // Set alpha to 85
                lightMaterial.SetColor("_LightColor", lightColor); // Apply the modified color

                Debug.Log("Light transparency updated successfully.");
            }
            else
            {
                Debug.LogWarning("Material does not have a '_LightColor' property!");
            }
        }
        else
        {
            Debug.LogError("Renderer component not found on the object!");
        }
        SetTagToScannableUnderParent("ScannableObjects","Bow");
        SetTagToScannableUnderParent("ScannableObjects", "Trash");
    }


    private void UseHole()
    {
        Debug.Log("Using hole, getout");
        audioSource.Play();
        SwitchSceneWithDelay(rainbowSceneName, 2f);
    }

    private void UseSneaker()
    {
        Debug.Log("Using sneaker, open fence2");
        audioSource.Play();
        tutorialFence2.SetActive(false);
    }

    private void UseBasketball()
    {
        Debug.Log("Using basketball, open fence1");
        audioSource.Play();
        tutorialFence1.SetActive(false);
    }

    private void UseDonut()
    {
        Debug.Log("Using donut, open fence1");
        audioSource.Play();
        SwitchSceneWithDelay(madOwnerSceneName, 2f);
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

    private void EnableLedgeGrab()
    {
        int ledgeGrabID = 8; // 

        foreach (var state in animal.states)
        {
            if (state.ID.ID == ledgeGrabID) // 
            {
                state.Enable(true); // 
                Debug.Log("LedgeGrab state enabled.");
                return;
            }
        }

        Debug.LogWarning("LedgeGrab state not found in MAnimal's states list.");
    }

    //private void ModifyTrotVerticalSpeed(float newSpeed)
    //{
    //    // 
    //    var groundSpeedSet = animal.speedSets.Find(s => s.name == "Ground");
    //    if (groundSpeedSet == null)
    //    {
    //        Debug.LogError("Ground SpeedSet not found!");
    //        return;
    //    }

    //    // 
    //    if (!groundSpeedSet.Speeds.Exists(s => s.name == "Trot"))
    //    {
    //        Debug.LogError("Trot Speed not found in Ground SpeedSet!");
    //        return;
    //    }
    //    var trotSpeed = groundSpeedSet.Speeds.Find(s => s.name == "Trot");

    //    // 
    //    trotSpeed.Vertical = newSpeed;
    //    Debug.Log($"Trot Vertical Speed updated to {newSpeed}");
    //}

    public void SetTagToScannableUnderParent(string parentName, string childName)
    {
        // Find the parent object by name
        GameObject parentObject = GameObject.Find(parentName);

        if (parentObject != null)
        {
            // Find the child object under the parent
            Transform childTransform = parentObject.transform.Find(childName);

            if (childTransform != null)
            {
                // Set the tag of the child object to "Scannable"
                childTransform.gameObject.tag = "Scannable";
                Debug.Log($"Tag of '{childName}' under '{parentName}' has been set to 'Scannable'.");
            }
            else
            {
                Debug.LogWarning($"Child '{childName}' not found under parent '{parentName}'.");
            }
        }
        else
        {
            Debug.LogError($"Parent object '{parentName}' not found in the scene.");
        }
    }


}
