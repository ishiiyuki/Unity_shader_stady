// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BMToon/BMT_Basic" {
	Properties{
		/*
		[Header(BMToon ver1.0.0)]
		[Space]
		[Toggle(USE_EDGE)] _UseEdge("Use Edge", Float) = 1
		[Space]

		_UnityAmbient("UnityAmbient",Range(0,2)) = 0.0
		[Space]

		[Header(MainColorParameter)]
		_MainTex("MainTex", 2D) = "white" {}
		_MainColor("MainColor", Color) = (1,1,1,1)
		[Space]

		[Header(ShadowColorParameter)]
		_ShadowTex("ShadowTex", 2D) = "white" {}
		_ShadowColor("ShadowColor", Color) = (0.5,0.5,0.5,1)
		_ShadowPower("ShadowPower",float) = 1.0
		[Space]

		[Header(ShadowRateParameter)]
		_RampTex("RampTex", 2D) = "white" {}
		_ShadowRate("ShadowRate",Range(-1,1)) = 0.0
		_ShadowRateTex("ShadowRateTex", 2D) = "gray" {}
		_HighlightRate("HilightRate(Use_RampAlpha&RateTexGreen)",Range(-1,1)) = 0.0
		[Space]

		[Header(SpecularParameter)]
		_SpecularTex("SpecularTex", 2D) = "gray" {}
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_SpecularPower("SpecularPower",Range(1,64)) = 1
		[Space]

		[Header(SphereMapParameter)]
		_SphereTex("SphereTex", 2D) = "black" {}
		_SphereColor("SphereColor", Color) = (1,1,1,1)
		_SphereMode("SphereMode",Range(0,1)) = 0
		[Space]

		[Header(EdgeParameter)]
		_EdgeColTex("EdgeColTex", 2D) = "white" {}
		_EdgeColor("EdgeColor",Color) = (0,0,0,1)
		_EdgeSizeTex("EdgeSizeTex", 2D) = "white" {}
		_EdgeSize("EdgeSize",Range(0,10)) = 2.5
		[Space]

		[Header(NormalMapParameter)]
		_NormalTex("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", float) = 1.0
		[Space]

		[Header(RimLightParameter)]
		_RimLightColor("RimLightColor", Color) = (0,0,0,1)
		_RimRampTex("RimRampTex", 2D) = "white" {}
		_RimLightPower("RimLightPower", float) = 8.0
		_RimLightTex("RimLightTex", 2D) = "white" {}
		_LightInfluence_Rim("LightInfluence_Rim",Range(0,1)) = 0
		*/
		[Header(BMToon ver1.0.0)]
		[Space]
		[Toggle(USE_EDGE)] _UseEdge("エッジ有効", Float) = 1
		[Space]

		_UnityAmbient("ユニティのアンビエント色有効化",Range(0,2)) = 0.0
		[Space]

		[Header(MainColorParameter)]
		_MainTex("メインテクスチャ", 2D) = "white" {}
		_MainColor("メイテンクスチャ補正色", Color) = (1,1,1,1)
		[Space]

		[Header(ShadowColorParameter)]
		_ShadowTex("影テクスチャ", 2D) = "white" {}
		_ShadowColor("影テクスチャ補正色", Color) = (0.5,0.5,0.5,1)
		_ShadowPower("自己乗算影",float) = 1.0
		[Space]

		[Header(ShadowRateParameter)]
		_RampTex("ランプテクスチャ", 2D) = "white" {}
		_ShadowRate("影になりやすさ",Range(-1,1)) = 0.0
		_ShadowRateTex("影になりやすさテクスチャ", 2D) = "gray" {}
		_HighlightRate("ハイライトになりやすさ(Use_RampAlpha&RateTexGreen)",Range(-1,1)) = 0.0
		[Space]

		[Header(SpecularParameter)]
		_SpecularTex("スぺキュラ色テクスチャ", 2D) = "white" {}
		_SpecularColor("スぺキュラ補正色", Color) = (0,0,0,1)
		_SpecularPower("スぺキュラ鋭さ",Range(1,64)) = 1
		[Space]

		[Header(SphereMapParameter)]
		_SphereTex("スフィアテクスチャ", 2D) = "black" {}
		_SphereColor("スフィアテクスチャ補正色", Color) = (1,1,1,1)
		_SphereMode("スフィアモード（0:加算 1:乗算）",Range(0,1)) = 0
		[Space]

		[Header(EdgeParameter)]
		_EdgeColTex("エッジ色テクスチャ", 2D) = "white" {}
		_EdgeColor("エッジ補正色",Color) = (0,0,0,1)
		_EdgeSizeTex("エッジ大きさテクスチャ", 2D) = "white" {}
		_EdgeSize("エッジ大きさ",Range(0,10)) = 2.5
		[Space]

		[Header(NormalMapParameter)]
		_NormalTex("ノーマルマップテクスチャ", 2D) = "bump" {}
		_NormalScale("ノーマルマップ強度", float) = 1.0
		[Space]

		[Header(RimLightParameter)]
		_RimLightTex("リムライトテクスチャ", 2D) = "white" {}
		_RimLightColor("リムライト補正色", Color) = (0,0,0,1)
		_RimRampTex("リムライト用ランプテクスチャ", 2D) = "white" {}
		_RimLightPower("リムライト鋭さ", float) = 8.0
		_LightInfluence_Rim("メインライト影響度",Range(0,1)) = 0

	}
		SubShader{
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		cull off
		//メインライト処理
		Tags{ "RenderType" = "Opaque" }
		Pass{
		Name "BMT_BASIC_MAIN"
		Tags{
		"LightMode" = "ForwardBase"
	}
		CGPROGRAM

#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase
#include "UnityCG.cginc"
#include "AutoLight.cginc"

	uniform float _UnityAmbient;
	uniform float _HighlightRate;
	uniform float _ShadowRate;
	uniform sampler2D _ShadowRateTex;
	uniform float4 _ShadowRateTex_ST;
	uniform float4 _MainColor;
	uniform sampler2D _ShadowTex;
	uniform float4 _ShadowTex_ST;
	uniform float4 _ShadowColor;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform sampler2D _RampTex;
	uniform float4 _RampTex_ST;
	uniform float _ShadowPower;
	uniform fixed4 _LightColor0;

	uniform sampler2D _SpecularTex;
	uniform float4 _SpecularTex_ST;
	uniform float4 _SpecularColor;
	uniform float _SpecularPower;

	uniform sampler2D _SphereTex;
	uniform float4 _SphereTex_ST;
	uniform float4 _SphereColor;
	uniform float _SphereMode;

	uniform sampler2D _NormalTex;
	uniform float4 _NormalTex_ST;
	uniform float _NormalScale;

	uniform float4 _RimLightColor;
	uniform float _RimLightPower;
	uniform float _LightInfluence_Rim;
	uniform sampler2D _RimLightTex;
	uniform float4 _RimLightTex_ST;
	uniform sampler2D _RimRampTex;
	uniform float4 _RimRampTex_ST;

	//バーテックスシェーダからフラグメントシェーダに渡す構造体
	struct v2f {
		float4 pos : SV_POSITION;
		float2 tex : TEXCOORD0;
		float3 Eye : TEXCOORD1;
		float2 sptex : TEXCOORD2;
		float3 normal : NORMAL;
		LIGHTING_COORDS(3, 4)
	};

	//バーテックスシェーダ
	v2f vert(appdata_base v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.tex = v.texcoord;
		o.normal = v.normal;
		o.Eye = WorldSpaceViewDir(v.vertex);

		float2 NormalWV = normalize(mul((fixed3x3)UNITY_MATRIX_V, o.normal));
		o.sptex.x = NormalWV.x * 0.5f + 0.5f;
		o.sptex.y = NormalWV.y * 0.5f + 0.5f;

		TRANSFER_VERTEX_TO_FRAGMENT(o);
		return o;
	}
	//フラグメントシェーダ
	float4 frag(v2f i) : COLOR{
		//ノーマルマップ
		i.normal = lerp(i.normal,i.normal+UnpackNormal(tex2D(_NormalTex,i.tex * _NormalTex_ST.xy + _NormalTex_ST.zw)),_NormalScale);

		i.normal = mul(unity_ObjectToWorld, float4(i.normal.xyz, 0.0)).xyz;
	//光源方向
	float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);

	_LightColor0.a = 1;
	//スぺキュラ
	float3 HalfVector = normalize(normalize(i.Eye) + normalize(LightDir));
	float4 SpecularCol = tex2D(_SpecularTex, i.tex * _SpecularTex_ST.xy + _SpecularTex_ST.zw);
	float3 Specular = pow(max(0, dot(HalfVector, normalize(i.normal))), _SpecularPower) * _SpecularColor * _LightColor0 * SpecularCol.rgb * 2.0;

	float shadow = LIGHT_ATTENUATION(i);
	float4 AmbientColor = UNITY_LIGHTMODEL_AMBIENT;

	float4 retCol = float4(0,0,0,1);

	float4 MainCol;
	MainCol = tex2D(_MainTex, i.tex * _MainTex_ST.xy + _MainTex_ST.zw) * _MainColor;

	float4 ShadowCol;
	ShadowCol = tex2D(_ShadowTex, i.tex * _ShadowTex_ST.xy + _ShadowTex_ST.zw) * _ShadowColor;
	if (_ShadowPower > 1) ShadowCol *= pow(MainCol, _ShadowPower);

	//スフィア
	float4 SpCol = tex2D(_SphereTex,i.sptex * _SphereTex_ST.xy + _SphereTex_ST.zw);
	SpCol *= _SphereColor;
	MainCol = lerp(MainCol + SpCol, MainCol * SpCol, _SphereMode);
	ShadowCol = lerp(ShadowCol + SpCol, ShadowCol * SpCol, _SphereMode);
	MainCol.rgb += Specular;

	//影なりやすさ
	float4 ShadowAndHighLightTex = tex2D(_ShadowRateTex, i.tex * _ShadowRateTex_ST.xy + _ShadowRateTex_ST.zw);
	float ShadowRate = _ShadowRate - (ShadowAndHighLightTex.r * 2 - 1);
	float HighLightRate = _HighlightRate - (ShadowAndHighLightTex.g * 2 - 1);
	float d = max(0, dot(normalize(LightDir.xyz), normalize(i.normal))) * shadow;

	float ramp = tex2D(_RampTex, float2(max(0, min(1, d - ShadowRate)), 0.5) * _RampTex_ST.xy + _RampTex_ST.zw).r;
	float rampHL = tex2D(_RampTex, float2(max(0, min(1, d - HighLightRate)), 0.5) * _RampTex_ST.xy + _RampTex_ST.zw).a;

	//ramp *= shadow;
	retCol = lerp(ShadowCol * _LightColor0, MainCol * _LightColor0 + (1- rampHL)*_LightColor0, ramp);
	retCol.rgb += AmbientColor.rgb*_UnityAmbient;

	//リムライト
	float4 Rim = tex2D(_RimLightTex, i.tex * _RimLightTex_ST.xy + _RimLightTex_ST.zw) * _RimLightColor;
	float RimD = dot(normalize(i.Eye),normalize(i.normal));

	float rim_ramp = 1 - tex2D(_RimRampTex, float2(max(0, min(1, pow(RimD, _RimLightPower))), 0.5) * _RimRampTex_ST.xy + _RimRampTex_ST.zw).r;
	Rim.rgb = rim_ramp * Rim.rgb * lerp(1,_LightColor0, _LightInfluence_Rim);

	float RimLV = max(0,dot(normalize(-i.Eye), normalize(LightDir)));
	Rim *= lerp(1,RimLV, _LightInfluence_Rim);
	retCol.rgb += Rim.rgb * 2;

	return retCol;
	}

		ENDCG
	}
		//-----------------------------------------------------------------------------
		//サブライト用パス

		Pass{
		Name "BMT_BASIC_SUB"
		Tags{ "LightMode" = "ForwardAdd" }

		Blend One One
		CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase	
#include "UnityCG.cginc"
#include "AutoLight.cginc"

	uniform float _UnityAmbient;
	uniform float _ShadowRate;
	uniform sampler2D _ShadowRateTex;
	uniform float4 _ShadowRateTex_ST;
	uniform float4 _MainColor;
	uniform sampler2D _ShadowTex;
	uniform float4 _ShadowTex_ST;
	uniform float4 _ShadowColor;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform sampler2D _RampTex;
	uniform float4 _RampTex_ST;
	uniform float _ShadowPower;
	uniform fixed4 _LightColor0;

	uniform sampler2D _SpecularTex;
	uniform float4 _SpecularTex_ST;
	uniform float4 _SpecularColor;
	uniform float _SpecularPower;

	uniform sampler2D _SphereTex;
	uniform float4 _SphereTex_ST;
	uniform float4 _SphereColor;
	uniform float _SphereMode;

	uniform sampler2D _NormalTex;
	uniform float4 _NormalTex_ST;
	uniform float _NormalScale;

	//バーテックスシェーダからフラグメントシェーダに渡す構造体
	struct v2f {
		float4 pos : SV_POSITION;
		float2 tex : TEXCOORD0;
		float3 Eye : TEXCOORD1;
		float2 sptex : TEXCOORD2;
		float3 normal : NORMAL;
		LIGHTING_COORDS(3, 4)
	};

	//バーテックスシェーダ
	v2f vert(appdata_base v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.tex = v.texcoord;
		o.normal = mul(unity_ObjectToWorld, float4(v.normal.xyz, 0.0)).xyz;
		o.Eye = WorldSpaceViewDir(v.vertex);

		float2 NormalWV = normalize(mul((fixed3x3)UNITY_MATRIX_V, o.normal));
		o.sptex.x = NormalWV.x * 0.5f + 0.5f;
		o.sptex.y = NormalWV.y * 0.5f + 0.5f;

		TRANSFER_VERTEX_TO_FRAGMENT(o);

		return o;
	}
	//フラグメントシェーダ
	float4 frag(v2f i) : COLOR{
		//ノーマルマップ
		i.normal += UnpackNormal(tex2D(_NormalTex,i.tex * _NormalTex_ST.xy + _NormalTex_ST.zw))*_NormalScale;
	//光源方向
	float3 LightDir = _WorldSpaceLightPos0;

	//スぺキュラ
	float3 HalfVector = normalize(normalize(i.Eye) + -LightDir);
	float4 SpecularCol = tex2D(_SpecularTex, i.tex * _SpecularTex_ST.xy + _SpecularTex_ST.zw);
	float3 Specular = pow(max(0, dot(HalfVector, normalize(i.normal))), _SpecularPower) * _SpecularColor * _LightColor0 * SpecularCol.rgb;

	float shadow = LIGHT_ATTENUATION(i);
	float4 AmbientColor = UNITY_LIGHTMODEL_AMBIENT;

	float4 retCol = float4(0,0,0,1);

	float4 MainCol;
	MainCol = tex2D(_MainTex, i.tex * _MainTex_ST.xy + _MainTex_ST.zw) * _MainColor;
	MainCol.rgb += Specular;
	float4 ShadowCol;
	ShadowCol = tex2D(_ShadowTex, i.tex * _ShadowTex_ST.xy + _ShadowTex_ST.zw) * _ShadowColor;
	ShadowCol *= pow(MainCol, _ShadowPower);

	//スフィア
	float4 SpCol = tex2D(_SphereTex,i.sptex * _SphereTex_ST.xy + _SphereTex_ST.zw);
	SpCol *= _SphereColor;
	MainCol = lerp(MainCol + SpCol, MainCol * SpCol, _SphereMode);
	ShadowCol = lerp(ShadowCol + SpCol, ShadowCol * SpCol, _SphereMode);

	_LightColor0.a = 1;
	//影なりやすさ
	float ShadowRate = _ShadowRate - (tex2D(_ShadowRateTex, i.tex * _ShadowRateTex_ST.xy + _ShadowRateTex_ST.zw).r * 2 - 1);
	float d = max(0, dot(normalize(LightDir.xyz), normalize(i.normal)) * 0.5 + 0.5) * shadow;
	float ramp = tex2D(_RampTex, float2(max(0, min(1, d - ShadowRate)), 0.5) * _RampTex_ST.xy + _RampTex_ST.zw).r;

	//ramp *= shadow;
	retCol = lerp(ShadowCol * _LightColor0, MainCol * _LightColor0, ramp);
	retCol.rgb += AmbientColor.rgb*_UnityAmbient;
	return retCol;
	}

		ENDCG
	}
		//----------------------------------------------------------------------------------------
		//エッジ---
		Pass{

		Cull         Front                            // Front(表) は非表示
		ZTest        Less                             // 深度バッファと比較(近距離)

		CGPROGRAM                                     // Cgコード
#pragma shader_feature USE_EDGE
#include "UnityCG.cginc"                      // 基本セット
#pragma target 3.0                            // Direct3D 9 上の Shader Model 3.0 にコンパイル
#pragma vertex        vertFunc                // バーテックスシェーダーに vertFunc を使用
#pragma fragment    fragFunc                  // フラグメントシェーダーに fragFunc を使用

													  // Cgコード内で、使用する宣言

	uniform	sampler2D _EdgeColTex;
	uniform sampler2D _EdgeSizeTex;
	float _EdgeSize;
	float4 _EdgeColor;
	float _UseEdge;

	float4 _MainTex_ST;                           // uv

	struct v2f {                                  // vertex シェーダーと fragment シェーダーの橋渡し
		float4 pos      : SV_POSITION;
		float2 uv       : TEXCOORD0;
	};

	v2f vertFunc(appdata_tan v) {                 // Vertex Shader
		v2f o = (v2f)0;
		#if !USE_EDGE
			return o;
		#else
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			float4 pos = UnityObjectToClipPos(v.vertex);                               // 頂点
			float4 normal = normalize(UnityObjectToClipPos(float4(v.normal, 0)));    // 法線

			float scale_col = tex2Dlod(_EdgeSizeTex, float4(o.uv,0,0)).r;
			float  edgeScale = _EdgeSize * 0.002 * scale_col * saturate(1 - length(WorldSpaceViewDir(v.vertex))*0.05);                                       // Edge スケール係数
			float4 addpos = normal * pos.w * edgeScale;                                 // 頂点座標拡張方向とスケール
			o.pos = pos + addpos;
			return o;
		#endif
	}

	float4 fragFunc(v2f i) : COLOR{               // Fragment Shader
		#if !USE_EDGE
				return 0;
		#else
			float4 col = tex2D(_EdgeColTex, i.uv.xy);
			col *= _EdgeColor;
			return col;
		#endif
	}
		ENDCG                                         // Cgコード終了


	}
	}
	FallBack "Diffuse"
}
