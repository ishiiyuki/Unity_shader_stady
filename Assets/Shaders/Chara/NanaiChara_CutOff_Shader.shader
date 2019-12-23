Shader "Aktsk/Chara/Chara CutOff"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        [HDR]_AmbColor("Ambient Color", Color) = (1,1,1,1)

        _AlphaTest("CutOff Rate", Range(0.0, 1.0)) = 0.5
    }
        SubShader
        {
            Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
            Lighting Off

            ZTest LEqual
            ZWrite On
            Fog { Mode Off }
            Blend SrcAlpha OneMinusSrcAlpha

            Pass
            {
                Cull Back

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase

                #include "UnityCG.cginc"

                struct vert_in
                {
                    float4 vertex : POSITION;
                    float4 color  : COLOR;
                    float3 normal : NORMAL;
                    float2 uv 	  : TEXCOORD0;
                };

                struct vert_out
                {
                    float4 pos 			: SV_POSITION;
                    float4 color  		: COLOR;
                    float2 uv 			: TEXCOORD0;
                    float3 normal	    : TEXCOORD1;
                };

                sampler2D 	_MainTex;
                float4 		_MainTex_ST;

                uniform float4 _AmbColor;

                uniform float _AlphaTest;


                vert_out vert(vert_in v)
                {
                    vert_out o;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.color = v.color;

                    o.normal = UnityObjectToWorldNormal(v.normal);

                    return o;
                }

                fixed4 frag(vert_out i) : SV_Target
                {
                    float4 vAlbedo = tex2D(_MainTex, i.uv);


                    fixed4 vFinale = i.color * vAlbedo * _AmbColor;

                    if (vFinale.a <= _AlphaTest)
                        discard;

                    return vFinale;

                }
                ENDCG
            }

        }
            Fallback "VertexLit"
}
