/**
 * @author shun.kyuzen
 * 参考 -> http://iryoku.com/aacourse/downloads/09-FXAA-3.11-in-15-Slides.pdf
 * FXAA Console(低スペック向けアルゴリズム)
 *
 *
 *
 */
Shader "Aktsk/FXAA"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags{ "RenderType" = "Opaque" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            uniform sampler2D _MainTex;
            uniform half _EdgeThresholdMin;
            uniform half _EdgeThreshold;
            uniform half _EdgeSharpness;

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 fxaaConsolePosPos : TEXCOORD1;
                float4 fxaaConsoleRcpFrameOpt : TEXCOORD2;
                float4 fxaaConsoleRcpFrameOpt2 : TEXCOORD3;
            };

            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;

            v2f vert(appdata_img v)
            {
                v2f o;

                    o.pos = UnityObjectToClipPos(v.vertex);

                    o.uv = v.texcoord.xy;

                    // xy__  upper left of pixel。
                    // __zw = lower right of pixel
                    float4 fxaaConsolePosPos;
                    float2 offset = (_MainTex_TexelSize.xy) * 0.5f;
                    fxaaConsolePosPos.xy = v.texcoord.xy - offset;
                    fxaaConsolePosPos.zw = v.texcoord.xy + offset;

                    // 0.5 = default 0.3 = sharpness
                    float4 rcpSize;
                    rcpSize.xy = -_MainTex_TexelSize.xy * 0.5f;
                    rcpSize.zw = _MainTex_TexelSize.xy * 0.5f;

                    // -2.0 / inpixel
                    o.fxaaConsolePosPos = fxaaConsolePosPos;
                    o.fxaaConsoleRcpFrameOpt = rcpSize;
                    o.fxaaConsoleRcpFrameOpt2 = rcpSize;

                    o.fxaaConsoleRcpFrameOpt2.xy *= 4.0;
                    o.fxaaConsoleRcpFrameOpt2.zw *= 4.0;

                    return o;
                }

                #define FxaaTexTop(t, p) tex2Dlod(t, float4(p, 0.0, 0.0))

                half FxaaLuma(half4 rgba) { return rgba.g; }

                inline half TexLuminance(half2 uv)
                {
                    return FxaaLuma(FxaaTexTop(_MainTex, uv));
                }

                half3 FxaaPixelShader(float2 pos, float4 fxaaConsolePosPos, float4 fxaaConsoleRcpFrameOpt, float4 fxaaConsoleRcpFrameOpt2)
                {
                    half lumaNw = TexLuminance(fxaaConsolePosPos.xy);
                    half lumaSw = TexLuminance(fxaaConsolePosPos.xw);
                    half lumaNe = TexLuminance(fxaaConsolePosPos.zy);
                    half lumaSe = TexLuminance(fxaaConsolePosPos.zw);

                    half4 rgbyM = FxaaTexTop(_MainTex, pos);
                    half lumaCentre = rgbyM.g;

                    half lumaMaxNwSw = max(lumaNw , lumaSw);
                    lumaNe += 0.002604167f; //1.0 / 384.0;
                    half lumaMinNwSw = min(lumaNw , lumaSw);

                    half lumaMaxNeSe = max(lumaNe , lumaSe);
                    half lumaMinNeSe = min(lumaNe , lumaSe);

                    half lumaMax = max(lumaMaxNeSe, lumaMaxNwSw);
                    half lumaMin = min(lumaMinNeSe, lumaMinNwSw);

                    half lumaMaxScaled = lumaMax * _EdgeThreshold;

                    half lumaMinCentre = min(lumaMin , lumaCentre);
                    half lumaMaxScaledClamped = max(_EdgeThresholdMin , lumaMaxScaled);
                    half lumaMaxCentre = max(lumaMax , lumaCentre);
                    half dirSWMinusNE = lumaSw - lumaNe;
                    half lumaMaxCMinusMinC = lumaMaxCentre - lumaMinCentre;
                    half dirSEMinusNW = lumaSe - lumaNw;

                    if (lumaMaxCMinusMinC < lumaMaxScaledClamped)
                    {
                        return rgbyM;
                    }

                    half2 dir;
                    dir.x = dirSWMinusNE + dirSEMinusNW;
                    dir.y = dirSWMinusNE - dirSEMinusNW;

                    half2 dir1 = normalize(dir.xy);
                    half4 rgbyN1 = FxaaTexTop(_MainTex, pos.xy - dir * fxaaConsoleRcpFrameOpt.zw);
                    half4 rgbyP1 = FxaaTexTop(_MainTex, pos.xy + dir * fxaaConsoleRcpFrameOpt.zw);

                    half dirAbsMinTimesC = min(abs(dir1.x) , abs(dir1.y)) * _EdgeSharpness;
                    half2 dir2 = clamp(dir1.xy / dirAbsMinTimesC, -2.0, 2.0);

                    half4 rgbyN2 = FxaaTexTop(_MainTex, pos.xy - dir2 * fxaaConsoleRcpFrameOpt2.zw);
                    half4 rgbyP2 = FxaaTexTop(_MainTex, pos.xy + dir2 * fxaaConsoleRcpFrameOpt2.zw);

                    half4 rgbyA = rgbyN1 + rgbyP1;
                    half4 rgbyB = ((rgbyN2 + rgbyP2) * 0.25) + (rgbyA * 0.25);

                    bool twoTap = (rgbyB.g < lumaMin) || (rgbyB.g > lumaMax);

                    if (twoTap) { rgbyB.xyz = rgbyA.xyz * 0.5; }

                    return rgbyB;
                }

                half4 frag(v2f i) : SV_Target
                {
                    half3 color = FxaaPixelShader(UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST), i.fxaaConsolePosPos, i.fxaaConsoleRcpFrameOpt, i.fxaaConsoleRcpFrameOpt2);
                    return half4(color, 1.0);
                }

                ENDCG
            }
    }
}