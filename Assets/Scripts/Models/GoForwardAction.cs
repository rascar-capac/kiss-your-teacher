using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoForwardAction : AbstractAction
{
    private Vector3 destination;
    private float speed;

    public GoForwardAction(EActionType actionType, ChickenBehaviour context, float distance, float speed) : base(actionType, context)
    {
        destination = GetContext().transform.position + GetContext().transform.forward * distance;
        this.speed = speed;
    }

    public override string ToString()
    {
        return base.ToString() + " of speed " + speed + " and destination " + destination;
    }

    public override void Update()
    {
        SetDone((GetContext().transform.position - destination).magnitude <= 0.1);
    }

    public override void Execute()
    {
        GetContext().GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeRotationY | RigidbodyConstraints.FreezeRotationZ;

        GetContext().transform.position += GetContext().transform.forward * speed * Time.deltaTime;
    }
}
