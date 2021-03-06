// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Stady"
{
    
    Properties
    {
        
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        //_StencilComp ("Stencil Comparison", Float) = 8
        //_Stencil ("Stencil ID", Float) = 0
        //_StencilOp ("Stencil Operation", Float) = 0
        //_StencilWriteMask ("Stencil Write Mask", Float) = 255
        //_StencilReadMask ("Stencil Read Mask", Float) = 255

        //色情報は16進数？
        //_ColorMask ("Color Mask", Float) = 15

        //[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Pass
        {
            Name "Stady"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

           //頂点情報
            struct appdata_t
            {
                 //セマンティクス
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color = (1,1,1,1);
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            //頂点
            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                // UnityCG.cgincからTRANSFORM_TEXマクロを使用して
                // テクスチャスケールとオフセットが正しく適用されていることを確認
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                
                OUT.color = v.color * _Color ;
                return OUT;
            }


            //フラグメンツ
            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                //return color;

                //二色に塗り分ける まず横線の処理をしてから　縦線の領域の処理をする　合わせることで四角形が表示できる
                //return (step(0.2, IN.texcoord.y) * step(0.2, 1.0-IN.texcoord.y) ) *(step(0.2, IN.texcoord.x) * step(0.2, 1.0-IN.texcoord.x) ) ;
                //円を描画する
                fixed radius = 0.4;
                fixed r = distance(IN.texcoord, fixed2(0.5,0.5));
                return step(radius, r);
            }
        ENDCG
        }
    }
}
