Shader "Unlit/More Textures"
{
    Properties
    {
       [NoScaleOffset]_BaseMap("Texture2D", 2D) = "white" {}
       _OcclusionMap("Occlusion", 2D) = "white" {}
       _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0 //!important note: This parameter makes the occlusion works
       _BumpMap("Normal Map", 2D) = "bump" {}
       _BumpScale ("Normal Scale", Range (0.0,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _NORMALMAP ON
            #pragma shader_feature BUMP_SCALE_NOT_SUPPORTED
            #pragma shader_feature _OCCLUSIONMAP ON
            
            #include "Packages/com.unity.render-pipelines.universal/Shaders/litInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 vertex       : POSITION;
                float3 normal       : NORMAL;
                float4 tangent      : TANGENT;
                float2 uv           : TEXCOORD0;
            };
            
            struct Varyings
            {
                half3 worldPos  : TEXCOORD0;
                half3 tspace0   : TEXCOORD1;
                half3 tspace1   : TEXCOORD2; 
                half3 tspace2   : TEXCOORD3; 
                float2 uv       : TEXCOORD4;
                float4 pos      : SV_POSITION;
            };
            
            Varyings vert(Attributes v)
            {
                Varyings o;
                o.pos = GetVertexPositionInputs(v.vertex.xyz).positionCS;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normal, v.tangent);
                half3 wNormal = normalInputs.normalWS;
                half3 wTangent = normalInputs.tangentWS;
  
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(Varyings i) : SV_Target
            {
                half3 tnormal = SampleNormal(i.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap),_BumpScale);

                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);
                
                half3 worldViewDir = normalize(GetCameraPositionWS().xyz - i.worldPos);
                half3 worldRefl = reflect(-worldViewDir, worldNormal);
                half4 skyData = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, worldRefl, 0);
                half3 skyColor = DecodeHDREnvironment(skyData, unity_SpecCube0_HDR);
                  
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                half occlusion = SampleOcclusion(i.uv);
                  
                half4 c = 1;
                c.rgb = skyColor;
                c.rgb *= baseColor;
                c.rgb *= occlusion;
                
                return c;
            }
            
            ENDHLSL
        }
    }
}
