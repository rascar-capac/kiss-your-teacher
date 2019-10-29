using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TurnAction : AbstractAction
{
    private float angle;
    private float speed;
    private float rotationDuration = 0;

    public float Angle { get;  set; }

    public TurnAction(EActionType actionType, ChickenBehaviour context, float angle, float speed) : base(actionType, context)
    {
        this.angle = angle;
        this.speed = speed;
    }

    public override string ToString()
    {
        return base.ToString() + " of speed " + speed + " and angle " + angle;
    }

    public override void Update()
    {
        SetDone(GetContext().transform.rotation == Quaternion.AngleAxis(angle, Vector3.up));
    }

    public override void Execute()
    {
        GetContext().GetComponent<Rigidbody>().constraints = RigidbodyConstraints.None;

        rotationDuration += Time.deltaTime * speed / 10;
        GetContext().transform.rotation = Quaternion.Slerp(GetContext().transform.rotation, Quaternion.AngleAxis(angle, Vector3.up), rotationDuration);
    }
}
