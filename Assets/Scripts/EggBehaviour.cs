using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EggBehaviour : MonoBehaviour
{
    [SerializeField] [Range(1f, 120f)] private float minHatchSpeed = 30;
    [SerializeField] [Range(1f, 120f)] private float maxHatchSpeed = 60;
    public ChickBehaviour chick;

    private float timer;

    private void Awake()
    {
        timer = 0;
    }

    private void Update()
    {
        float hatchTime = Random.Range(minHatchSpeed, maxHatchSpeed);
        if(timer >= hatchTime)
        {
            Hatch();
        }
        timer += Time.deltaTime;
    }

    private void Hatch()
    {
        ChickBehaviour newChick = Instantiate(chick, transform.position, Quaternion.identity);
        newChick.transform.GetChild(0).GetComponent<MeshRenderer>().material.color = transform.GetChild(0).GetComponent<MeshRenderer>().material.color;
        Destroy(this.gameObject);
    }

}
