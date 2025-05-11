using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public float moveSpeed = 5f;         // �ƶ��ٶ�
    public float jumpForce = 5f;        // ��Ծ����
    public float gravity = -9.8f;       // �Զ�������
    public CharacterController controller; // ��ɫ���������
    public bool isGrounded;            // �Ƿ��ڵ�����

    private Vector3 velocity;           // ��ǰ�ٶ�
    public Transform groundCheck;       // �������
    public float groundDistance = 0.4f; // �����ⷶΧ
    public LayerMask groundMask;        // ����㼶

    void Start()
    {
        if (controller == null)
        {
            controller = GetComponent<CharacterController>();
        }
    }

    void Update()
    {
        // ����Ƿ�Ӵ�����
        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        // ����ڵ��棬������ֱ�����ٶ�
        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        // ��ȡ����
        float horizontal = Input.GetAxis("Horizontal"); // A��D
        float vertical = Input.GetAxis("Vertical");     // W��S

        // �����ƶ�����
        Vector3 move = transform.right * horizontal + transform.forward * vertical;

        // �ƶ���ɫ
        controller.Move(move * moveSpeed * Time.deltaTime);

        // ��Ծ
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpForce * -2f * gravity);
        }

        // Ӧ������
        velocity.y += gravity * Time.deltaTime;

        // �ƶ���ɫ����ֱ����
        controller.Move(velocity * Time.deltaTime);
    }
}
