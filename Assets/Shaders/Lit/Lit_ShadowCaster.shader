﻿Shader "Lit/Simple Difuse"
{
    Properties
    {
       [NoScaleOffset]_BaseMap("Texture2D", 2D) = "white" {}
       _BaseColor ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
        
        Pass
        {
            Name "Lit"
            // indicate that our pass is the "base" pass in forward
            // rendering pipeline. It gets ambient and main directional
            // light data set up; light direction in _WorldSpaceLightPos0
            // and color in _LightColor0
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            
            struct Attributes
            {
                float4 vertex           : POSITION;
                float3 normal           : NORMAL;
                float2 uv               : TEXCOORD0;
            };
            
            struct Varyings
            {
                float2 uv               : TEXCOORD0;
                float4 vertex           : SV_POSITION;
                half4 color             : COLOR;
            };
            
            Varyings vert(Attributes input)
            {
                Varyings o;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
                o.vertex = vertexInput.positionCS;
                
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normal);
                half3 worldNormal = normalInputs.normalWS;
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half normalLight = max(0, dot(worldNormal, _MainLightPosition.xyz));
                // factor in the light color
                o.color = normalLight * (_MainLightColor ); 
                o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return o;
            }
    
            half4 frag(Varyings input) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                col *= _BaseColor;
                col *= input.color;
                return col;
            }
            ENDHLSL
        }
    }
}