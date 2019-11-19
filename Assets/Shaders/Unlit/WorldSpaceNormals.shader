Shader "Unlit/WorldSpaceNormals"
{
    Properties
    {
        _ColorIntensitiy ("Color Intensitiy",Range(0.0,1.0)) = 0.5
        _ScrollColor ("Add",Range(0.0,1.0)) = 0.5
    }
    
    SubShader
    {
        
        Tags { "RenderPipeline"="UniversalPipeline"}
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            
            half _ColorIntensitiy;
            half _ScrollColor;
            
            struct Varyings
            {
                half3 worldNormal   : TEXCOORD0;
                float4 pos          : SV_POSITION;
            };
            
            Varyings vert(float4 vertex : POSITION, float3 normal : NORMAL)
            {
                Varyings o;   
                o.pos = TransformObjectToHClip(vertex.xyz);
                o.worldNormal = TransformObjectToWorldNormal(normal);
                return o;
            }
    
            half4 frag(Varyings i) : SV_Target
            {
                half4 c;        
                c.rbg = i.worldNormal * _ColorIntensitiy + _ScrollColor;
                return c;
            }
            
            ENDHLSL
        }
    }
}
