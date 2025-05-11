using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorController : MonoBehaviour
{
    public Transform player;
    public float activationDistance = 5f;
    public Animator doorAnimator;
    public GameObject key;
    public float keyPickupDistance = 2f;

    private bool isDoorOpen = false;
    private bool hasKey = false;

    void Update()
    {
        CheckKeyPickup();
        CheckDoorInteraction();
    }
    void CheckKeyPickup()
    {
        if (hasKey) return;

        if (Vector3.Distance(player.position, key.transform.position) <= keyPickupDistance)
        {
            Debug.Log("靠近钥匙，按 E 键捡起");

            if (Input.GetKeyDown(KeyCode.E))
            {
                hasKey = true;
                Destroy(key);
                Debug.Log("钥匙已捡起！");
            }
        }
    }

    void CheckDoorInteraction()
    {
        float distance = Vector3.Distance(player.position, transform.position);

        if (distance <= activationDistance)
        {
            if (!hasKey)
            {
                Debug.Log("需要钥匙才能开门！");
                return;
            }
            else
            {
                Debug.Log("按 E 键开门");

                if (Input.GetKeyDown(KeyCode.E))
                {
                    ToggleDoor();
                }
            }

        }
        else
        {
            Debug.Log("距离太远，无法开门");
        }
    }
    void ToggleDoor()
    {
        if (isDoorOpen)
        {
            doorAnimator.SetTrigger("CloseDoor");
            isDoorOpen = false;
        }
        else
        {
            doorAnimator.SetTrigger("OpenDoor");
            isDoorOpen = true;
        }
    }
}