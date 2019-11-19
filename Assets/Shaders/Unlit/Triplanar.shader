Shader "Unlit/Triplanar"
{
     Properties
    {
        _BaseMap ("Texture", 2D) = "white" {}
        _Tiling ("Tiling", Float) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}
        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _OCCLUSIONMAP ON
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            
            struct Varyings 
            {
                half3 normal    : TEXCOORD0;
                float3 coords   : TEXCOORD1;
                float2 uv       : TEXCOORD2;
                float4 vertex   : SV_POSITION;
            };
        
            half _Tiling;
            
            Varyings vert (float4 vertex : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0)
            {
                Varyings o;
                o.vertex = TransformWorldToHClip (TransformObjectToWorld (vertex));
                o.coords = vertex.xyz * _Tiling;
                o.normal = normal;
                o.uv = uv;
                return o;
            }
            
            half4 frag (Varyings i) : SV_Target
            {
                // use absolute value of normal as texture weights
                half3 blend = abs(i.normal);
                // make sure the weights sum up to 1 (divide by sum of x+y+z)
                blend /= dot(blend,1.0);
                // read the three texture projections, for x,y,z axes
                half4 cx = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.coords.yz);
                half4 cy = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.coords.xz);
                half4 cz = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.coords.xz);
                // blend the textures based on weights
                half4 c = cx * blend.x + cy * blend.y + cz * blend.z;
                // modulate by regular occlusion map
                c.rgb *= SampleOcclusion(i.uv);
                return c;
            }
            ENDHLSL
        }
    }
}