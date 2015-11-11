Shader "Custom/SpecularLightShaderII" 
{
	Properties 
	{
		_Color("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shininess("Shininess", float) = 10
	}
	
	SubShader 
	{		
		Pass
		{
			CGPROGRAM
			#pragma vertex SpecularVertexFunction
			#pragma fragment SpecularFragmentFunction
			
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _Shininess;
			
			uniform float4 _LightColor0;
			
			struct SpecularInput
			{
				float4 vertexPos : POSITION;
				float3 vertexNormal : NORMAL;
			};
			
			struct SpecularOutput
			{
				float4 pixelPos : SV_POSITION;
				float4 pixelCol : COLOR;
				float3 normalDirection : TEXCOORD0;
				float4 pixelWorldPos: TEXCOORD1;
			};
			
			SpecularOutput SpecularVertexFunction(SpecularInput input)
			{
				SpecularOutput returnSpec;
				
				float3 normalDirection = normalize(mul(float4(input.vertexNormal, 0.0), _Object2World).xyz);
				returnSpec.normalDirection = normalDirection;
				
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.vertexPos).xyz).xyz);	
				returnSpec.pixelWorldPos = float4(viewDirection, 1.0);	
				
				returnSpec.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				
				return returnSpec;
			}
			
			float4 SpecularFragmentFunction(SpecularOutput input) : COLOR
			{			
				float3 lightDirection;
				float attenuation = 1.0;

				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(input.normalDirection, lightDirection));
				
				float3 specularReflection = reflect(lightDirection, input.normalDirection); // Most likely source of error
				specularReflection = dot(specularReflection, input.pixelWorldPos.xyz);
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(input.normalDirection, lightDirection)) * specularReflection;
				
				float3 finalLight = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
				
				input.pixelCol = float4(finalLight * _Color, 1.0);
				
				return input.pixelCol * _SpecColor;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}

