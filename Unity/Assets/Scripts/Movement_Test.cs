using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public float moveSpeed = 5f;         // 移动速度
    public float jumpForce = 5f;        // 跳跃力度
    public float gravity = -9.8f;       // 自定义重力
    public CharacterController controller; // 角色控制器组件
    public bool isGrounded;            // 是否在地面上

    private Vector3 velocity;           // 当前速度
    public Transform groundCheck;       // 地面检测点
    public float groundDistance = 0.4f; // 地面检测范围
    public LayerMask groundMask;        // 地面层级

    void Start()
    {
        if (controller == null)
        {
            controller = GetComponent<CharacterController>();
        }
    }

    void Update()
    {
        // 检测是否接触地面
        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        // 如果在地面，重置竖直方向速度
        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        // 获取输入
        float horizontal = Input.GetAxis("Horizontal"); // A和D
        float vertical = Input.GetAxis("Vertical");     // W和S

        // 计算移动方向
        Vector3 move = transform.right * horizontal + transform.forward * vertical;

        // 移动角色
        controller.Move(move * moveSpeed * Time.deltaTime);

        // 跳跃
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpForce * -2f * gravity);
        }

        // 应用重力
        velocity.y += gravity * Time.deltaTime;

        // 移动角色（竖直方向）
        controller.Move(velocity * Time.deltaTime);
    }
}
