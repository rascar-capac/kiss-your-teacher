using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IdleAction : AbstractAction
{

    private float duration;
    private float timer;

    public IdleAction(EActionType actionType, ChickenBehaviour context) : base(actionType, context)
    {
        duration = Random.Range(GetContext().GetMinIdleDuration(), GetContext().GetMaxIdleDuration());
        timer = 0;
    }

    public override string ToString()
    {
        return base.ToString() + " of " + duration + "s";
    }

    public override void Update()
    {
        timer += Time.deltaTime;
        SetDone(timer >= duration);
    }

    public override void Execute()
    {
    }
}
