using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public static PauseMenu Instance;

    public GameObject menuUI; // 拖入菜单Canvas
    private bool isPaused = false;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
            return;
        }
    }

    // Only called by the Pause button
    public void OpenMenu()
    {
        if (isPaused) return;
        menuUI.SetActive(true);
        Time.timeScale = 1f;
        isPaused = true;
    }

    public void Resume()
    {
        menuUI.SetActive(false);
        Time.timeScale = 1f;
        isPaused = false;
    }

    public void RestartLevel()
    {
        menuUI.SetActive(false);
        Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        isPaused = false;
    }

    public void RestartGame()
    {
        menuUI.SetActive(false);
        Time.timeScale = 1f;
        SceneManager.LoadScene("TutorialFinal");
        isPaused = false;
    }

    public void QuitGame()
    {

        Application.Quit();
        Debug.Log("Quit Game");
    }
}
