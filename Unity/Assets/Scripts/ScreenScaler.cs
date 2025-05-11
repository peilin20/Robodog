using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenScaler: MonoBehaviour
{
    void Start()
    {
        float targetAspect = 1920f / 1080f;
        float currentAspect = (float)Screen.width / Screen.height;

        if (currentAspect > targetAspect)
        {
            // 当前分辨率更宽，添加左右黑边
            float scaleHeight = targetAspect / currentAspect;
            Camera.main.rect = new Rect((1f - scaleHeight) / 2f, 0, scaleHeight, 1);
        }
        else if (currentAspect < targetAspect)
        {
            // 当前分辨率更高，添加上下黑边
            float scaleWidth = currentAspect / targetAspect;
            Camera.main.rect = new Rect(0, (1f - scaleWidth) / 2f, 1, scaleWidth);
        }
    }

}
