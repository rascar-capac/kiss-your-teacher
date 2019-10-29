using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChickenSpawner : MonoBehaviour
{
    [SerializeField] private ChickenBehaviour targetToSpawn = null;
    [SerializeField] [Range(1, 20)] private int spawnPointsCount = 3;
    [SerializeField] [Range(1f, 20f)] private float spawnRange = 3;
    [SerializeField] [Range(1, 20)] private int spawnCount = 3;

    private int counter;
    private List<ChickenBehaviour> chickens;
    private List<Vector3> spawnPoints;

    /* UNITY METHODS */
    private void Awake()
    {
        counter = 0;
        chickens = new List<ChickenBehaviour>();
        spawnPoints = new List<Vector3>();
    }

    private void Start()
    {
        for(int i = 0; i < spawnPointsCount; i++)
        {
            float angle = Random.Range(0, Mathf.PI * 2);
            float distance = Random.Range(0, 30);
            spawnPoints.Add(new Vector3(Mathf.Cos(angle) * distance, 1, Mathf.Sin(angle) * distance));
        }

        foreach(Vector3 spawnPoint in spawnPoints)
        {
            Debug.Log(spawnPoint);
            for(int i = 0; i < spawnCount; i++)
            {
                Spawn(new Vector3(Random.Range(spawnPoint.x - spawnRange, spawnPoint.x + spawnRange), 1, Random.Range(spawnPoint.z - spawnRange, spawnPoint.z + spawnRange)));
            }
        }
    }
     
    /* TOOLS */
    public void Spawn(Vector3 spawnLocation)
    {
        ChickenBehaviour target = Instantiate(targetToSpawn, spawnLocation, Quaternion.Euler(new Vector3(0, Random.Range(-180f, 180f))));
        target.transform.GetChild(0).GetComponent<MeshRenderer>().material.color = PickRandomColor();
        target.name = "Chicken " + counter;
        counter++;
        chickens.Add(target);
    }

    private static Color PickRandomColor()
    {
        Color color = new Color(
            Random.Range(0f, 1f),
            Random.Range(0f, 1f),
            Random.Range(0f, 1f)
        );
        return color;
    }
}
