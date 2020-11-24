using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Footstep : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Destroy(this.gameObject, 3f);
    }

    // Update is called once per frame
    void Update()
    {
        GetComponent<SpriteRenderer>().color -= new Color(0, 0, 0, Time.deltaTime/2);
    }
}
