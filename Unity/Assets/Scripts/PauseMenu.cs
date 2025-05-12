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
            SceneManager.sceneLoaded += OnSceneLoaded;

            // 自动绑定
            if (menuUI == null)
            {
                menuUI = transform.Find("Canvas/Canvas(PauseMenu)")?.gameObject;
                if (menuUI == null)
                    Debug.LogWarning("menuUI not found! PauseMenu may not work.");
            }
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        isPaused = false;
        Time.timeScale = 1f;

        if (menuUI != null)
        {
            menuUI.SetActive(false);
        }
        else
        {
            Debug.LogWarning("menuUI is null after scene load!");
        }
    }

    // Only called by the Pause button
    public void OpenMenu()
    {
        Debug.LogWarning("isPaused="+isPaused);
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
        SceneManager.LoadScene("StartMenu");
        isPaused = false;
    }

    public void QuitGame()
    {

        Application.Quit();
        Debug.Log("Quit Game");
    }
}
