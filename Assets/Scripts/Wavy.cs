using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Wavy : MonoBehaviour
{

    public Material mat;

    public float waveNumber;
    public float waveLength;

    void Update()
    {
        Shader.SetGlobalFloat("_waveLength", waveNumber); // I know I switched the variables on accident. It still works though.
        Shader.SetGlobalFloat("_waveNumber", waveLength);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, mat);
    }
}
