Shader "Aktsk/Room/Toon + LightMap"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _BumpMap("Normap Map", 2D) = "white" {}

        [HDR]_AmbColor("Ambient Color", Color) = (1,1,1,1)

        _DiffuseRate("Diffuse Blend Rate", Range(0.0, 1.0)) = 0.4

    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
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
            float3 uv1 : TEXCOORD1;
            float3 uv0 : TEXCOORD0;
        };

        struct vert_out
        {
            float4 pos 			: SV_POSITION;
            float4 color  		: COLOR;
            float2 uv0 : TEXCOORD0;
            float2 uv1 : TEXCOORD1;
            float3 normal	: TEXCOORD2;
            float3 vEye			: TEXCOORD3;
            float3 lightDir		: TEXCOORD4;
        };

        uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
        uniform sampler2D _BumpMap; uniform float4 _BumpMap_ST;

        uniform float4 _AmbColor;

        uniform float4 _RimColor;
        uniform float  _RimThick;

        float _DiffuseRate;

        vert_out vert(vert_in v)
        {
            vert_out o;

            o.pos = UnityObjectToClipPos(v.vertex);

            o.color = v.color;

            o.uv0 = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            o.uv1 = v.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;


            o.normal = UnpackNormal(tex2Dlod(_BumpMap, float4(o.uv1, 0, 0)));;

            o.vEye = normalize(WorldSpaceViewDir(v.vertex));

            o.lightDir = normalize(_WorldSpaceLightPos0.xyz);

            return o;
        }


        fixed4 frag(vert_out i) : SV_Target
        {
            float4 objPos = mul(unity_ObjectToWorld, float4(0,0,0,1));

            //Albedo
            float4 vAlbedo = tex2D(_MainTex, i.uv1.xy);

            float3 lightmap = float3(1.0, 1.0, 1.0);
            lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv0.xy));

            half NdotL = max(0, dot(i.normal, i.lightDir));

            float3 Diffuse = lerp(vAlbedo.rgb, NdotL * vAlbedo.rgb, _DiffuseRate);


            return float4(Diffuse * lightmap * _AmbColor.rgb, vAlbedo.a);

        }
        ENDCG
    }


    }
    Fallback "VertexLit"
}