Shader "Unlit/SkyReflection"
{
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline"}
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            
            struct Varyings
            {
                half3 worldRefl             : TEXCOORD0;
                float4 pos                  : SV_POSITION;
            };
            
            Varyings vert (float4 vertex : POSITION, float3 normal : NORMAL)
            {
                Varyings o;
                o.pos = GetVertexPositionInputs(vertex.xyz).positionCS;
                // compute world space position of the vertex
                float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;
                // compute world space view direction
                float3 worldViewDir = normalize(GetCameraPositionWS().xyz - worldPos);
                // world space normal
               float3 worldNormal = TransformObjectToWorldNormal(normal);
                // world space reflection vector
                o.worldRefl = reflect(-worldViewDir, worldNormal);
                return o;
            }
            
            half4 frag(Varyings i) : SV_Target
            {
                // sample the default reflection cubemap, using the reflection vector
                half4 skyData = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, i.worldRefl, 0);
                // decode cubemap data into actual color
                half3 skyColor = DecodeHDREnvironment(skyData, unity_SpecCube0_HDR);
                // output it!
                half4 c = 0;
                c.rgb = skyColor;
                return c; 
            }
            ENDHLSL
        }
    }
}