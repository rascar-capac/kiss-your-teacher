Shader "Custom/LP_FlatSurface"
{
	Properties
	{
		// base water
		//_MainTex("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_SpecColor("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 1.0
		_LightColorInfluence("Light Color Influence", Range(0,1)) = 1
		_RandomHeight("Random height", Float) = 0.5
		_GeometryOffset("Geometry Offset", Float) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		GrabPass
		{
			Name "BASE"
			Tags{ "LightMode" = "Always" }
		}

		Pass{
			 CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

		float rand(float3 co)
		{
			return frac(sin(dot(co.xyz ,float3(12.9898,78.233,45.5432))) * 43758.5453);
		}

		float rand2(float3 co)
		{
			return frac(sin(dot(co.xyz ,float3(19.9128,75.2,34.5122))) * 12765.5213);
		}

		 // Use shader model 3.0 target, to get nicer looking lighting
		 #pragma target 3.0

		 sampler2D _MainTex;

		 struct Input
		 {
			 float2 uv_MainTex;
		 };

		 float _RandomHeight;
		 float _GeometryOffset;

		 uniform float4 _LightColor0;
		 float _LightColorInfluence;

		 uniform float4 _Color;
		 uniform float4 _SpecColor;
		 uniform float _Shininess;
		
		 struct v2g
		 {
			 float4  pos : SV_POSITION;
			 float3	norm : NORMAL;
			 float2  uv : TEXCOORD0;
		 };

		 struct g2f
		 {
			 float4  pos : SV_POSITION;
			 float3  norm : NORMAL;
			 float2  uv : TEXCOORD0;
			 float3 diffuseColor : TEXCOORD1;
			 float3 specularColor : TEXCOORD2;
		 };

		 v2g vert(appdata_full v, float3 normal : NORMAL)
		 {
			 //float3 v0 = mul(unity_ObjectToWorld, v.vertex).xyz;
			 float3 v0 =  v.vertex.xyz;

			 float phase0_1 = (_RandomHeight) * sin( cos( rand( v0.xzz ) * _RandomHeight * cos( sin( rand( v0.xxz ) ) ) ) );

			 v0.x += phase0_1 + _GeometryOffset;
			 v0.y += phase0_1 + _GeometryOffset;
			 v0.z += phase0_1 + _GeometryOffset;

			 //v.vertex.y = mul((float3x3)unity_WorldToObject, v0).y;
			 v.vertex.xyz = v0.xyz;

			 // world space normal
			 //float3 worldNormal = UnityObjectToWorldNormal(normal);
			 float3 worldNormal = normal;

			 v2g OUT;
			 OUT.pos = v.vertex;
			 OUT.norm = v.normal;
			 OUT.uv = v.texcoord;
			
			 return OUT;
		 }

		 [maxvertexcount(3)]
		 void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
		 {
			 float3 v0 = IN[0].pos.xyz;
			 float3 v1 = IN[1].pos.xyz;
			 float3 v2 = IN[2].pos.xyz;

			 float3 centerPos = (v0 + v1 + v2) / 3.0;

			 float3 vn = normalize(cross(v1 - v0, v2 - v0));

			 float4x4 modelMatrix = unity_ObjectToWorld;
			 float4x4 modelMatrixInverse = unity_WorldToObject;

			 float3 normalDirection = normalize(mul(float4(vn, 0.0), modelMatrixInverse).xyz);
			 float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, float4(centerPos, 0.0)).xyz);
			 float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			 float attenuation = 1.0;

			 float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

			 float3 diffuseReflection = attenuation 
				 * (_LightColor0.rgb + 1 - _LightColorInfluence)
				 * _Color.rgb
				 * max(0.0, dot(normalDirection, lightDirection));

			 float3 specularReflection;

			 if (dot(normalDirection, lightDirection) < 0.0)
			 {
				 specularReflection = float3(0.0, 0.0, 0.0);
			 }
			 else
			 {
				 specularReflection = attenuation
					 * (_LightColor0.rgb + 1 - _LightColorInfluence)
					 * _SpecColor.rgb * pow(max(0.0, dot(
						 reflect(-lightDirection, normalDirection),
						 viewDirection)), _Shininess);
			 }

			 float3 worldReflection = attenuation 
				 * (_LightColor0.rgb + 1 - _LightColorInfluence)
				 * _Color.rgb
				 * max(0.0, dot(normalDirection, lightDirection));

			 g2f OUT;
			 OUT.pos = UnityObjectToClipPos(IN[0].pos);
			 OUT.norm = vn;
			 OUT.uv = IN[0].uv;
			 OUT.diffuseColor = ambientLighting + diffuseReflection;
			 OUT.specularColor = specularReflection;
			 triStream.Append(OUT);

			 OUT.pos = UnityObjectToClipPos(IN[1].pos);
			 OUT.norm = vn;
			 OUT.uv = IN[1].uv;
			 OUT.diffuseColor = ambientLighting + diffuseReflection;
			 OUT.specularColor = specularReflection;
			 triStream.Append(OUT);

			 OUT.pos = UnityObjectToClipPos(IN[2].pos);
			 OUT.norm = vn;
			 OUT.uv = IN[2].uv;
			 OUT.diffuseColor = ambientLighting + diffuseReflection;
			 OUT.specularColor = specularReflection;
			 triStream.Append(OUT);

		 }

		 half4 frag(g2f IN) : SV_Target
		 {

			half4 col = float4( IN.diffuseColor + IN.specularColor, _Color.a);
	
			return col;
		 }

		 ENDCG
	}

	}
		FallBack "Diffuse"
}
