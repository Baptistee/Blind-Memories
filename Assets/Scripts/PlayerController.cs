using UnityEngine;
using UnityEngine.AI;


public class PlayerController : MonoBehaviour
{
    public Camera cam;

    public NavMeshAgent agent;

    public NavMeshPath path;

    void Start()
    {
        path = new NavMeshPath();
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Debug.Log("if click");
            Ray ray = cam.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            
            if (Physics.Raycast(ray, out hit))
            {
                Debug.Log("if move");
                NavMesh.CalculatePath(agent.transform.position, hit.point,NavMesh.AllAreas,path);
                // MOVE OUR AGENT
                agent.SetDestination(hit.point);
                for (int i = 0; i < path.corners.Length - 1; i++)
                {
                    Debug.DrawLine(path.corners[i], path.corners[i + 1], Color.red, 2, false);
                }
            }
        }
        
    }
}
