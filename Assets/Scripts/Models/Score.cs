using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Score : MonoBehaviour
{
    public string PlayerName { get; set; }
    public int Result { get; set; }

    public Score(string playerName, int result)
    {
        this.PlayerName = playerName;
        this.Result = result;
    }

    public bool isGreaterThan(Score score)
    {
        return this.Result > this.Result;
    }
}
