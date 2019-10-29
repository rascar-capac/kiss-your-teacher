using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameOverDisplayer : MonoBehaviour
{
    [SerializeField] private Text gameOverText;
    [SerializeField] private Button validate;
    [SerializeField] private InputField playerName;


    private void Start()
    {
        validate.onClick.AddListener(ValidateScore);
        playerName.text = "";
    }

    private void ValidateScore()
    {
        if (playerName.text != "")
        {
            ScoresManager.AddScore(new Score(playerName.text, GetComponent<PlayerController>().EggsCount));

        }
    }


}
