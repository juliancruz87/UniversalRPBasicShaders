Shader "Unlit/SingleColor"
{
    Properties
    {
       _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            //GetVertexPositionInputs is included here.
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            
            half4 _Color;
            struct Varyings
            {
                half4 vertex : SV_POSITION;
            };
            
            Varyings vert(half4 position : POSITION)
            {
                Varyings o;
                o.vertex = GetVertexPositionInputs(position.xyz).positionCS;
                return o;
            }
    
            half4 frag() : SV_Target
            {
                return _Color;
            }
            
            ENDHLSL
        }
    }
}
