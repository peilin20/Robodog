using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;


public class UIDragHandler : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    
    private Transform parentAfterDrag;
    private RectTransform scannedCardDragRectTransform;
    private RectTransform outcomeCardDragRectTransform;
    private RectTransform inputAreaRectTransform;
    public float boundaryPadding = 3f;
    public Vector3 spawnPoint = new Vector3(0f,0f,0f);

    public Sprite overlappingSprite; //
    public Sprite overlappedSprite; // 
    public Sprite draggingSprite; // 
    private Sprite defaultSprite; //
    private Image windowImage; //
    private bool isOverlapping = false;
    private GameObject linkedGameObject;
    private GameObject tohideGameObject;

    private void Start()
    {
        windowImage = GetComponent<Image>();
        if (windowImage != null)
        {
            defaultSprite = windowImage.sprite;
        }
        else
        {
            Debug.LogError("Image component not found on the window.");
        }
    }

    public void InitializeScannedCardArea(RectTransform panel)
    {
        scannedCardDragRectTransform = panel;
    }

    public void InitializeOutcomeCardArea(RectTransform panel)
    {
        outcomeCardDragRectTransform = panel;
    }

    public void InitializeInputArea(RectTransform panel)
    {
        inputAreaRectTransform = panel;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        Debug.Log("BeginDrag");
        Debug.Log("Curr:" + transform);
        parentAfterDrag = transform.parent;
        transform.SetParent(transform.root);
        transform.SetAsLastSibling();
        SetDraggingSprite();
    }

    public void OnDrag(PointerEventData eventData)
    {
        RectTransform targetRectTransform = null;

        // 
        if (CompareTag("OutcomeCard"))
        {
            targetRectTransform = outcomeCardDragRectTransform;
        }
        else if (CompareTag("ScannableCard"))
        {
            targetRectTransform = scannedCardDragRectTransform;
            PerformOverlapCheck();
        }

        if (targetRectTransform == null)
        {
            Debug.LogError($"Target RectTransform is null for tag {tag}. Did you forget to initialize?");
            return;
        }

        // 
        DragWithinBounds(targetRectTransform);
        if (!isOverlapping)
        {
            SetDraggingSprite();
        }
    }

    private void DragWithinBounds(RectTransform targetRectTransform)
    {
        // 
        Vector2 mousePosition = Input.mousePosition;
        Vector2 localMousePosition = targetRectTransform.InverseTransformPoint(mousePosition);

        // 
        Rect panelRect = targetRectTransform.rect;

        // 
        RectTransform cardRect = GetComponent<RectTransform>();
        Vector2 cardSize = cardRect.sizeDelta * cardRect.lossyScale;

        // 
        localMousePosition.x = Mathf.Clamp(
            localMousePosition.x,
            panelRect.xMin + cardSize.x / 2 + boundaryPadding, // 
            panelRect.xMax - cardSize.x / 2 - boundaryPadding  // 
        );
        localMousePosition.y = Mathf.Clamp(
            localMousePosition.y,
            panelRect.yMin + cardSize.y / 2 + boundaryPadding, // 
            panelRect.yMax - cardSize.y / 2 - boundaryPadding  // 
        );

        // 
        transform.position = targetRectTransform.TransformPoint(localMousePosition);
       
        //Debug.Log($"Dragging within {targetRectTransform.name}: Local({localMousePosition}) World({transform.position})");
    }



    public void OnEndDrag(PointerEventData eventData)
    {
        //transform.position = parentAfterDrag.position;
        Debug.Log("endDrag");
        Debug.Log("mousepos:" + Input.mousePosition);
        transform.SetParent(parentAfterDrag);
        PerformOverlapCheck(finalize: true);
        ResetSprite();
    }

    private Rect GetWorldRect(RectTransform rectTransform)
    {
        Vector3[] corners = new Vector3[4];
        rectTransform.GetWorldCorners(corners);

        // Bottom-left corner is corners[0], top-right corner is corners[2]
        return new Rect(
            corners[0].x,
            corners[0].y,
            corners[2].x - corners[0].x, // 
            corners[2].y - corners[0].y  //
        );
    }

    private void PerformOverlapCheck(bool finalize = false)
    {
        RectTransform thisRect = GetComponent<RectTransform>();
        UIDragHandler[] allCards = FindObjectsOfType<UIDragHandler>();
        isOverlapping = false;

        if (CompareTag("OutcomeCard"))
        {
            Rect thisWorldRect = GetWorldRect(thisRect);
            Rect inputWorldRect = GetWorldRect(inputAreaRectTransform);
            if (thisWorldRect.Overlaps(inputWorldRect))
            {
                Debug.Log("Overlap detected with input area!");
                HandleFinalOverlapOutcome();
            }
            else
            {
                Debug.Log("No overlap detected with input area.");
            }
        }

        if (CompareTag("ScannableCard"))
        {
            foreach (var otherCard in allCards)
            {
                if (otherCard == this) continue; // 

                RectTransform otherRect = otherCard.GetComponent<RectTransform>();
                Rect thisWorldRect = GetWorldRect(thisRect);
                Rect otherWorldRect = GetWorldRect(otherRect);


                if (thisWorldRect.Overlaps(otherWorldRect))
                {
                    isOverlapping = true;

                    // 
                    if (finalize)
                    {
                        Debug.Log($"Final overlap detected with {otherCard.name}");
                        HandleFinalOverlapCombine(otherCard);

                    }
                    else
                    {
                        // 
                        SetOverlappingSprite();
                        otherCard.SetOverlappedSprite();
                    }
                }
                else
                {
                    // 
                    otherCard.ResetSprite();
                }
            }

            if (!isOverlapping)
            {
                ResetSprite(); // 
            }
        }
    }

    private void HandleFinalOverlapCombine(UIDragHandler otherCard)
    {
        // 
        string thisCardText = transform.Find("CardName")?.GetComponent<TMP_Text>().text;
        string otherCardText = otherCard.transform.Find("CardName")?.GetComponent<TMP_Text>().text;

        if (thisCardText == null || otherCardText == null) return; // 

        string strippedText1 = Regex.Replace(thisCardText, "<.*?>", string.Empty);
        string strippedText2 = Regex.Replace(otherCardText, "<.*?>", string.Empty);

        // Battery Puzzle
        if ((strippedText1.Equals("Battery") && strippedText2.Equals("Bat")) ||
            (strippedText1.Equals("Bat") && strippedText2.Equals("Battery")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Battery");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Battery not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }

        // Patch Puzzle
        if ((strippedText1.Equals("Pan") && strippedText2.Equals("Match")) ||
            (strippedText1.Equals("Match") && strippedText2.Equals("Pan")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Patch");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Patch not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }

        // Hole Puzzle
        if ((strippedText1.Equals("Hook") && strippedText2.Equals("Bottle")) ||
            (strippedText1.Equals("Bottle") && strippedText2.Equals("Hook")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Hole");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Hole not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }
        // Basketball Puzzle
        if ((strippedText1.Equals("Basket") && strippedText2.Equals("Ball")) ||
            (strippedText1.Equals("Ball") && strippedText2.Equals("Basket")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Basketball");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Basketball not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }

        // Donut Puzzle
        if ((strippedText1.Equals("Document") && strippedText2.Equals("Nut")) ||
            (strippedText1.Equals("Nut") && strippedText2.Equals("Document")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Donut");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Donut not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }
        // Sneaker Puzzle
        if ((strippedText1.Equals("Speaker") && strippedText2.Equals("Snack")) ||
            (strippedText1.Equals("Snack") && strippedText2.Equals("Speaker")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Sneaker");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Sneaker not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }
        // Footprint Puzzle
        if ((strippedText1.Equals("Football") && strippedText2.Equals("Print")) ||
            (strippedText1.Equals("Print") && strippedText2.Equals("Football")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Footprint");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Footprint not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }
        // Footprint Puzzle
        if ((strippedText1.Equals("Raindoll") && strippedText2.Equals("Bow")) ||
            (strippedText1.Equals("Bow") && strippedText2.Equals("Raindoll")))
        {
            Debug.Log($"Final overlap match: {thisCardText} and {otherCardText}");

            RectTransform thisCardRect = GetComponent<RectTransform>();
            RectTransform otherCardRect = otherCard.GetComponent<RectTransform>();
            Vector2 middlePoint = (thisCardRect.anchoredPosition + otherCardRect.anchoredPosition) / 2;

            // 
            GameObject outcomeCardPrefab = Resources.Load<GameObject>("OutcomeCards/Rainbow");
            if (outcomeCardPrefab != null)
            {
                UIManager.Instance.AddOutcomeCard(outcomeCardPrefab, middlePoint);
            }
            else
            {
                Debug.LogError("Rainbow not found in Resources.");
            }

            // 
            Destroy(gameObject);
            Destroy(otherCard.gameObject);
        }
    }

    private void HandleFinalOverlapOutcome()
    {
            Debug.Log($"Card {gameObject.name} entered the target panel.");
            string cardBaseName = gameObject.name.Replace("(Clone)", "").Trim();
            string linkedGameObjectName = $"{cardBaseName}_obj";
            string tohideGameObjectName = $"{cardBaseName}_obj_tohide";
            string parentObjectName = "OutcomeObjects";
            GameObject parentObject = GameObject.Find(parentObjectName);

        if (parentObject != null)
        {
            Transform linkedchildTransform = parentObject.transform.Find(linkedGameObjectName);
            Transform tohidechildTransform = parentObject.transform.Find(tohideGameObjectName);
            if (linkedchildTransform != null)
            {
                linkedGameObject = linkedchildTransform.gameObject;
                linkedGameObject.SetActive(true); // 
                Debug.Log($"Activated {linkedGameObject.name}");
            }
            else
            {
                Debug.LogError($"No GameObject named {linkedGameObjectName} found under {parentObjectName}.");
            }
            if (tohidechildTransform != null)
            {
                tohideGameObject = tohidechildTransform.gameObject;
                tohideGameObject.SetActive(false); // 
                Debug.Log($"Hide {tohideGameObject.name}");
            }
            else
            {
                Debug.Log($"No GameObject named {tohideGameObjectName} found under {parentObjectName}.");
            }
        }
            Destroy(gameObject);
        
    }

   

    public void SetOverlappingSprite()
    {
        if (windowImage != null && overlappingSprite != null)
        {
            windowImage.sprite = overlappingSprite;
        }
    }

    public void SetOverlappedSprite()
    {
        if (windowImage != null && overlappedSprite != null)
        {
            windowImage.sprite = overlappedSprite;
        }
    }

    public void SetDraggingSprite()
    {
        if (windowImage != null && draggingSprite != null)
        {
            windowImage.sprite = draggingSprite;
        }
    }

    public void ResetSprite()
    {
        if (windowImage != null)
        {
            windowImage.sprite = defaultSprite;
        }
    }


}
