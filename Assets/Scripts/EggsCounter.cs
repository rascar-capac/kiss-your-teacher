using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EggsCounter : MonoBehaviour
{
    [SerializeField] private Text eggsCounter = null;
    [SerializeField] private PlayerController player = null;

    private void Update()
    {
        Debug.Log(player.EggsCount);
        eggsCounter.text = (player.EggsCount).ToString();
    }
}
