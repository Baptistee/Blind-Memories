using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    Vector2 movement;
    public float movespeed = 10f;
    public Transform camTransform;

    public GameObject footstep;
    public float defaultStepDelay = 1f;
    float stepDelay;
    int nbFootStep = 0;

    // Start is called before the first frame update
    void Start()
    {
        stepDelay = defaultStepDelay;
    }

    // Update is called once per frame
    void Update()
    {
        movement.x = Input.GetAxisRaw("Horizontal");
        movement.y = Input.GetAxisRaw("Vertical");

        //déplacements
        transform.Translate(movement * movespeed * Time.deltaTime);
        camTransform.position = new Vector3(transform.position.x, transform.position.y, -5);

        footstepCheck();
    }

    void footstepCheck()
    {
        if (movement.x != 0 || movement.y != 0)
        {
            stepDelay -= Time.deltaTime;
        }

        if (stepDelay <= 0)
        {
            createFootstep();
            stepDelay = defaultStepDelay;
        }
    }

    void createFootstep()
    {
        GameObject fs = Instantiate(footstep);
        fs.transform.position = transform.position;
        if(nbFootStep % 2 == 1) fs.GetComponent<SpriteRenderer>().flipX = true;
        
        Vector3 currentPosition = transform.position;
        Vector3 stepMovement = new Vector3(movement.x, movement.y, 0);
        Vector3 futurePosition = transform.position + stepMovement;
        Vector2 dif = futurePosition - currentPosition;
        float sign = (futurePosition.x < currentPosition.x) ? 1f : -1f;
        fs.transform.eulerAngles = new Vector3(0, 0, Vector2.Angle(Vector2.up, dif) * sign);

        nbFootStep++;
    }
}
