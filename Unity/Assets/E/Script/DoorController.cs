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
            Debug.Log("����Կ�ף��� E ������");

            if (Input.GetKeyDown(KeyCode.E))
            {
                hasKey = true;
                Destroy(key);
                Debug.Log("Կ���Ѽ���");
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
                Debug.Log("��ҪԿ�ײ��ܿ��ţ�");
                return;
            }
            else
            {
                Debug.Log("�� E ������");

                if (Input.GetKeyDown(KeyCode.E))
                {
                    ToggleDoor();
                }
            }

        }
        else
        {
            Debug.Log("����̫Զ���޷�����");
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