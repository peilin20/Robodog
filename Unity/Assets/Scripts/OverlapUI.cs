using UnityEngine;
using UnityEngine.UI;

public class OverlapUI : MonoBehaviour
{
    public Sprite overlappingSprite; // 
    public Sprite overlappedSprite; //
    public Sprite draggingSprite; //
    private Sprite defaultSprite; // 
    private Image buttonImage; // 
    private bool isOverlapping = false; //



    private void Start()
    {
        buttonImage = GetComponent<Image>();
        if (buttonImage != null)
        {
            defaultSprite = buttonImage.sprite;
        }
        else
        {
            Debug.LogError("Image component not found on the card.");
        }
    }

    private void Update()
    {
        OverlapCheck(); // 
    }

    private void OverlapCheck()
    {
        RectTransform thisRect = GetComponent<RectTransform>();

        OverlapUI[] allCards = FindObjectsOfType<OverlapUI>();
        bool overlapDetected = false;

        foreach (var otherCard in allCards)
        {
            if (otherCard == this) continue;

            RectTransform otherRect = otherCard.GetComponent<RectTransform>();

            if (thisRect != null && otherRect != null && RectOverlaps(thisRect, otherRect))
            {
                overlapDetected = true;

                // 
                SetOverlappingSprite();

                // 
                otherCard.SetOverlappedSprite();
            }
            else
            {
                // 
                otherCard.ResetSprite();
            }
        }

        if (!overlapDetected)
        {
            ResetSprite(); // 
        }
    }

    private bool RectOverlaps(RectTransform rect1, RectTransform rect2)
    {
        Rect worldRect1 = GetWorldRect(rect1);
        Rect worldRect2 = GetWorldRect(rect2);
        return worldRect1.Overlaps(worldRect2);
    }

    private Rect GetWorldRect(RectTransform rectTransform)
    {
        Vector3[] corners = new Vector3[4];
        rectTransform.GetWorldCorners(corners);
        return new Rect(
            corners[0].x,
            corners[0].y,
            corners[2].x - corners[0].x,
            corners[2].y - corners[0].y
        );
    }

    public void SetOverlappingSprite()
    {
        if (!isOverlapping && buttonImage != null && overlappingSprite != null)
        {
            buttonImage.sprite = overlappingSprite; // 
            isOverlapping = true;
        }
    }

    public void SetOverlappedSprite()
    {
        if (buttonImage != null && overlappedSprite != null && !isOverlapping)
        {
            buttonImage.sprite = overlappedSprite; // 
        }
    }

    public void ResetSprite()
    {
        if (buttonImage != null)
        {
            buttonImage.sprite = defaultSprite; // 
            isOverlapping = false;
        }
    }
}
