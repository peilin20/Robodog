using System.Collections;
using UnityEngine;
using Cinemachine;
using UnityEngine.Animations;

public class CameraSwitch : MonoBehaviour
{
    public CinemachineVirtualCamera virtualCamera; // 
    public PositionConstraint positionConstraint; // 
    public float rotationDuration = 3f; // 
    public float positionRestDuration = 3f; // 

    public Vector3 enterRotation; // 
    public Vector3 exitRotation; // 
    public Vector3 enterPositionRest; // 
    public Vector3 exitPositionRest; // 

    private bool isSwitching = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") && !isSwitching)
        {
            StartCoroutine(SmoothSwitch(enterRotation, enterPositionRest));
            Debug.Log($"Entered trigger, switching to Enter State.");
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player") && !isSwitching)
        {
           
            StartCoroutine(SmoothSwitch(exitRotation, exitPositionRest));
        }
    }

    private IEnumerator SmoothSwitch(Vector3 targetRotation, Vector3 targetPositionRest)
    {
        isSwitching = true;

        // 
        Quaternion initialRotation = virtualCamera.transform.rotation;
        Quaternion targetQuaternion = Quaternion.Euler(targetRotation);

        Vector3 initialPositionRest = positionConstraint.translationAtRest;

        float elapsedTime = 0f;

        // 
        float totalDuration = Mathf.Max(rotationDuration, positionRestDuration);

        while (elapsedTime < totalDuration)
        {
            elapsedTime += Time.deltaTime;

            // 
            float rotationT = Mathf.Clamp01(elapsedTime / rotationDuration);
            float positionT = Mathf.Clamp01(elapsedTime / positionRestDuration);

            // 
            virtualCamera.transform.rotation = Quaternion.Lerp(initialRotation, targetQuaternion, rotationT);

            // 
            positionConstraint.translationAtRest = Vector3.Lerp(initialPositionRest, targetPositionRest, positionT);

            yield return null;
        }

        //
        virtualCamera.transform.rotation = targetQuaternion;
        positionConstraint.translationAtRest = targetPositionRest;

        isSwitching = false;
    }
}
