using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChickBehaviour : ChickenBehaviour
{
    [SerializeField] [Range(1f, 240f)] private float growDuration = 5;
    [SerializeField] private ChickenBehaviour chicken = null;

    private float originalScaleX;

    private void Awake()
    {
        actionsQueue = new List<AbstractAction>();
        currentAction = new IdleAction(EActionType.Idle, this);
        originalScaleX = transform.localScale.x;
    }

    private void Update()
    {
        if (actionsQueue.Count == 0)
        {
            AbstractAction action = PickAction();
            actionsQueue.Add(action);
        }

        currentAction.Execute();
        currentAction.Update();

        if (currentAction.IsDone())
        {
            currentAction = actionsQueue[0];
            actionsQueue.RemoveAt(0);
        }

        float deltaTime = Time.deltaTime;
        transform.localScale += new Vector3(deltaTime, deltaTime, deltaTime) * 2.5f / growDuration;

        if(transform.localScale.x >= originalScaleX * 2.5f)
        {
            ChickenBehaviour newChicken = Instantiate(chicken, transform.position, Quaternion.identity);
            newChicken.transform.GetChild(0).GetComponent<MeshRenderer>().material.color = transform.GetChild(0).GetComponent<MeshRenderer>().material.color;
            Destroy(this.gameObject);
        }
    }
}