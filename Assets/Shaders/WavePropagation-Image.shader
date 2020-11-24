Shader "Assets/WavePropagation-Image"
{
	Properties
	{
		_Channel0("iChannel0", 2D) = "black" {} // BufA
		_Channel1("iChannel1", 2D) = "black" {} // Texture or Camera
	}
		SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
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


			/*
				Common variables/functions for ShaderToy fragment programs
			*/

			#define iChannel0 _Channel0
			sampler2D iChannel0;

			#define iChannel1 _Channel1
			sampler2D iChannel1;

			#define iResolution _ScreenParams
			// float3;


			/*
				Common shader mains for ShaderToy fragment programs
			*/

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

				void mainImage(out float4 fragColor, float2 fragCoord)
				{
					float2 uv = fragCoord.xy / iResolution.xy;
					float4 vals = tex2D(iChannel0, uv);


					float2 delta = float2(1., 1.) / iResolution.xy;

					float3 offset = float3(delta.x, delta.y, 0.);

					float4 fxp = tex2D(iChannel0, uv + offset.xz);
					float4 fxm = tex2D(iChannel0, uv - offset.xz);

					float4 fyp = tex2D(iChannel0, uv + offset.zy);
					float4 fym = tex2D(iChannel0, uv - offset.zy);

					// partial derivatives d/dx, d/dy
					float dx = fxp.y - fxm.y;
					float dy = fyp.y - fym.y;

					// partials in 3d space

					float3 fx = float3(2., 0., dx);
					float3 fy = float3(0., 2., dy);


					float3 n = normalize(cross(fx, fy));

					float3 campos = float3(0.5, 0.5, 200.);
					float3 p = float3(uv, 0.);

					float3 v = campos - p;

					float3 l = normalize(float3(10., 70., 400.));

					float3 h = normalize(l + v);

					float specular = pow(max(0., dot(h, n)), 16.);

					float3 r = refract(-v, n, 1. / 1.35);
					// very simple hacky refraction
					float2 roffset = 10. * vals.y * normalize(r.xy - n.xy) / iResolution.xy;

					float3 color = tex2D(iChannel1, uv + roffset).xyz;

					float block = 1. - vals.w;

					color *= block;

					float factor = clamp(max(dot(n, l), 0.) + specular + 0.2, 0., 1.);
					fragColor = float4(color * factor, 1.);
				}

				ENDCG
			}
	}
}
