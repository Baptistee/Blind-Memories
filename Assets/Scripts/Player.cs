using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    Vector2 movement;
    public float movespeed = 10f;
    public Transform camTransform;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        movement.x = Input.GetAxisRaw("Horizontal");
        movement.y = Input.GetAxisRaw("Vertical");

        //déplacements
        transform.Translate(movement * movespeed * Time.deltaTime);
        camTransform.position = new Vector3(transform.position.x, transform.position.y, -5);
    }
}
