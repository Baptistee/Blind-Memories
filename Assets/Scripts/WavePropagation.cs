// Add script to quad and assign material with shader. Play.

using System;
using UnityEngine;

public class WavePropagation : MonoBehaviour
{
	public int resolution;
	public Material material;
	public Player player;
	public Camera worldCamera;

	RenderTexture BufferA1, BufferA2;
	bool swap = true;

	void Blit(RenderTexture source, RenderTexture destination, Material mat, string name)
	{
		RenderTexture.active = destination;
		mat.SetTexture(name, source);
		GL.PushMatrix();
		GL.LoadOrtho();
		GL.invertCulling = true;
		mat.SetPass(0);
		GL.Begin(GL.QUADS);
		GL.MultiTexCoord2(0, 0.0f, 0.0f);
		GL.Vertex3(0.0f, 0.0f, 0.0f);
		GL.MultiTexCoord2(0, 1.0f, 0.0f);
		GL.Vertex3(1.0f, 0.0f, 0.0f);
		GL.MultiTexCoord2(0, 1.0f, 1.0f);
		GL.Vertex3(1.0f, 1.0f, 1.0f);
		GL.MultiTexCoord2(0, 0.0f, 1.0f);
		GL.Vertex3(0.0f, 1.0f, 0.0f);
		GL.End();
		GL.invertCulling = false;
		GL.PopMatrix();
	}

	void Start()
	{
		BufferA1 = new RenderTexture(resolution, resolution, 0, RenderTextureFormat.ARGBFloat);  //buffer must be floating point RT
		BufferA2 = new RenderTexture(resolution, resolution, 0, RenderTextureFormat.ARGBFloat);  //buffer must be floating point RT
		GetComponent<Renderer>().material = material;
		worldCamera.targetTexture = new RenderTexture(worldCamera.pixelWidth, worldCamera.pixelHeight, 0, RenderTextureFormat.ARGBFloat);
		//gameObject.transform.position = new Vector3(worldCamera.transform.position.x, worldCamera.transform.position.y, 80);
		//gameObject.transform.position = worldCamera.transform.position;
		//gameObject.transform.localScale = new Vector3(worldCamera.pixelWidth, worldCamera.pixelHeight, 0);
	}

	void Update()
	{
		RaycastHit hit;
		if (Input.GetMouseButton(0))
		{
			if (Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hit))
				material.SetVector("iMouse",
					new Vector4(hit.textureCoord.x * resolution, hit.textureCoord.y * resolution,
					Mathf.Sign(System.Convert.ToSingle(Input.GetMouseButton(0))),
					Mathf.Sign(System.Convert.ToSingle(Input.GetMouseButton(1)))));
		}
		else
		{
			material.SetVector("iMouse", new Vector4(0.0f, 0.0f, -1.0f, -1.0f));
		}

		material.SetVector("_PlayerPos", new Vector2(player.transform.position.x, player.transform.position.y));
		material.SetInt("iFrame", Time.frameCount);
		material.SetTexture("_WCTexture", worldCamera.targetTexture);
		material.SetVector("_WCResolution", new Vector2((float)worldCamera.pixelWidth, (float)worldCamera.pixelHeight));
		material.SetVector("_WaveResolution", new Vector4(resolution, resolution, 0.0f, 0.0f));

		if (swap)
		{
			material.SetTexture("_BufferA", BufferA1);
			Blit(BufferA1, BufferA2, material, "_BufferA");
			material.SetTexture("_BufferA", BufferA2);
		}
		else
		{
			material.SetTexture("_BufferA", BufferA2);
			Blit(BufferA2, BufferA1, material, "_BufferA");
			material.SetTexture("_BufferA", BufferA1);
		}
		swap = !swap;
	}

	void OnDestroy()
	{
		BufferA1.Release();
		BufferA2.Release();
	}
}