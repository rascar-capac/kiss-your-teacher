Shader "Onanagro/LP_Waves"
{
	Properties
	{
		// base water
		_Color("Color", Color) = (1,0,0,1)
		_SpecColor("Specular Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 1.0
		_WaveLength("Wave length", Float) = 0.5
		_WaveHeight("Wave height", Float) = 0.5
		_WaveSpeed("Wave speed", Float) = 1.0
		_RandomHeight("Random height", Float) = 0.5
		_RandomSpeed("Random Speed", Float) = 0.5
		// Foam
		_Tint("Tint", Color) = (1,1,1,1)
		_Foam("Foamline Thickness", Range(0, 3)) = 0.5
		// Ripples
		 [Toggle(ENABLE_RIPPLES)]
		_EnableRipples("Enable Ripples Global variables", Range(0, 1)) = 0
			// Reflection
			_ReflectionTex("Reflection Texture", 2D) = "" {}
			_ReflectionStrength("Reflection Strength", Range(0,1)) = .5
	}

		SubShader
			{
				Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
				LOD 100
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha
				Cull Off

				GrabPass
				{
					Name "BASE"
					Tags{ "LightMode" = "Always" }
				}

				Pass
				{
					CGPROGRAM
					#include "UnityCG.cginc"
					#pragma vertex vert
					#pragma geometry geom
					#pragma fragment frag
					// make fog work
					#pragma multi_compile_fog
					#pragma shader_feature ENABLE_RIPPLES

					float rand(float3 co)
					{
						return frac(sin(dot(co.xyz ,float3(12.9898,78.233,45.5432))) * 43758.5453);
					}

					float rand2(float3 co)
					{
						return frac(sin(dot(co.xyz ,float3(19.9128,75.2,34.5122))) * 12765.5213);
					}

					// Foam
					float4 _Tint;
					uniform sampler2D _CameraDepthTexture; //Depth Texture
					float _Foam;

					sampler2D _ReflectionTex;

					// Ripples
					//bool _EnableRipples;
					uniform float3 _Position;
					uniform sampler2D _GlobalEffectRT;
					uniform float _OrthographicCamSize;

					// Triangle water & waves
					float _WaveLength;
					float _WaveHeight;
					float _WaveSpeed;
					float _RandomHeight;
					float _RandomSpeed;

					uniform samplerCUBE _Cube;
					uniform float _ReflectionStrength;

					uniform float4 _LightColor0;

					uniform float4 _Color;
					uniform float4 _SpecColor;
					uniform float _Shininess;

					struct v2g
					{
						float4  pos : SV_POSITION;
						float3	norm : NORMAL;
						float2  uv : TEXCOORD0;
						half3 worldRefl : TEXCOORD1;
					};

					struct g2f
					{
						float4  pos : SV_POSITION;
						float3  norm : NORMAL;
						float2  uv : TEXCOORD0;
						float3 diffuseColor : TEXCOORD1;
						float3 specularColor : TEXCOORD2;
						//UNITY_FOG_COORDS(3)
						float4 scrPos : TEXCOORD3;
						float4 worldPos : TEXCOORD4;
						half3 worldRefl : TEXCOORD5;
					};

					v2g vert(appdata_full v, float3 normal : NORMAL)
					{
						//float3 v0 = mul(unity_ObjectToWorld, v.vertex).xyz;
						float3 v0 = v.vertex.xyz;

						float phase0 = (_WaveHeight)* sin((_Time[1] * _WaveSpeed) + (v0.x * _WaveLength) + (v0.z * _WaveLength) + rand2(v0.xzz));
						float phase0_1 = (_RandomHeight)*sin(cos(rand(v0.xzz) * _RandomHeight * cos(_Time[1] * _RandomSpeed * sin(rand(v0.xxz)))));

						v0.y += phase0 + phase0_1;

						//v.vertex.xyz = mul((float3x3)unity_WorldToObject, v0);
						v.vertex.xyz = v0;

						// world space normal
						//float3 worldNormal = UnityObjectToWorldNormal(normal);
						float3 worldNormal = normal;

						v2g OUT;
						OUT.pos = v.vertex;
						OUT.norm = v.normal;
						OUT.uv = v.texcoord;
						//UNITY_TRANSFER_FOG(OUT, OUT.pos);
						OUT.worldRefl = reflect(-normalize(UnityWorldSpaceViewDir(OUT.pos.xyz)), worldNormal);
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

						float3 diffuseReflection = attenuation * _LightColor0.rgb
													* _Color.rgb
													* max(0.0, dot(normalDirection, lightDirection));

						float3 specularReflection;

						if (dot(normalDirection, lightDirection) < 0.0)
						{
							specularReflection = float3(0.0, 0.0, 0.0);
						}
						else
						{
							specularReflection = attenuation * _LightColor0.rgb
												* _SpecColor.rgb * pow(max(0.0, dot(
													reflect(-lightDirection, normalDirection),
													viewDirection)), _Shininess);
						}

						float3 worldReflection = attenuation * _LightColor0.rgb
													* _Color.rgb
													* max(0.0, dot(normalDirection, lightDirection));



						g2f OUT;
						OUT.pos = UnityObjectToClipPos(IN[0].pos);
						OUT.norm = vn;
						OUT.uv = IN[0].uv;
						OUT.diffuseColor = ambientLighting + diffuseReflection;
						OUT.specularColor = specularReflection;
						OUT.scrPos = ComputeScreenPos(OUT.pos);
						OUT.worldPos = mul(unity_ObjectToWorld, IN[0].pos);
						OUT.worldRefl = IN[0].worldRefl + worldReflection;
						triStream.Append(OUT);

						OUT.pos = UnityObjectToClipPos(IN[1].pos);
						OUT.norm = vn;
						OUT.uv = IN[1].uv;
						OUT.diffuseColor = ambientLighting + diffuseReflection;
						OUT.specularColor = specularReflection;
						OUT.scrPos = ComputeScreenPos(OUT.pos);
						OUT.worldPos = mul(unity_ObjectToWorld, IN[1].pos);
						OUT.worldRefl = IN[1].worldRefl + worldReflection;
						triStream.Append(OUT);

						OUT.pos = UnityObjectToClipPos(IN[2].pos);
						OUT.norm = vn;
						OUT.uv = IN[2].uv;
						OUT.diffuseColor = ambientLighting + diffuseReflection;
						OUT.specularColor = specularReflection;
						OUT.scrPos = ComputeScreenPos(OUT.pos);
						OUT.worldPos = mul(unity_ObjectToWorld, IN[2].pos);
						OUT.worldRefl = IN[2].worldRefl + worldReflection;
						triStream.Append(OUT);

					}

					half4 frag(g2f IN) : SV_Target
					{
						// sample the default reflection cubemap, using the reflection vector
						half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.worldRefl);
						// decode cubemap data into actual color
						half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
						// output it!
						float4 c = 0;
						c.rgb = skyColor;

						 float4 finalColor = texCUBE(_Cube, IN.scrPos);
						 //finalColor.w *= _ReflectionStrength;

						 //float2 texUV = IN.worldPos.xz;
						 //float3 texCol = tex2D(_ReflectionTex, texUV);

						half4 col = float4(IN.diffuseColor + lerp(IN.specularColor, c, _ReflectionStrength), _Color.a);
						//half4 col = float4(IN.diffuseColor + lerp(IN.specularColor, texCol , _ReflectionStrength), _Color.a);

						half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.scrPos))); // depth
						half4 foamLine = 1 - saturate(_Foam * (depth - IN.scrPos.w));// foam line by comparing depth and screenposition

						col += foamLine * _Tint;

		#ifdef ENABLE_RIPPLES

						// rendertexture UV
						float2 uv = IN.worldPos.xz - _Position.xz;
						uv = uv / (_OrthographicCamSize * 2);
						uv += 0.5;

						// Ripples
						float ripples = tex2D(_GlobalEffectRT, uv).b;

						ripples = step(0.99, ripples * 3);
						float4 ripplesColored = ripples * _Tint;

						col = saturate(col + ripplesColored);
		#endif
						return col;
					}
					ENDCG

				}
			}
}