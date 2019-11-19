Shader "Unlit/SkyReflection Per Pixel Bump"
{
    Properties 
    {
        // normal map texture on the material,
        // default to dummy "flat surface" normalmap
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range (0.0,1.0)) = 0.5
    }
    
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline"}
        
        Pass
        {
            HLSLPROGRAM
            #pragma shader_feature _NORMALMAP ON
            #pragma shader_feature BUMP_SCALE_NOT_SUPPORTED 
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Varyings
            {
                half3 worldPos  : TEXCOORD0;
                // these three vectors will hold a 3x3 rotation matrix
                // that transforms from tangent to world space
                half3 tspace0   : TEXCOORD1; // tangent.x, bitangent.x, normal.x
                half3 tspace1   : TEXCOORD2; // tangent.y, bitangent.y, normal.y
                half3 tspace2   : TEXCOORD3; // tangent.z, bitangent.z, normal.z
                // texture coordinate for the normal map
                float2 uv       : TEXCOORD4;
                float4 pos      : SV_POSITION;
            };
            
            Varyings vert (float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
            {
                Varyings o;
                o.pos = GetVertexPositionInputs(vertex.xyz).positionCS;
                o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;
                
                VertexNormalInputs normalInputs = GetVertexNormalInputs(normal, tangent);
                half3 wNormal = normalInputs.normalWS;
                half3 wTangent = normalInputs.tangentWS;
  
                // compute bitangent from cross product of normal and tangent
                half tangentSign = tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.uv = uv;
                return o;
            }
            
            half _BumpScale;
            
            half4 frag(Varyings i) : SV_Target
            {
                /*half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv); 
                half3 tnormal;
                #if BUMP_SCALE_NOT_SUPPORTED
                    tnormal = UnpackNormal(n);
                #else
                    tnormal = UnpackNormalScale(n, _BumpScale);
                #endif*/
                
                half3 tnormal = SampleNormal(i.uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap),_BumpScale);
                // transform normal from tangent to world space
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);
                
                half3 worldViewDir = normalize(GetCameraPositionWS().xyz - i.worldPos);
                half3 worldRefl = reflect(-worldViewDir, worldNormal);
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