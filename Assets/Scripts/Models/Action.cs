using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class AbstractAction
{
    private EActionType actionType;
    private ChickenBehaviour context;
    private bool done;

    public AbstractAction(EActionType actionType, ChickenBehaviour context)
    {
        this.actionType = actionType;
        this.context = context;
        done = false;
    }

    public ChickenBehaviour GetContext()
    {
        return context;
    }

    public EActionType GetActionType()
    {
        return actionType;
    }

    public bool IsDone()
    {
        return done;
    }

    public void SetDone(bool done)
    {
        this.done = done;
    }

    public override string ToString()
    {
        return actionType + " action";
    }

    public abstract void Update();
    public abstract void Execute();
}