Shader "Aktsk/Chara/Toon + Lambert + Specular + RimLight"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}

        [HDR]_AmbColor("Ambient Color", Color) = (1,1,1,1)

        _DiffuseRate("Diffuse Blend Rate", Range(0.0, 1.0)) = 0.4

        _SpecularRate("Specular Blend Rate", Range(0.0, 1.0)) = 0.4

        _RimThick("Rim Thickness", Range(0.0, 10.0)) = 1.0
        _RimColor("Rim Color", Color) = (1,1,1,1)

        _Mask("Mask", Int) = 1
        _CompareMode("CompareMode", Int) = 0

    }

    SubShader
    {
        Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        Lighting Off

        ZTest LEqual
        ZWrite On
        Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha

        Stencil
        {
            Ref[_Mask]
            Comp[_CompareMode]
        }

        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                float3 worldNormal	: TEXCOORD1;
                float3 vEye			: TEXCOORD2;
                float3 lightDir		: TEXCOORD3;
            };

            sampler2D 	_MainTex;
            float4 		_MainTex_ST;

            float4 _AmbColor;

            float4 _RimColor;
            float  _RimThick;

            float _DiffuseRate;
            float3 _Light;

            float _SpecularPower;
            float _SpecularRate;

            vert_out vert(vert_in v)
            {
                vert_out o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                // ViewDir
                o.vEye = normalize(WorldSpaceViewDir(v.vertex));

                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

                return o;
            }

            fixed3 Lambert(fixed3 normal, fixed3 lightDir, fixed3 albedo)
            {
                half NdotL = max(0, dot(normal, lightDir));
                return NdotL * albedo;
            }

            fixed3 NormalizeHalfLambert(fixed3 normal, fixed3 lightDir, fixed3 albedo)
            {
                half NdotL = max(0, dot(normal, lightDir)) * 0.5 + 0.5;
                return albedo * NdotL * NdotL * (3.0f / (4.0f * 3.1415926535));
            }

            fixed4 frag(vert_out i) : SV_Target
            {
                //Albedo
                float4 vAlbedo = tex2D(_MainTex, i.uv);

                fixed3 vLambert = Lambert(i.worldNormal, i.lightDir, vAlbedo.rgb);
                fixed3 vDiffuse = lerp(vAlbedo.rgb, vLambert, _DiffuseRate);

                // Specular powerは10で決め打ち Rateで強さ調整
                fixed3 R = reflect(-i.lightDir, i.worldNormal);
                fixed3 vSpecular = pow(max(0.0f, dot(R, i.vEye)), 10) * vDiffuse;
                vDiffuse += lerp(float3(0, 0, 0), vSpecular, _SpecularRate);
                    
                //Rim
                half fRim = max(0, dot(i.worldNormal, i.vEye));
                fRim = 1.0f - fRim;

                //Rim Thick
                fRim = pow(fRim, 8);
                fRim = min(1, fRim * _RimThick);

                //Rim Color
                vDiffuse = lerp(vDiffuse, _RimColor.rgb, fRim);
                return float4(vDiffuse  * _AmbColor.rgb, vAlbedo.a);

            }
            ENDCG
        }

    }
    Fallback "VertexLit"
    CustomEditor "NanaiCharaSpecularRimLightShaderEditor"
}