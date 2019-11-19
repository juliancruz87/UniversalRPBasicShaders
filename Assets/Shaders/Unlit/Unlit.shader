Shader "Unlit/Unlit"
{
    Properties
    {
       [NoScaleOffset]_MainTex("Texture2D", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
        
        Pass
        {
            Name "Unlit"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            
            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex);  // funciton inside of UnlitInput.hlsl
            half4 _MainTex_ST;
            
            struct Attributes
            {
                float4 position         : POSITION;
                float2 uv               : TEXCOORD0;
            };
            
            struct Varyings
            {
                float2 uv               : TEXCOORD0;
                float4 vertex           : SV_POSITION;
            };
            
            Varyings vert(Attributes input)
            {
                /*struct VertexPositionInputs 
                {
                    float3 positionWS; // World space position
                    float3 positionVS; // View space position
                    float4 positionCS; // Homogeneous clip space position
                    float4 positionNDC;// Homogeneous normalized device coordinates
                };*/
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.position.xyz);
                output.vertex = vertexInput.positionCS;
                output.uv = input.uv; // if this isn't added Unity will crash. 
                return output;
            }
    
            half4 frag(Varyings input) : SV_Target
            {
                half2 uv = input.uv;
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                return texColor;
            }
            
            ENDHLSL
        }
    }
}
