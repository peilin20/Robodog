using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scannable : MonoBehaviour
{
    
    public string namePart1; //
    public Color namePart1Color;
    public string namePart2; //
    public Color namePart2Color;
    public Sprite icon;
    private bool isScanned = false; // 

    public string GetFormattedName()
    {
        //transparency = 100
        namePart1Color.a = 1f; // 
        namePart2Color.a = 1f;
        // 
        string part1Formatted = string.IsNullOrEmpty(namePart1)
            ? ""
            : $"<color=#{ColorUtility.ToHtmlStringRGBA(namePart1Color)}>{namePart1}</color>";

        // 
        if (string.IsNullOrEmpty(namePart2))
        {
            return part1Formatted;
        }

        // 
        string part2Formatted = $"<color=#{ColorUtility.ToHtmlStringRGBA(namePart2Color)}>{namePart2}</color>";

        // 
        return $"{part1Formatted}{part2Formatted}";
    }

    // 
    public void OnScanned()
    {
        if (isScanned) return;

        isScanned = true;
        Debug.Log($"{GetFormattedName()} has been scanned!");

        // 
        UIManager.Instance.AddScannedCard(GetFormattedName(), icon);
        Destroy(gameObject);
    }
}


