
Shader "ShaderMan/SmoothDisk"
{
    Properties{
    _MainTex("MainTex",2D) = "white"{}

    }
        SubShader
    {
    Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
    Pass
    {
    ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #include "UnityCG.cginc"



    float4 vec4(float x,float y,float z,float w) { return float4(x,y,z,w); }
    float4 vec4(float x) { return float4(x,x,x,x); }
    float4 vec4(float2 x,float2 y) { return float4(float2(x.x,x.y),float2(y.x,y.y)); }
    float4 vec4(float3 x,float y) { return float4(float3(x.x,x.y,x.z),y); }


    float3 vec3(float x,float y,float z) { return float3(x,y,z); }
    float3 vec3(float x) { return float3(x,x,x); }
    float3 vec3(float2 x,float y) { return float3(float2(x.x,x.y),y); }

    float2 vec2(float x,float y) { return float2(x,y); }
    float2 vec2(float x) { return float2(x,x); }

    float vec(float x) { return float(x); }



    struct VertexInput {
    float4 vertex : POSITION;
    float2 uv:TEXCOORD0;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    //VertexInput
    };
    struct VertexOutput {
    float4 pos : SV_POSITION;
    float2 uv:TEXCOORD0;
    //VertexOutput
    };
    sampler2D _MainTex;


    VertexOutput vert(VertexInput v)
    {
    VertexOutput o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    //VertexFactory
    return o;
    }

    // Ripple effect by Mahmud Yuldashev. Math from Adrian Boeing Blog




    fixed4 frag(VertexOutput vertex_output) : SV_Target
    {

        //variables
        float2 mouse = float2(.5,.5);
        float time = _Time.y;

        float intensity = 0.09;


        float2 p = -1. + 2. * vertex_output.uv / 1 - vec2(0,-mouse.y * .001);


        float cLength = length(p);

        float2 uv = (vertex_output.uv / 1) / -1.
            + (p / cLength) * cos(cLength * 15.0 - _Time.y * 4.0) * intensity;

        float3 col = smoothstep(0.1,.91,tex2D(_MainTex,uv).xyz);

        col.r = 0.01;
        col.g = 0.;




        return vec4(col,1.0);


        }
        ENDCG
        }
    }
}
