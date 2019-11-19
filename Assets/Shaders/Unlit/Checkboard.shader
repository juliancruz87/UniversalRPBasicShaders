Shader "Unlit/Checkboard"
{
     Properties
    {
       _Density ("Density", Range (2,50)) = 30
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            
            half _Density;
            
            struct Varyings 
            {
                float2 uv       : TEXCOORD0;
                float4 vertex   : SV_POSITION;
            };
        
            Varyings vert (float4 vertex : POSITION, float2 uv : TEXCOORD0)
            {
                Varyings o;
                o.vertex = TransformWorldToHClip (TransformObjectToWorld (vertex));
                o.uv = uv * _Density;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half2 c = i.uv;
                c = floor(c) / 2 ; 
                float checker = frac(c.x + c.y) * 2;
                return checker;
            }
            ENDHLSL
        }
    }
}
