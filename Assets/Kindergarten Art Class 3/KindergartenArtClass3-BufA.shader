Shader "ShaderToy/KindergartenArtClass3-BufA"
{
	Properties
	{
		_Channel0 ("iChannel0", 2D) = "black" {}
		_Channel1 ("iChannel1", 2D) = "black" {}
		_Channel2 ("iChannel2", 2D) = "black" {}
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

			#define iChannel2 _Channel2
			sampler2D iChannel2;

			#define iResolution _ScreenParams
			// float3;

			#define iTime _Time.y
			// float;

			#define iTimeDelta unity_DeltaTime.x
			// float;

			#define iFrame ((int)(_Time.y / iTimeDelta))
			// int;

			#define iMouse _MousePos
			float4 iMouse;

			float mod(float x, float y) { return x - y * floor(x / y); }


			/*
				Common shader mains for ShaderToy fragment programs
			*/
			static float c = .5;
			static int STATE_WAVES = 0;
			static int STATE_BLOCK = 10;
			static int STATE_CLEAR = 20;

			bool isPressed(int key)
			{
				float val = tex2D(iChannel2, float2( (float(key) + 0.5) / 256.0, 0.25) ).x;
				return val > .5;
			}

			bool isToggled(int key)
			{
				float val = tex2D(iChannel2, float2( (float(key) + 0.5) / 256.0, 0.75) ).x;
				return val > .5;
			}

			int getState(int state)
			{
				bool change = isToggled(67);

				int iState = int(state);
				bool lastToggle = iState - 100 >= 0;

				iState = iState - int(lastToggle) * 100;


				change = change != lastToggle;
				if (!change)
				{
					return iState;
				}
				else if (iState == STATE_WAVES)
				{
					return STATE_BLOCK;
				}
				else if (iState == STATE_BLOCK)
				{
					return STATE_CLEAR;
				}
				else
				{
					return STATE_WAVES;
				}
			}

			float setState(int state)
			{
				return float(state) + 100. * float(isToggled(67));
			}

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

			float2 hash2(float n) { return frac(sin(float2(n, n + 1.0))*float2(43758.5453123, 22578.1459123)); }

			// smoothstep interpolation of texture
			float4 ssamp(float2 uv, float oct)
			{
				uv /= oct;

				//return tex2D( iChannel0, uv, -10.0 );
				float texSize = 8.;

				float2 x = uv * texSize - .5;
				float2 f = frac(x);

				// remove fractional part
				x -= f;

				// apply smoothstep to fractional part
				f = f * f*(3.0 - 2.0*f);

				// reapply fractional part
				x += f;

				uv = (x + .5) / texSize;

				//uv.y = 1 - uv.y;
				//return tex2D(iChannel1, uv);
				return tex2Dbias(iChannel1, float4(uv, 0., -10.0));
			}


			static float2 e = float2(1. / 256., 0.);
			float4 dx(float2 uv, float oct) { return (ssamp(uv + e.xy, oct) - ssamp(uv - e.xy, oct)) / (2.*e.x); }
			float4 dy(float2 uv, float oct) { return (ssamp(uv + e.yx, oct) - ssamp(uv - e.yx, oct)) / (2.*e.x); }


			void mainImage(out float4 fragColor, float2 fragCoord)
			{

				float2 delta = float2(1., 1.) / iResolution.xy;

				float3 offset = float3(delta.x,delta.y,0.);

				float2 uv = fragCoord.xy * delta;

				float4 f = tex2D(iChannel0, uv);

				float state = f.z;

				int iState = getState(state);

				float mouseRadius = 10. + float(isPressed(65)) * 10.;

				if (iTime < .5)
				{
					float rand = tex2D(iChannel1, uv/4.).x;
					if (rand > .9 || rand < .05)
						fragColor = float4(0., 5., setState(STATE_WAVES), 0.);
					else
						fragColor = float4(0., 0., setState(STATE_WAVES), 0.);
				}
				else if (isPressed(82))
				{
					fragColor = float4(0., 0., setState(STATE_WAVES), 0.);
				}
				else if (fragCoord.x == 0. || fragCoord.y == 0. || fragCoord.x == iResolution.x - 1. || fragCoord.y == iResolution.y - 1.)
				{
					// Limites ecran
					fragColor = float4(0., 0., setState(iState), 1.);
				}
				else if (iState == STATE_CLEAR && iMouse.w > 0. && length(fragCoord.xy - iMouse.xy) < mouseRadius)
				{
					fragColor = float4(0., 0., setState(iState), 0.);
				}
				else if (f.w > 0.0)
				{
					fragColor = float4(0., 0., setState(iState), 1.0);
				}
				else if (iState == STATE_BLOCK && iMouse.w > 0. && length(fragCoord.xy - iMouse.xy) < mouseRadius)
				{
					fragColor = float4(0., 0., setState(iState), 1.0);
				}
				else if (iState == STATE_WAVES && iMouse.w > 0. && length(fragCoord.xy - iMouse.xy) < mouseRadius)
				{
					float dist = length(fragCoord.xy - iMouse.xy);
					fragColor = float4(f.y, 40. * exp(-0.001 * dist * dist), setState(iState), 0.0);
				}
				else
				{


					float2 mouse = iMouse.xy * delta;


					// Sample stuff for derivatives
					float4 fxp = tex2D(iChannel0, uv + offset.xz);
					float4 fxm = tex2D(iChannel0, uv - offset.xz);

					float4 fyp = tex2D(iChannel0, uv + offset.zy);
					float4 fym = tex2D(iChannel0, uv - offset.zy);

					// Discrete wave pde
					float ft = c * c * (fxp.y + fxm.y + fyp.y + fym.y - 4.0 * f.y) - f.x + 2.0 * f.y;

					// x = value at t-1, y = value at t, z = state, w = blocked
					// Little bit of damping so everything settles down
					fragColor = float4(float2(f.y, ft) * 0.995, setState(iState), 0.0);
				}
			}

			ENDCG
		}
	}
}
