// Original reference: https://www.shadertoy.com/view/MlVfDR
// Translated from GLSL to HLSL by Przemyslaw Zaworski

Shader "Assets/WavePropagation"
{

	Properties
	{
		_MainTexture("Main Texture", 2D) = "black"{}
	}
	SubShader
	{

//-------------------------------------------------------------------------------------------
	
		CGINCLUDE
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

		#define iTime _Time.y
		// float;

		#define iResolution _ScreenParams
		// float3;
		
		sampler2D _MainTexture;
		
		void mainImage(out float4 fragColor, float2 fragCoord);

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv * iResolution.xy;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float4 fragColor;
			mainImage(fragColor, i.uv);
			return fragColor;
		}
		
		ENDCG

//-------------------------------------------------------------------------------------------
// Buffer A
		Pass
		{ 
			CGPROGRAM
			sampler2D _BufferA;
			int iFrame;
			float4 iMouse;

			static float c = .5;
			static int STATE_WAVES = 0;
		
			void mainImage(out float4 fragColor, float2 fragCoord)
			{
				float2 delta = float2(1.,1.) / iResolution.xy;
				
				float3 offset = float3(delta.x, delta.y, 0.);

				float2 uv = fragCoord.xy * delta;

				float4 f = tex2D(_BufferA, uv);

				float state = f.z;

				int iState = 0;

				float mouseRadius = 10.;

				if (fragCoord.x == 0. || fragCoord.y == 0. || fragCoord.x == iResolution.x - 1. || fragCoord.y == iResolution.y - 1.)
				{
					// Boundary conditions
					fragColor = float4(0., 0., 0., 1.0);
				}
				else if (f.w > 0.0)
				{
					fragColor = float4(0., 0., 0., 1.0);
				}
				else if (iState == STATE_WAVES && iMouse.w > 0. && length(fragCoord.xy - iMouse.xy) < mouseRadius)
				{
					float dist = length(fragCoord.xy - iMouse.xy);
					fragColor = float4(f.y, 40. * exp(-0.001 * dist * dist), 0., 0.0);
				}
				else
				{
					float2 mouse = iMouse.xy * delta;

					float4 fxp = tex2D(_BufferA, uv + offset.xz);
					float4 fxm = tex2D(_BufferA, uv - offset.xz);

					float4 fyp = tex2D(_BufferA, uv + offset.zy);
					float4 fym = tex2D(_BufferA, uv - offset.zy);

					float ft = c * c * (fxp.y + fxm.y + fyp.y + fym.y - 4.0 * f.y) - f.x + 2.0 * f.y;

					fragColor = float4(float2(f.y, ft) * 0.995, 0., 0.0);
				}
			}
			
			ENDCG
		}

//-------------------------------------------------------------------------------------------
// Image
		Pass
		{ 
			CGPROGRAM
			sampler2D _BufferA;
			float4 _BufferA_TexelSize;

			void mainImage(out float4 fragColor, float2 fragCoord)
			{
				float2 uv = fragCoord.xy / iResolution.xy;
				float4 vals = tex2D(_BufferA,uv);

				float2 delta = float2(1.,1.) / iResolution.xy;

				float3 offset = float3(delta.x,delta.y,0.);

				float4 fxp = tex2D(_BufferA,uv + offset.xz);
				float4 fxm = tex2D(_BufferA,uv - offset.xz);

				float4 fyp = tex2D(_BufferA,uv + offset.zy);
				float4 fym = tex2D(_BufferA,uv - offset.zy);

				float dx = fxp.y - fxm.y;
				float dy = fyp.y - fym.y;

				float3 fx = float3(2.,0.,dx);
				float3 fy = float3(0.,2.,dy);

				float3 n = normalize(cross(fx,fy));

				float3 campos = float3(0.5,0.5,200.);
				float3 p = float3(uv,0.);

				float3 v = campos - p;

				float3 l = normalize(float3(10.,70.,400.));

				float3 h = normalize(l + v);

				float specular = pow(max(0.,dot(h,n)),16.);

				float3 r = refract(-v,n,1. / 1.35);

				float2 roffset = 10. * vals.y * normalize(r.xy - n.xy) / iResolution.xy;

				float3 color = tex2D(_MainTexture,uv + roffset).xyz;

				float block = 1. - vals.w;

				color *= block;

				float factor = clamp(max(dot(n,l),0.) + specular + 0.2,0.,1.);
				fragColor = float4(color * factor,1.);
			}
			
			ENDCG
		}

//-------------------------------------------------------------------------------------------
		
	}
}