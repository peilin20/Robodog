using UnityEngine;
using System.Collections.Generic;
using cakeslice;

public class Scanning : MonoBehaviour
{
   
    public List<GameObject> objectsInRange = new List<GameObject>();
    private Outline outline;

    

    public void OnScanButtonClick()
    {
        if (objectsInRange.Count > 0)
        {
            
            foreach (GameObject obj in objectsInRange)
            {
                if (obj == null) continue;
                if (obj.CompareTag("Scannable"))
                {
                    Scannable scannable = obj.GetComponent<Scannable>();
                    
                        scannable?.OnScanned();
                    
                }

                else if (obj.CompareTag("Outcome"))
                {
                    CollectItem collectitem = obj.GetComponent<CollectItem>();
                     collectitem?.OnScannedCollect();
                    
                
                }
                
            }

            objectsInRange.Clear();

        }
    }

    void OnTriggerEnter(Collider other)
    {
        //
        if (other.CompareTag("Scannable")) // 
        {
            objectsInRange.Add(other.gameObject);
 
                foreach (Transform child in other.gameObject.transform)
                {
                    outline = child.GetComponent<Outline>();
                    outline.eraseRenderer = false;
                if (outline != null)
                    {
                        break; // 
                    }
                }

                if (outline == null)
                {
                    Debug.LogError("Outline script not found in any child object!");
                } 
        }

        if (other.CompareTag("Outcome")) // 
        {
            objectsInRange.Add(other.gameObject);

       
                outline = other.GetComponent<Outline>();
                outline.eraseRenderer = false;
               

            if (outline == null)
            {
                Debug.LogError("Outline script not found in object!");
            }
        }
         
    }

    void OnTriggerExit(Collider other)
    {
        // 
        if (other.CompareTag("Scannable")) // 
        {
            objectsInRange.Remove(other.gameObject);
            foreach (Transform child in other.gameObject.transform)
            {
                outline = child.GetComponent<Outline>();
                outline.eraseRenderer = true;
                if (outline != null)
                {
                    break; // 
                }
            }

            if (outline == null)
            {
                Debug.LogError("Outline script not found in any child object!");
            }
        }

        if (other.CompareTag("Outcome")) // 
        {
            objectsInRange.Add(other.gameObject);


            outline = other.GetComponent<Outline>();
            outline.eraseRenderer = true;


            if (outline == null)
            {
                Debug.LogError("Outline script not found in object!");
            }
        }
    }

    // 
    
}
