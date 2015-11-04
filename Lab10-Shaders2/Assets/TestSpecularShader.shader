Shader "Custom/TestSpecularShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", float) = 10
	}
	SubShader {
		Pass{
		
			CGPROGRAM
			#pragma vertex vertexFunction
			#pragma fragment fragmentFunction
			
			//userDefined variables
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _Shininess;
				//light color for the shader
			uniform float4 _LightColor0;
			
			//unity defined variables
			
			//input struct
			struct inputStruct
			{
				float4 vertexPos: POSITION;
				float3 vertexNormal : NORMAL;
				
			};
		
			//output struct
			struct outputStruct
			{
				float4 pixelPos: SV_POSITION;
				float4 pixelCol: COLOR;
			};
			
			//vertex program
			outputStruct vertexFunction(inputStruct input)
			{
				outputStruct toReturn;
				
				float3 normalDirection = normalize(mul(float4(input.vertexNormal,0.0), _World2Object).xyz);
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.vertexPos).xyz));
				
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float attenuation = 1.0;
				
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection = reflect(-lightDirection, normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = max(0.0, specularReflection);
				specularReflection = max(0.0, dot(normalDirection, lightDirection)) * specularReflection;
				
				toReturn.pixelCol = float4(specularReflection, 1.0);
				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				
				return toReturn;
			}
			
			//fragment program
			float4 fragmentFunction(outputStruct input) : COLOR
			{
				return input.pixelCol;
			}
			ENDCG
		}
	} 
	//Fallback
	//FallBack "Diffuse"
}
