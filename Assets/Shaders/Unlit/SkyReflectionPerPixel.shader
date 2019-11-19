Shader "Unlit/SkyReflection Per Pixel"
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
                half3 worldPos              : TEXCOORD0;
                half3 worldNormal           : TEXCOORD1;
                float4 pos                  : SV_POSITION;
            };
            
            Varyings vert (float4 vertex : POSITION, float3 normal : NORMAL)
            {
                Varyings o;
                o.pos = GetVertexPositionInputs(vertex.xyz).positionCS;
                o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
                o.worldNormal = TransformObjectToWorldNormal(normal);
                return o;
            }
            
            half4 frag(Varyings i) : SV_Target
            {
                // compute view direction and reflection vector
                // per-pixel here
                half3 worldViewDir = normalize(GetCameraPositionWS().xyz - i.worldPos);
                half3 worldRefl = reflect(-worldViewDir, i.worldNormal);
                half4 skyData = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, worldRefl, 0);
                half3 skyColor = DecodeHDREnvironment(skyData, unity_SpecCube0_HDR);
                  
                half4 c = 0;
                c.rgb = skyColor;
                return c; 
            }
            ENDHLSL
        }
    }
}