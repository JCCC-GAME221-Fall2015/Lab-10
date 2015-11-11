Shader "Custom/SpecShader" {
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
			float3 lightDirection;
			float attenuation = 1.0;
			
			//Unity Defined Variables
			uniform float4 _LightColor0;
			
			//input struct
			struct inputStruct{
				float4 vertexPos : POSITION;
				float3 vertexNormal : NORMAL;
			};
			
			//output struct
			struct outputStruct{
				float4 pixelPos: SV_POSITION;
				float4 pixelCol : COLOR;
				
				float3 normalDirection : TEXCOORD0;
				float4 pixelWorldPos : TEXCOORD1;
			};
			
			//vertex function
			outputStruct vertexFunction(inputStruct input){
				outputStruct toReturn;
				
				float3 normalDirection = normalize(mul(float4(input.vertexNormal, 0.0), _World2Object).xyz);
				toReturn.normalDirection = normalDirection;
				toReturn.pixelWorldPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				
				return toReturn;
			}
			
			//fragment program
			float4 fragmentFunction(outputStruct input) : COLOR {
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.pixelPos).xyz));
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(input.normalDirection, lightDirection));
				float3 specularReflection = reflect(-lightDirection, input.normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(input.normalDirection, lightDirection)) * specularReflection;	
				float3 finalLight = (specularReflection * _SpecColour) + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT;
				input.pixelCol = float4(finalLight * _Color, 1.0);
				return input.pixelCol;
			}
			
			ENDCG
		}
	}
	//Fallback
	//FallBack "Diffuse"
}