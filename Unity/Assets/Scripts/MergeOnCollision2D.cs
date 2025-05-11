using UnityEngine;

public class MergeOnCollision : MonoBehaviour
{
    public GameObject newSquarePrefab; // Prefab for the new square to be created
    
    private void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log($"Collision with {collision.gameObject.name}");
        // Check if the other object has the same tag as this object
        if (collision.gameObject.tag == "Word")
        {
            Debug.Log($"Collision with {collision.gameObject.name}");
            // Calculate the average position of the two colliding squares
            Vector3 newPosition = (transform.position + collision.transform.position) / 2;

            // Instantiate the new square
            Instantiate(newSquarePrefab, newPosition, Quaternion.identity);

            // Destroy both original squares
            Destroy(collision.gameObject); // Other square
            Destroy(gameObject); // This square
        }
    }
}
