using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Sound_source : MonoBehaviour
{
    public Image souvenir;

    // Start is called before the first frame update
    void Start()
    {
        souvenir.GetComponent<Image>().enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetButton("Fire1"))
        {
            souvenir.GetComponent<Image>().enabled = false;
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        GetComponent<AudioSource>().Stop();
        souvenir.GetComponent<Image>().enabled = true;
        GetComponent<MeshRenderer>().enabled = false;
        GetComponent<BoxCollider>().enabled = false;
    }
}
