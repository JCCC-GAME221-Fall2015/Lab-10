Shader "Custom/SpecularLightShader" 
{
	Properties 
	{
		_Color("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_Shine("Shininess", float) = 10
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
			uniform float4 _Shine;
			
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
			};
			
			SpecularOutput SpecularVertexFunction(SpecularInput input)
			{
				SpecularOutput returnSpec;
				
				float3 lightDirection;
				float attenuation = 1.0;

				float3 normalDirection = normalize(mul(float4(input.vertexNormal, 0.0), _Object2World).xyz);
				
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - mul(_Object2World, input.vertexPos).xyz));				
				
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = attenuation * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection = reflect(lightDirection, normalDirection);
				
				returnSpec.pixelCol = float4(specularReflection, 1.0);
				returnSpec.pixelPos = mul(UNITY_MATRIX_MVP, input.vertexPos);
				
				
				return returnSpec;
			}
			
			float4 SpecularFragmentFunction(SpecularOutput input) : COLOR
			{
				return input.pixelCol;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
