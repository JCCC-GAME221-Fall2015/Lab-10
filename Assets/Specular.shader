Shader "Custom/Specular" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_SpecColor("Specular color", Color) = (1,1,1,1)
		_Shininess("Shininess", float) = 10
		_Attenuation("Fall off", Range(0,5)) = 1 
	}
	SubShader {
	Tags{"LightMode"="ForwardBase"}
	Pass{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//user defined
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float  _Shininess;
			uniform	float _Attenuation;

			//unity
			uniform float4 _LightColor0;

			//input
			struct input{
				float4 vertexPos : POSITION;
				float3 vertexNormal : NORMAL;
			};

			struct v2f{
				float4 pixelPos : SV_POSITION;
				float4 pixelCol : COLOR;

				float3 normalDirection : TEXCOORD0;
				float4 pixelWorldPos : TEXCOORD1;
			};

			v2f vert(input i){
				v2f toReturn;

				//normal, view and light directions
				toReturn.normalDirection = normalize(mul(float4(i.vertexNormal, 0.0), _World2Object).xyz);
				toReturn.pixelWorldPos = mul(_Object2World, i.vertexPos);

				toReturn.pixelPos = mul(UNITY_MATRIX_MVP, i.vertexPos);
				return toReturn;
			}

			float4 frag(v2f i) : COLOR {
				//direction declarations
				float3 viewDirection = normalize(float3(float4(_WorldSpaceCameraPos.xyz, 1.0) - i.pixelWorldPos.xyz));
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				//reflections
				float3 diffuseReflection = _SpecColor * _Attenuation * _LightColor0.xyz * max(0.0, dot(i.normalDirection, lightDirection));
				float3 specularReflection = reflect(-lightDirection, i.normalDirection);
				specularReflection = dot(specularReflection, viewDirection);
				specularReflection = pow(max(0.0, specularReflection), _Shininess);
				specularReflection = max(0.0, dot(i.normalDirection, lightDirection)) * specularReflection;

				//final
				float3 finalLight = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT;

				i.pixelCol = float4(finalLight * _Color, 1.0);

				return i.pixelCol;
			}

		ENDCG
		} 
	}
	//FallBack "Diffuse"
}
