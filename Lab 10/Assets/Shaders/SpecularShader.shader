// SpecularShader.shader
Shader "Custom/SpecularShader" { // Basic shader for Lab 10
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_SpecColour("Specular Color", Color) = (1,1,1,1)
    _Shininess("Shininess", float) = 10
	}
	SubShader {
		Pass{
			
			CGPROGRAM
			#pragma vertex vertexFunction
			#pragma fragment fragmentFunction
			
			//user defined variables
			uniform float4 _Color;
			uniform float4 _SpecColour;
			uniform float _Shininess;
			
			//unity defined variables
			uniform float4 _LightColor0;
						
			//input struct
			struct inputStruct
			{
				float4 vertexPos : POSITION;
				float3 vertexNormal : NORMAL;
								
			};
			
			//output struct
			struct outputStruct
			{
				float4 pixelPos: SV_POSITION;
				float4 pixelCol : COLOR;
			};
			
			//vertex program
			outputStruct vertexFunction(inputStruct input)
			{
				outputStruct toReturn;
				float3 lightDirection;
				float attenuation = 1.0;

				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				
				float3 normalDirection = normalize(mul(float4(input.vertexNormal, 0.0), _Object2World).xyz);
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) -
																mul(_Object2World, input.vertexPos).xyz));
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				float3 specularReflection = reflect(-lightDirection, normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = max(0.0, specularReflection);
				specularReflection = max(0.0, dot(normalDirection, lightDirection)) * specularReflection;
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(normalDirection, lightDirection)) * specularReflection;
				float3 finalLight = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT;

				toReturn.pixelCol = float4(finalLight * _Color, 1.0);
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
