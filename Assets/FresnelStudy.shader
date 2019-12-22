Shader "Custom/FresnelStudy"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        //_F0 は垂直入射の時のFresnel反射係数の実部である。
        [PowerSlider(0.1)] _F0 ("F0", Range(0.0, 1.0)) = 0.02
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION; //頂点の位置 ワールドに影響あるのでfloat
                half3 normal : NORMAL; //頂点の法線
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;//SV_POSITIONはGPUがラスタライズ処理を行うために必ず必要
                half vdotn : TEXCOORD1; //２番めのUV座標
            };

            float _F0;

            v2f vert (appdata v)
            {
                v2f o;
                // MVP行列に掛ける
                // mul(UNITY_MATRIX_MVP, v.vertex) と同じ処理だけどパフォーマンス良い
                o.vertex = UnityObjectToClipPos(v.vertex);
                half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));//オブジェクト空間から見たカメラ方向を算出する関数をノーマライズ
                o.vdotn = dot(viewDir ,v.normal.xyz);//２ベクトルの内積
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fresnel
                half fresnel = _F0 + (1.0h - _F0) * pow(1.0h - i.vdotn, 5);//1.0h - i.vdotnを5乗
                return fresnel;
            }
            ENDCG
        }
    }
}
