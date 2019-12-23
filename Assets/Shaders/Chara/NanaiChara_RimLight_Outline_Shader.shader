Shader "Aktsk/Chara/Toon + Lambert + RimLight + Outline"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}

        [HDR]_AmbColor("Ambient Color", Color) = (1,1,1,1)

        _DiffuseRate("Diffuse Blend Rate", Range(0.0, 1.0)) = 0.4

        _RimThick("Rim Thickness", Range(0.0, 10.0)) = 1.0
        _RimColor("Rim Color", Color) = (1,1,1,1)

        _LineColor("Outline Color", Color) = (0,0,0,1)
        _LineThick("Outline Thickness", Range(0.0, 0.3)) = 0.2

        _ZWrite("Z Write", Int) = 1
        _Mask("Mask", Int) = 1
        _CompareMode("CompareMode", Int) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        Lighting Off

        ZTest LEqual
        ZWrite[_ZWrite]
        Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha

        Stencil
        {
            Ref[_Mask]
            Comp[_CompareMode]
        }

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vert_in
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv 	  : TEXCOORD0;
            };

            struct vert_out
            {
                float4 pos 			: SV_POSITION;
                float2 uv 			: TEXCOORD0;
            };
						float4 _Color;

            sampler2D 	_MainTex;
            float4 		_MainTex_ST;

            uniform float 	_LineThick;
            uniform float4 	_LineColor;

            vert_out vert(vert_in v)
            {
                vert_out o;

                //Move Position
                float3 vNorm = normalize(v.normal);
                float4 vNewPos = v.vertex + (float4(vNorm.xyz, 0.0f) * _LineThick * 0.01f);
                o.pos = UnityObjectToClipPos(vNewPos);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag(vert_out i) : SV_Target
            {
                return _LineColor;
            }
            ENDCG
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

            uniform float4 _AmbColor;

            uniform float4 _RimColor;
            uniform float  _RimThick;

            float _DiffuseRate;
            uniform float3 _Light;

            vert_out vert(vert_in v)
            {
                vert_out o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.vEye = normalize(WorldSpaceViewDir(v.vertex));

                o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

                return o;
            }

            fixed3 Lambert(fixed3 normal, fixed3 lightDir, fixed3 albedo)
            {
                half NdotL = max(0, dot(normal, lightDir));
                return NdotL * albedo;
            }

            fixed4 frag(vert_out i) : SV_Target
            {
                //Albedo
                float4 vAlbedo = tex2D(_MainTex, i.uv);

                fixed3 vLambert = Lambert(i.worldNormal, i.lightDir, vAlbedo.rgb);
                fixed3 vDiffuse = lerp(vAlbedo.rgb, vLambert, _DiffuseRate);

                //-------------------------------------------------
                //Rim
                fixed3 E = i.vEye;
                half fRim = max(0, dot(i.worldNormal, E));
                fRim = 1.0f - fRim;

                //Rim Thick
                fRim = pow(fRim, 8);
                fRim = min(1, fRim * _RimThick);

                //Rim Color
                vDiffuse = lerp(vDiffuse, _RimColor.rgb, fRim);
                return float4(vDiffuse * _AmbColor.rgb, vAlbedo.a);

            }
            ENDCG
        }

    }
    Fallback "VertexLit"
    CustomEditor "NanaiCharaRimLightOutlineShaderEditor"
}