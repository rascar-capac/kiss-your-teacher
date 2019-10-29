using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Food : InventoryItemBase
{
    public int FoodPoints = 20;

    public override void OnUse()
    {
        PlayerController player = FindObjectOfType<PlayerController>();
        player.Eat(FoodPoints);

        player.Inventory.RemoveItem(this);

        Destroy(this.gameObject);
    }
}
