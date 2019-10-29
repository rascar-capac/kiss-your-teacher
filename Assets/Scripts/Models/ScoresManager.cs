using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoresManager
{
    public static List<Score> scores = new List<Score>();

    public static void AddScore(Score newScore)
    {
        foreach (Score score in scores)
        {
            if (newScore.isGreaterThan(score))
            {
                scores.Insert(scores.IndexOf(score), newScore);
            }
            scores.Add(score);
        }
    }
}
