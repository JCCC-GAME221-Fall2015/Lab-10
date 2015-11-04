Shader "Custom/SpecularShader" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
	}
	SubShader {
		Pass{
			
			CGPROGRAM
			#pragma vertex vertexFunction
			#pragma fragment fragmentFunction
			
			//user defined variables
			uniform float4 _Color;
			
			//unity defined variables
			
			//input struct
			struct inputStruct
			{
				float4 vertexPos : POSITION;
				
			};
			
			//output struct ?
			struct outputStruct
			{
				float4 pixelPos: SV_POSITION;
			};
			
			//vertex program
			outputStruct vertexFunction(inputStruct input)
			{
				outputStruct toReturn;
				
				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				return toReturn;
			}
			
			//fragment program
			float4 fragmentFunction(outputStruct input) : COLOR
			{
				return _Color;
			}
			

			ENDCG
		} 
	}
	
	//Fallback
	//FallBack "Diffuse"
}
