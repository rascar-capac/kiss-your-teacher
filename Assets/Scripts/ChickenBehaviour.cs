using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChickenBehaviour : MonoBehaviour
{
    [SerializeField] [Range(0.1f, 10f)] private float minIdleDuration = 0.1f;
    [SerializeField] [Range(0.1f, 10f)] private float maxIdleDuration = 5f;
    [SerializeField] [Range(0.1f, 10f)] private float minMoveSpeed = 0.1f;
    [SerializeField] [Range(0.1f, 10f)] private float maxMoveSpeed = 5f;
    [SerializeField] [Range(1f, 20f)] private float minDistance = 5f;
    [SerializeField] [Range(1f, 30f)] private float maxDistance = 20f;
    [SerializeField] [Range(1f, 60f)] private float minEggFrequency = 1;
    [SerializeField] [Range(1f, 60f)] private float maxEggFrequency = 10;
    [SerializeField] public EggBehaviour egg = null;
    PlayerController olivier = null;
    [SerializeField] public Food food = null;


    protected List<AbstractAction> actionsQueue;
    protected AbstractAction currentAction;
    protected GameObject gameManager = null;
    private float eggTimer;

    /* UNITY METHODS */
    private void Awake()
    {
        olivier = FindObjectOfType<PlayerController>();
        actionsQueue = new List<AbstractAction>();
        currentAction = new IdleAction(EActionType.Idle, this);
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

        if (eggTimer >= Random.Range(minEggFrequency, maxEggFrequency))
        {
            EggBehaviour newEgg = Instantiate(egg, new Vector3(transform.position.x, transform.position.y, transform.position.z - transform.forward.z * -1), Quaternion.identity);
            newEgg.transform.GetChild(0).GetComponent<MeshRenderer>().material.color = transform.GetChild(0).GetComponent<MeshRenderer>().material.color;
            eggTimer = 0;
        }
        
        eggTimer += Time.deltaTime;
    }

    void OnCollisionStay(Collision collision)
    {      
        if(collision.collider.GetComponent<PlayerController>() != null)
        {

            if (olivier.GetComponent<PlayerController>().IsAttacking)
            {
                Instantiate(food, transform.position, Quaternion.identity);
                Destroy(this.gameObject);
            }
        }
    }

    /* GETTERS AND SETTERS */
    public float GetMinIdleDuration()
    {
        return minIdleDuration;
    }

    public float GetMaxIdleDuration()
    {
        return maxIdleDuration;
    }

    public float GetMinMoveSpeed()
    {
        return minMoveSpeed;
    }

    public float GetMaxMoveSpeed()
    {
        return maxMoveSpeed;
    }

    public List<AbstractAction> GetActionsQueue()
    {
        return actionsQueue;
    }

    public AbstractAction GetCurrentAction()
    {
        return currentAction;
    }

    public void SetGameManager(GameObject gameManager)
    {
        this.gameManager = gameManager;
    }

    /* TOOLS */
    protected AbstractAction PickAction()
    {
        EActionType actionType = PickActionType();
        switch (actionType)
        {
            case EActionType.GoForward:
                float distance = Random.Range(minDistance, maxDistance);
                float speed = Random.Range(minMoveSpeed, maxMoveSpeed);
                return new GoForwardAction(actionType, this, distance, speed);
            case EActionType.Turn:
                float angle = Random.Range(-180f, 180f);
                speed = Random.Range(minMoveSpeed, maxMoveSpeed);
                return new TurnAction(actionType, this, angle, speed);
            case EActionType.Idle:
                return new IdleAction(actionType, this);
            default:
                return null;
        }
    }

    protected EActionType PickActionType()
    {
        System.Array actionTypes = System.Enum.GetNames(typeof(EActionType));
        EActionType actionType = (EActionType)Random.Range(0, actionTypes.Length);
        if (actionType != currentAction.GetActionType())
        {
            return actionType;
        }
        else
        {
            return PickActionType();
        }
    }
}
