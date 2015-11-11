shader "Custom/SpecShader"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_SpecColour("Specular Color", Color) = (1,1,1,1)
		_Shininess("Specularity", float) = 10
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			
			//Pragmas
			#pragma vertex vertexFunction
			#pragma fragment fragmentFunction

			//User-Defined Variables
			uniform float4 _Color;
			uniform float4 _SpecColour;
			uniform float _Shininess;
			
			//Unity-Defined Variables
			uniform float4 _LightColor0;

			struct inputStruct
			{
				//Vertex Setup
				float4 vertexPos : POSITION;
				float3 vertexNormal : NORMAL;
			};

			struct outputStruct
			{
				//Pixel Setup
				float4 pixelPos: SV_POSITION;
				float4 pixelCol : COLOR;
				
				//Texture
				float3 normalDirection : TEXCOORD0;
				float4 pixelWorldPos : TEXCOORD1;
			};

			outputStruct vertexFunction(inputStruct input)
			{
				outputStruct toReturn;
				
				//Sets up Light
				float3 lightDir;
				float attenuation = 1.0;
				lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				//Sets up the view
				float3 normalDir = normalize(mul(float4(input.vertexNormal, 0.0), _World2Object).xyz);
				float3 viewDir = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) -
					mul(_Object2World, input.vertexPos).xyz));
				
				//Sets up Specularity
				float3 diffReflect = attenuation * _LightColor0.xyz * max(0.0, dot(normalDir, lightDir));
				float3 specReflect = reflect(-lightDir, normalDir);
				
				//More Specularity Setup
				specReflect = dot(specReflect, viewDir);
				specReflect = max(0.0, specReflect);
				specReflect = max(0.0, dot(normalDir, lightDir)) * specReflect;
				specReflect = pow(max(0.0, specReflect), _Shininess);
				
				//Final Light Setup
				float3 finalLight = specReflect * diffReflect + UNITY_LIGHTMODEL_AMBIENT;
				
				//Return Values				
				toReturn.pixelCol = float4(finalLight * _Color, 1.0);
				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
			
				return toReturn;
			}

			float4 fragmentFunction(outputStruct input) : COLOR
			{
				//Return Pixel Color
				return input.pixelCol;
			}
			
			ENDCG
		}
	}
	//FallBack "Diffuse"
}