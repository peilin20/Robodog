using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections.Generic;
using UnityEngine.EventSystems;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;
    public GameObject cardPrefab; // 
    public RectTransform brainPanelDrag; // 
    public RectTransform brainPanelGenerate;
    public RectTransform outcomePanelDrag;
    public RectTransform inputPanel;
    //public Vector2 cardSpacing = new Vector2(10, 10); // 
    //public Vector2 initialCardOffset = new Vector2(-150, 100);

    private int cardCount = 0; // 

    private void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);


    }


    public void AddScannedCard(string Name, Sprite cardIcon)
    {
        // Instantiate the card under brainPanelDrag
        GameObject newCard = Instantiate(cardPrefab, brainPanelDrag);

        // Initialize drag functionality
        UIDragHandler dragHandler = newCard.GetComponent<UIDragHandler>();
        if (dragHandler != null)
        {
            dragHandler.InitializeScannedCardArea(brainPanelDrag);
            dragHandler.InitializeOutcomeCardArea(outcomePanelDrag);
            dragHandler.InitializeInputArea(inputPanel);
        }
        else
        {
            Debug.LogError("UIDragHandler script is missing on the card prefab.");
        }

        // Generate a random position within brainPanelGenerate
        RectTransform generateRect = brainPanelGenerate.GetComponent<RectTransform>();
        RectTransform dragRect = brainPanelDrag.GetComponent<RectTransform>();

        if (generateRect != null && dragRect != null)
        {
            // Get the actual bounds of brainPanelGenerate
            Vector3[] worldCorners = new Vector3[4];
            generateRect.GetWorldCorners(worldCorners);

            // Generate random position within the bounds
            float randomX = Random.Range(worldCorners[0].x, worldCorners[2].x); // Left to Right
            float randomY = Random.Range(worldCorners[0].y, worldCorners[1].y); // Bottom to Top
            Vector3 randomWorldPosition = new Vector3(randomX, randomY, 0);

            // Convert the world position to local position in brainPanelDrag
            Vector3 localPositionInDragPanel = dragRect.InverseTransformPoint(randomWorldPosition);

            // Assign the calculated position to the new card
            newCard.GetComponent<RectTransform>().localPosition = localPositionInDragPanel;

            Debug.Log($"Generated card at local position: {localPositionInDragPanel} in dragPanel");
        }
        else
        {
            Debug.LogError("RectTransforms for brainPanelGenerate or brainPanelDrag not found!");
        }

        // Set the card name
        TMP_Text cardText = newCard.transform.Find("CardName")?.GetComponent<TMP_Text>();
        if (cardText != null)
        {
            cardText.text = Name;
            Debug.Log($"Card text set to: {cardText.text}");
        }

        // Set the card icon
        Image cardImage = newCard.transform.Find("CardIcon")?.GetComponent<Image>();
        if (cardImage != null && cardIcon != null)
        {
            cardImage.sprite = cardIcon;
        }

        cardCount++;
    }

    public void AddOutcomeCard(GameObject outcomeCardPrefab, Vector2 middlePoint)
    {
        if (outcomeCardPrefab == null)
        {
            Debug.LogError("Outcome card prefab is null. Cannot instantiate.");
            return;
        }

        Vector3 worldMiddlePoint = brainPanelDrag.TransformPoint(middlePoint); //
        Vector2 localMiddlePoint = outcomePanelDrag.InverseTransformPoint(worldMiddlePoint); // 

        // 
        GameObject newCard = Instantiate(outcomeCardPrefab, outcomePanelDrag);

        RectTransform newCardRect = newCard.GetComponent<RectTransform>();
        UIDragHandler dragHandler = newCard.GetComponent<UIDragHandler>();
        if (dragHandler != null)
        {
            dragHandler.InitializeScannedCardArea(brainPanelDrag);
            dragHandler.InitializeOutcomeCardArea(outcomePanelDrag);
            dragHandler.InitializeInputArea(inputPanel);
        }
        else
        {
            Debug.LogError("UIDragHandler script is missing on the card prefab.");
        }

        if (newCardRect != null)
        {
           
            // 
            newCardRect.anchoredPosition = localMiddlePoint;
            //newCardRect.localScale = Vector3.one; // 

            Debug.Log($"Outcome card generated at {localMiddlePoint}");
        }
        else
        {
            Debug.LogError("Generated card does not have a RectTransform.");
        }

        // 
        
    }


}
