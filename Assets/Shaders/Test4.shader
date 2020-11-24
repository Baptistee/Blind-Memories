Shader "Unlit/Test4"
{
    Properties
    {
        _MainTexture("Texture", 2D) = "white" {}
        _Color("Colour", Color) = (1,1,1,1)
        _AnimationSpeed("Animation Speed", Range(0, 3)) = 0
        _OffsetSize("Offset Size", Range(0, 10)) = 0
        _Param("Param", Range(0, 10)) = 0
        _F1("Fonction 1", Int) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vertexFunc
                #pragma fragment fragmentFunc

                #include "UnityCG.cginc"

                struct appdata {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f {
                    float4 position : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                // ----------
                // Properties
                // ----------
                sampler2D _MainTexture;
                fixed4 _Color;
                float _AnimationSpeed;
                float _OffsetSize;
                float _Param;
                int _F1;

                // ----------
                // Const
                // ----------
                static float c = .5;
                static int STATE_WAVES = 0;
                static int STATE_BLOCK = 10;
                static int STATE_CLEAR = 20;

                v2f vertexFunc(appdata IN)
                {
                    v2f OUT;

                    //IN.vertex += sin(_Time.y * _AnimationSpeed + IN.vertex.y * _OffsetSize);
                    OUT.position = UnityObjectToClipPos(IN.vertex);
                    OUT.uv = IN.uv;

                    return OUT;
                }

                fixed4 fragmentFunc(v2f IN) : SV_Target
                {
                    float2 tc = IN.uv;
                    float2 p = -1. + 2. * tc;

                    float len = length(p);
                    float2 uv = tc + (p / len) * cos(len * 12. - _Time.y * 4.) * .03;
                    float3 col = tex2D(_MainTexture, uv);

                    //float3 color = _Color * sin(_Time.y) * _Param;
                    //fixed4 pixelColor = tex2D(_MainTexture, IN.uv);
                    //return pixelColor * float4(color, 1.);

                    return float4(col, 1.) * _Color;
                }

            ENDCG
        }
    }
}
/*
[Pixel_Shader]
uniform vec2 resolution; // Screen resolution
uniform float time; // time in seconds
uniform sampler2D tex0; // scene buffer
void main(void)
{
  vec2 tc = gl_TexCoord[0].xy;
  vec2 p = -1.0 + 2.0 * tc;
  float len = length(p);
  vec2 uv = tc + (p/len)*cos(len*12.0-time*4.0)*0.03;
  vec3 col = texture2D(tex0,uv).xyz;
  gl_FragColor = vec4(col,1.0);
}
*/

/*
                    float t = clamp(_Time.y / 6., 0., 1.);

                    fixed4 pixelColor = tex2D(_MainTexture, IN.uv);

                    float2 dir = pixelColor - float2(.5, .5);

                    float dist = distance(pixelColor, float2(.5, .5));
                    float2 offset = dir * (sin(dist * 80. - _Time.y * 15.) + .5) / 30.;

                    float2 texCoord = pixelColor + offset;

                    float4 diffuse = tex2D(_MainTexture, texCoord);

                    return diffuse * (1. - t);
*/