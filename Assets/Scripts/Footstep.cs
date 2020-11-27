using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Footstep : MonoBehaviour
{
    bool triggerExit = false;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (triggerExit)
        {
            GetComponent<SpriteRenderer>().color -= new Color(0, 0, 0, Time.deltaTime / 2);
            Destroy(this.gameObject, 3f);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "player")
        {
            triggerExit = true;
        }
    }
}