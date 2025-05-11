using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using cakeslice;
using TMPro;

public class CollectItem : MonoBehaviour
{
    //public List<GameObject> objectsInRange = new List<GameObject>();
    private Outline outline;
    private Renderer objectRenderer;
    public TextMeshProUGUI TaskText;
    public string batteryDestroyedMessage = "Battery has been collected!";
    public string NewTask = " <shake>I need to fix my injured leg</shake> ";
    public float duration = 2f;
    public UseObject useObject;
    private Coroutine activeCoroutine;
    private List<GameObject> objectsInRange = new List<GameObject>();
    private bool isScanned = false;
    private Material[] allMaterials;
    

    private void Start()
    {
        Renderer[] renderers = GetComponentsInChildren<Renderer>();

        List<Material> materialsList = new List<Material>();
        foreach (Renderer renderer in renderers)
        {
            foreach (Material mat in renderer.materials)
            {
                materialsList.Add(mat);
            }
        }
        allMaterials = materialsList.ToArray();

        

        useObject = FindObjectOfType<UseObject>();
        if (useObject == null)
        {
            Debug.LogError("UseObject script not found in the scene!");
        }

    }

    public void OnScannedCollect()
    {
        if (isScanned) return;

        isScanned = true;
        UseCollectedObject(gameObject.name);
        Debug.Log($"{gameObject.name} has been scanned!");
        // Display the first message
        outline = gameObject.GetComponent<Outline>();
        outline.eraseRenderer = true;
        TaskText.text = batteryDestroyedMessage;
        Debug.Log("Task message updated: " + batteryDestroyedMessage);
        if (activeCoroutine == null)
        {
            activeCoroutine = StartCoroutine(DestroyAfterUpdate());
        }

    }

    private IEnumerator DestroyAfterUpdate()
    {
        
        yield return StartCoroutine(UpdateText());
        
        Destroy(gameObject);
    }

    public void UseCollectedObject(string itemName)
    {
        if (useObject != null)
        {
            useObject.Use(itemName);
        }
    }

    private IEnumerator UpdateText()
    {

        float elapsedTime = 0f;

        Dictionary<Material, Color> initialColors = new Dictionary<Material, Color>();
        foreach (Material mat in allMaterials)
        {
            if (mat != null)
            {
                initialColors[mat] = mat.color;

                // 
                mat.SetFloat("_Mode", 2); // 
                mat.renderQueue = 3000;   // 
            }
        }


        while (elapsedTime < duration)
        {
            float alpha = Mathf.Lerp(1f, 0f, elapsedTime / duration);

            foreach (Material mat in allMaterials)
            {
                if (mat != null)
                {
                    Color initialColor = initialColors[mat];
                    mat.color = new Color(initialColor.r, initialColor.g, initialColor.b, alpha);
                }
            }
            elapsedTime += Time.deltaTime;
            yield return null;

        }

        foreach (Material mat in allMaterials)
        {
            if (mat != null)
            {
                Color initialColor = initialColors[mat];
                mat.color = new Color(initialColor.r, initialColor.g, initialColor.b, 0f);
            }
        }


        if (TaskText != null)
        {
            
            // Wait for 2 seconds
            yield return new WaitForSeconds(duration);

            // Update to the new task message
            TaskText.text = NewTask;
            Debug.Log("Task message updated: " + NewTask);
        }
        else
        {
            Debug.LogWarning("TaskText is not assigned in the Inspector!");
        }

        activeCoroutine = null; // Allow new coroutines to start
    }

   
}
