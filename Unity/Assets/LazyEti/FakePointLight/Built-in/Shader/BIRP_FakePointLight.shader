// Made with Amplify Shader Editor v1.9.5.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LazyEti/BIRP/FakePointLight"
{
	Properties
	{
		[Header(___Light Settings___)][SingleLineTexture][Space(10)]_GradientTexture("GradientTexture", 2D) = "white" {}
		[HDR]_LightTint("Light Tint", Color) = (1,1,1,1)
		[Space(5)]_LightSoftness("Light Softness", Range( 0 , 1)) = 0.5
		_LightPosterize("Light Posterize", Range( 1 , 128)) = 1
		[Space(5)]_ShadingBlend("Shading Blend", Range( 0 , 1)) = 0.5
		_ShadingSoftness("Shading Softness", Range( 0.01 , 1)) = 0.5
		[Space(25)][Toggle(___HALO____ON)] ___Halo___("___Halo___", Float) = 1
		[HDR]_HaloTint("Halo Tint", Color) = (1,1,1,1)
		_HaloSize("Halo Size", Range( 0 , 5)) = 1
		_HaloPosterize("Halo Posterize", Range( 1 , 128)) = 1
		_HaloDepthFade("Halo Depth Fade", Range( 0.1 , 2)) = 0.5
		[Space(25)][Toggle]DistanceFade("___Distance Fade___", Float) = 0
		[Tooltip(Starts fading away at this distance from the camera)]_FarFade("Far Fade", Range( 0 , 400)) = 200
		_FarTransition("Far Transition", Range( 1 , 100)) = 50
		_CloseFade("Close Fade", Range( 0 , 50)) = 0
		_CloseTransition("Close Transition", Range( 0 , 50)) = 0
		[Space(25)][Toggle(___FLICKERING____ON)] ___Flickering___("___Flickering___", Float) = 0
		_FlickerIntensity("Flicker Intensity", Range( 0.1 , 1)) = 0.5
		_FlickerSpeed("Flicker Speed", Range( 0.01 , 5)) = 1
		_FlickerSoftness("Flicker Softness", Range( 0 , 1)) = 0.5
		_SizeFlickering("Size Flickering", Range( 0 , 0.5)) = 0.1
		[HideInInspector]_randomOffset("randomOffset", Range( 0 , 1)) = 0
		[Space(25)][Toggle(___NOISE____ON)] ___Noise___("___Noise___", Float) = 0
		[SingleLineTexture]_NoiseTexture("Noise Texture", 2D) = "black" {}
		_Noisiness("Noisiness", Range( 0 , 2)) = 0
		_NoiseScale("Noise Scale", Range( 0.1 , 2)) = 1
		_NoiseMovement("Noise Movement", Range( 0 , 1)) = 0
		[Space(20)][Header(___Extra Settings___)][Space(10)][Toggle(_PARTICLEMODE_ON)] _ParticleMode("Particle Mode", Float) = 0
		[Space(15)][Toggle]DayAlpha("Day Alpha", Float) = 0
		[Space (15)][Toggle(_SHADOWSHEAVY_ON)] _ShadowsHEAVY("Shadows (HEAVY)", Float) = 0
		_StepsSpacing("Steps Spacing", Range( 1 , 5)) = 3

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Overlay" "Queue"="Overlay" }
	LOD 100

		CGINCLUDE
		#pragma target 3.5
		ENDCG
		Blend SrcAlpha One, SrcAlpha One
		AlphaToMask On
		Cull Front
		ColorMask RGBA
		ZWrite On
		ZTest Always
		Offset 1000 , 2000
		
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#define ASE_USING_SAMPLING_MACROS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _PARTICLEMODE_ON
			#pragma shader_feature_local ___FLICKERING____ON
			#pragma shader_feature_local ___NOISE____ON
			#pragma shader_feature_local _SHADOWSHEAVY_ON
			#pragma shader_feature_local ___HALO____ON
			#ifdef STEREO_INSTANCING_ON
			UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_CameraDepthNormalsTexture);
			#else
			UNITY_DECLARE_TEX2D_NOSAMPLER(_CameraDepthNormalsTexture);
			#endif
			SamplerState sampler_CameraDepthNormalsTexture;
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
			#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex.SampleBias(samplerTex,coord,bias)
			#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex.SampleGrad(samplerTex,coord,ddx,ddy)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
			#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex2Dbias(tex,float4(coord,0,bias))
			#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex2Dgrad(tex,coord,ddx,ddy)
			#endif//ASE Sampling Macros
			


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float _LightSoftness;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _FlickerSpeed;
			uniform float _randomOffset;
			uniform float _FlickerSoftness;
			uniform float _FlickerIntensity;
			uniform float _SizeFlickering;
			uniform float _Noisiness;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_NoiseTexture);
			uniform float _NoiseMovement;
			uniform float _NoiseScale;
			SamplerState sampler_NoiseTexture;
			uniform float _LightPosterize;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_GradientTexture);
			SamplerState sampler_GradientTexture;
			uniform float4 _LightTint;
			uniform float _ShadingBlend;
			uniform float _ShadingSoftness;
			uniform float _StepsSpacing;
			uniform float _HaloSize;
			uniform float _HaloPosterize;
			uniform float4 _HaloTint;
			uniform float _HaloDepthFade;
			uniform float DayAlpha;
			uniform float DistanceFade;
			uniform float _FarFade;
			uniform float _FarTransition;
			uniform float _CloseFade;
			uniform float _CloseTransition;
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g755( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
				return result;
			}
			
			float4x4 Inverse4x4(float4x4 input)
			{
				#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
				float4x4 cofactors = float4x4(
				minor( _22_23_24, _32_33_34, _42_43_44 ),
				-minor( _21_23_24, _31_33_34, _41_43_44 ),
				minor( _21_22_24, _31_32_34, _41_42_44 ),
				-minor( _21_22_23, _31_32_33, _41_42_43 ),
			
				-minor( _12_13_14, _32_33_34, _42_43_44 ),
				minor( _11_13_14, _31_33_34, _41_43_44 ),
				-minor( _11_12_14, _31_32_34, _41_42_44 ),
				minor( _11_12_13, _31_32_33, _41_42_43 ),
			
				minor( _12_13_14, _22_23_24, _42_43_44 ),
				-minor( _11_13_14, _21_23_24, _41_43_44 ),
				minor( _11_12_14, _21_22_24, _41_42_44 ),
				-minor( _11_12_13, _21_22_23, _41_42_43 ),
			
				-minor( _12_13_14, _22_23_24, _32_33_34 ),
				minor( _11_13_14, _21_23_24, _31_33_34 ),
				-minor( _11_12_14, _21_22_24, _31_32_34 ),
				minor( _11_12_13, _21_22_23, _31_32_33 ));
				#undef minor
				return transpose( cofactors ) / determinant( input );
			}
			
			float noise58_g757( float x )
			{
				float n = sin (2 * x) + sin(3.14159265 * x);
				return n;
			}
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			float4 NormalTex2041( float2 uvs )
			{
				#ifdef STEREO_INSTANCING_ON
				return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthNormalsTexture,uvs);
				#else
				return SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture,sampler_CameraDepthNormalsTexture,uvs);
				#endif
			}
			
			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}
			
			float ExperimentalScreenShadowsBIRP223_g760( float3 _LightPos, float3 _ScreenPos, float _Spacing )
			{
				float3 lightPos = _LightPos;
				float3 _screenPos = _ScreenPos;
				float depth = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, _screenPos.xy );
				depth = 1/(_ZBufferParams.z * depth + _ZBufferParams.w);
				_screenPos.z = depth ;
				    float3 ray = ( lightPos )/ (400 / _Spacing);
				    half dist = distance(lightPos.xy,.5f );
				     if (depth>lightPos.z && dist <= 5)
				     {
				         for (int i = 0;i < 20 ;i++)
				         {                    
				            	float3 _newPos = _screenPos + (ray * i);
					float _d = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture ,_newPos.xy );
					_d = 1/(_ZBufferParams.z * _d + _ZBufferParams.w);
					float dif =  _newPos.z - _d;
				            if ( dif < 20 && dif > 0)  return 0;
				         }
				     }
				    return 1;
			}
			
			half3 HSVToRGB( half3 c )
			{
				half4 K = half4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				half3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, float4( (v.vertex).xyz, 1 )).xyz;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(ase_worldPos);
				float3 vertexToFrag7_g763 = worldSpaceLightDir;
				o.ase_texcoord4.xyz = vertexToFrag7_g763;
				
				o.ase_texcoord2 = v.ase_texcoord;
				o.ase_texcoord3.xyz = v.ase_texcoord1.xyz;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float temp_output_767_0 = ( ( 1.0 - _LightSoftness ) + -0.5 );
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g756 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g756 = UnStereo( UV22_g756 );
				float2 break64_g755 = localUnStereo22_g756;
				float clampDepth69_g755 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g755 = ( 1.0 - clampDepth69_g755 );
				#else
				float staticSwitch38_g755 = clampDepth69_g755;
				#endif
				float3 appendResult39_g755 = (float3(break64_g755.x , break64_g755.y , staticSwitch38_g755));
				float4 appendResult42_g755 = (float4((appendResult39_g755*2.0 + -1.0) , 1.0));
				float4 temp_output_43_0_g755 = mul( unity_CameraInvProjection, appendResult42_g755 );
				float3 temp_output_46_0_g755 = ( (temp_output_43_0_g755).xyz / (temp_output_43_0_g755).w );
				float3 In72_g755 = temp_output_46_0_g755;
				float3 localInvertDepthDir72_g755 = InvertDepthDir72_g755( In72_g755 );
				float4 appendResult49_g755 = (float4(localInvertDepthDir72_g755 , 1.0));
				float eyeDepth6_g754 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4x4 invertVal29_g754 = Inverse4x4( UNITY_MATRIX_M );
				float dotResult4_g754 = dot( ase_worldViewDir , -mul( UNITY_MATRIX_M, float4( (transpose( mul( invertVal29_g754, UNITY_MATRIX_I_V ) )[2]).xyz , 0.0 ) ).xyz );
				float3 temp_output_9_0_g754 = ( ( eyeDepth6_g754 * ( ase_worldViewDir / dotResult4_g754 ) ) + _WorldSpaceCameraPos );
				float3 ifLocalVar62_g754 = 0;
				if( unity_OrthoParams.w <= 0.0 )
				ifLocalVar62_g754 = temp_output_9_0_g754;
				else
				ifLocalVar62_g754 = (mul( unity_CameraToWorld, appendResult49_g755 )).xyz;
				float3 ReconstructedPos539 = ifLocalVar62_g754;
				float3 worldToObj263 = mul( unity_WorldToObject, float4( ReconstructedPos539, 1 ) ).xyz;
				float3 worldToObj137 = mul( unity_WorldToObject, float4( ( ReconstructedPos539 - i.ase_texcoord2.xyz ), 1 ) ).xyz;
				float3 ParticlePos653 = worldToObj137;
				float3 ase_parentObjectScale = ( 1.0 / float3( length( unity_WorldToObject[ 0 ].xyz ), length( unity_WorldToObject[ 1 ].xyz ), length( unity_WorldToObject[ 2 ].xyz ) ) );
				#ifdef _PARTICLEMODE_ON
				float3 staticSwitch255 = ( ParticlePos653 / ( i.ase_texcoord3.xyz + ase_parentObjectScale ) );
				#else
				float3 staticSwitch255 = worldToObj263;
				#endif
				float mulTime17_g757 = _Time.y * ( _FlickerSpeed * 4 );
				#ifdef _PARTICLEMODE_ON
				float staticSwitch1913 = i.ase_texcoord2.w;
				#else
				float staticSwitch1913 = _randomOffset;
				#endif
				float x58_g757 = ( mulTime17_g757 + ( staticSwitch1913 * UNITY_PI ) );
				float localnoise58_g757 = noise58_g757( x58_g757 );
				float temp_output_44_0_g757 = ( ( 1.0 - _FlickerSoftness ) * 0.5 );
				#ifdef ___FLICKERING____ON
				float staticSwitch53_g757 = saturate( (( 1.0 - _FlickerIntensity ) + ((0.0 + (localnoise58_g757 - -2.0) * (1.0 - 0.0) / (2.0 - -2.0)) - ( 1.0 - temp_output_44_0_g757 )) * (1.0 - ( 1.0 - _FlickerIntensity )) / (temp_output_44_0_g757 - ( 1.0 - temp_output_44_0_g757 ))) );
				#else
				float staticSwitch53_g757 = 1.0;
				#endif
				float FlickerAlpha416 = staticSwitch53_g757;
				float FlickerSize477 = (( 1.0 - _SizeFlickering ) + (FlickerAlpha416 - 0.0) * (1.0 - ( 1.0 - _SizeFlickering )) / (1.0 - 0.0));
				float temp_output_2062_0 = ( length( ( staticSwitch255 / ( 0.45 * FlickerSize477 ) ) ) * 1.1 );
				float mulTime41_g759 = _Time.y * ( _NoiseMovement * 0.2 );
				float3 objToWorld506 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
				float3 temp_output_8_0_g759 = ( ( ReconstructedPos539 - objToWorld506 ) * ( _NoiseScale * 0.1 ) );
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 uvs2041 = ase_grabScreenPosNorm.xy;
				float4 localNormalTex2041 = NormalTex2041( uvs2041 );
				float3 decodeViewNormalStereo2160 = DecodeViewNormalStereo( localNormalTex2041 );
				float3 viewToWorldDir2025 = ASESafeNormalize( mul( UNITY_MATRIX_I_V, float4( decodeViewNormalStereo2160, 0 ) ).xyz );
				float3 worldNormals1927 = viewToWorldDir2025;
				float3 temp_output_24_0_g759 = abs( round( worldNormals1927 ) );
				float temp_output_22_0_g759 = (temp_output_24_0_g759).x;
				float2 lerpResult19_g759 = lerp( (( ( float3(0.78,0.9,-0.72) * mulTime41_g759 ) + temp_output_8_0_g759 )).xz , (( ( float3(0.78,0.9,-0.72) * mulTime41_g759 ) + temp_output_8_0_g759 )).yz , temp_output_22_0_g759);
				float temp_output_23_0_g759 = (temp_output_24_0_g759).z;
				float2 lerpResult20_g759 = lerp( lerpResult19_g759 , (( ( float3(0.78,0.9,-0.72) * mulTime41_g759 ) + temp_output_8_0_g759 )).xy , temp_output_23_0_g759);
				float2 lerpResult46_g759 = lerp( (( ( mulTime41_g759 * float3(-0.86,-0.6,0.82) ) + temp_output_8_0_g759 )).xz , (( ( mulTime41_g759 * float3(-0.86,-0.6,0.82) ) + temp_output_8_0_g759 )).yz , temp_output_22_0_g759);
				float2 lerpResult47_g759 = lerp( lerpResult46_g759 , (( ( mulTime41_g759 * float3(-0.86,-0.6,0.82) ) + temp_output_8_0_g759 )).xy , temp_output_23_0_g759);
				#ifdef ___NOISE____ON
				float staticSwitch853 = saturate( ( _Noisiness * SAMPLE_TEXTURE2D( _NoiseTexture, sampler_NoiseTexture, lerpResult20_g759 ).r * SAMPLE_TEXTURE2D( _NoiseTexture, sampler_NoiseTexture, lerpResult47_g759 ).r ) );
				#else
				float staticSwitch853 = 0.0;
				#endif
				float temp_output_514_0 = ( temp_output_2062_0 * ( temp_output_2062_0 + staticSwitch853 ) );
				float smoothstepResult745 = smoothstep( temp_output_767_0 , ( 1.0 - temp_output_767_0 ) , temp_output_514_0);
				float temp_output_5_0_g762 = ( 256.0 / _LightPosterize );
				float GradientMask555 = ( ( 1.0 - smoothstepResult745 ) * saturate( ( floor( ( ( 1.0 - smoothstepResult745 ) * temp_output_5_0_g762 ) ) / temp_output_5_0_g762 ) ) );
				float2 temp_cast_4 = (( 1.0 - GradientMask555 )).xx;
				float4 temp_output_200_0 = ( GradientMask555 * SAMPLE_TEXTURE2D( _GradientTexture, sampler_GradientTexture, temp_cast_4 ) * _LightTint * i.ase_color );
				float2 temp_cast_5 = (( 1.0 - GradientMask555 )).xx;
				float surfaceMask487 = step( temp_output_514_0 , 0.999 );
				float4 transform2094 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
				#ifdef _PARTICLEMODE_ON
				float3 staticSwitch566 = -ParticlePos653;
				#else
				float3 staticSwitch566 = ( (transform2094).xyz - ReconstructedPos539 );
				#endif
				float dotResult436 = dot( staticSwitch566 , worldNormals1927 );
				float4 transform1852 = mul(unity_WorldToObject,float4( i.ase_texcoord2.xyz , 0.0 ));
				#ifdef _PARTICLEMODE_ON
				float4 staticSwitch1850 = transform1852;
				#else
				float4 staticSwitch1850 = float4( 0,0,0,0 );
				#endif
				float4 unityObjectToClipPos237_g760 = UnityObjectToClipPos( staticSwitch1850.xyz );
				float4 worldToClip255_g760 = mul(UNITY_MATRIX_VP, float4(WorldPosition, 1.0));
				float4 worldToClip255_g760NDC = worldToClip255_g760/worldToClip255_g760.w;
				float2 appendResult161_g760 = (float2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
				float4 break29_g760 = ( ( unityObjectToClipPos237_g760 - worldToClip255_g760NDC ) * float4( appendResult161_g760, 0.0 , 0.0 ) );
				float2 appendResult14_g760 = (float2(break29_g760.x , ( -break29_g760.y * 2 )));
				float temp_output_13_0_g760 = -break29_g760.y;
				float3 appendResult44_g760 = (float3(appendResult14_g760 , ( temp_output_13_0_g760 > 0.0 ? -0.001 : temp_output_13_0_g760 )));
				float4 break206_g760 = ( float4( appendResult161_g760, 0.0 , 0.0 ) * ( ( unityObjectToClipPos237_g760 / unityObjectToClipPos237_g760.w ) - worldToClip255_g760NDC ) );
				float2 appendResult207_g760 = (float2(break206_g760.x , ( -break206_g760.y * 2 )));
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float eyeDepth210_g760 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float3 appendResult46_g760 = (float3(appendResult207_g760 , ( 5.0 * saturate( ( break206_g760.y + 0.3 ) ) * ( saturate( ( 1.0 - abs( ase_worldViewDir.y ) ) ) + 0.5 ) * ( 1.0 - eyeDepth210_g760 ) )));
				float3 temp_output_28_0_g760 = ( unity_OrthoParams.w > 0.0 ? appendResult44_g760 : appendResult46_g760 );
				float3 _LightPos223_g760 = temp_output_28_0_g760;
				float3 _ScreenPos223_g760 = ase_screenPosNorm.xyz;
				float _Spacing223_g760 = _StepsSpacing;
				float localExperimentalScreenShadowsBIRP223_g760 = ExperimentalScreenShadowsBIRP223_g760( _LightPos223_g760 , _ScreenPos223_g760 , _Spacing223_g760 );
				#ifdef _SHADOWSHEAVY_ON
				float staticSwitch7_g760 = localExperimentalScreenShadowsBIRP223_g760;
				#else
				float staticSwitch7_g760 = 1.0;
				#endif
				float ScreenSpaceShadows1881 = staticSwitch7_g760;
				float ifLocalVar862 = 0;
				if( 1.0 <= _ShadingBlend )
				ifLocalVar862 = 1.0;
				else
				ifLocalVar862 = saturate( ( ( pow( saturate( dotResult436 ) , _ShadingSoftness ) * ScreenSpaceShadows1881 ) + _ShadingBlend ) );
				float NormalsMasking552 = ifLocalVar862;
				#ifdef _PARTICLEMODE_ON
				float staticSwitch726 = ( i.ase_texcoord3.xyz.x * 0.1 );
				#else
				float staticSwitch726 = 1.0;
				#endif
				float4 transform620 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
				#ifdef _PARTICLEMODE_ON
				float4 staticSwitch730 = float4( i.ase_texcoord2.xyz , 0.0 );
				#else
				float4 staticSwitch730 = transform620;
				#endif
				float dotResult962 = dot( float4( ase_worldViewDir , 0.0 ) , ( float4( _WorldSpaceCameraPos , 0.0 ) - staticSwitch730 ) );
				float4 objectToClip584 = UnityObjectToClipPos(float3( 0,0,0 ));
				float4 objectToClip584NDC = objectToClip584/objectToClip584.w;
				float4 worldToClip716 = mul(UNITY_MATRIX_VP, float4(i.ase_texcoord2.xyz, 1.0));
				float4 worldToClip716NDC = worldToClip716/worldToClip716.w;
				#ifdef _PARTICLEMODE_ON
				float4 staticSwitch712 = worldToClip716NDC;
				#else
				float4 staticSwitch712 = objectToClip584NDC;
				#endif
				float4 worldToClip583 = mul(UNITY_MATRIX_VP, float4(WorldPosition, 1.0));
				float4 worldToClip583NDC = worldToClip583/worldToClip583.w;
				float2 appendResult1075 = (float2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
				float smoothstepResult593 = smoothstep( 0.0 , ( ( _HaloSize * ( 1.0 + ( unity_OrthoParams.w * 0.5 ) ) ) * FlickerSize477 * staticSwitch726 ) , ( dotResult962 > 0.0 ? length( ( ( (( staticSwitch712 - worldToClip583NDC )).xyw * float3( appendResult1075 ,  0.0 ) ) * ( unity_OrthoParams.w <= 0.0 ? ( distance( _WorldSpaceCameraPos , staticSwitch730.xyz ) / -UNITY_MATRIX_P[ 1 ][ 1 ] ) : unity_OrthoParams.x ) ) ) : 20.0 ));
				float HaloMask616 = ( 1.0 - smoothstepResult593 );
				float temp_output_5_0_g761 = ( 256.0 / _HaloPosterize );
				float HaloPosterized651 = ( HaloMask616 * saturate( ( floor( ( HaloMask616 * temp_output_5_0_g761 ) ) / temp_output_5_0_g761 ) ) );
				float2 temp_cast_16 = (( 1.0 - HaloPosterized651 )).xx;
				float4 temp_output_608_0 = ( HaloPosterized651 * SAMPLE_TEXTURE2D( _GradientTexture, sampler_GradientTexture, temp_cast_16 ) * _HaloTint * i.ase_color );
				float2 temp_cast_17 = (( 1.0 - HaloPosterized651 )).xx;
				float3 objToWorld2044 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
				#ifdef _PARTICLEMODE_ON
				float3 staticSwitch721 = i.ase_texcoord2.xyz;
				#else
				float3 staticSwitch721 = objToWorld2044;
				#endif
				float HaloPenetrationMask683 = saturate( pow( saturate( ( distance( ReconstructedPos539 , _WorldSpaceCameraPos ) - distance( _WorldSpaceCameraPos , staticSwitch721 ) ) ) , _HaloDepthFade ) );
				#ifdef ___HALO____ON
				float3 staticSwitch1971 = ( (temp_output_608_0).rgb * ( (temp_output_608_0).a * HaloMask616 * HaloPenetrationMask683 ) );
				#else
				float3 staticSwitch1971 = float3( 0,0,0 );
				#endif
				half3 hsvTorgb47_g757 = HSVToRGB( half3(radians( staticSwitch53_g757 ),1.0,1.0) );
				float3 lerpResult51_g757 = lerp( hsvTorgb47_g757 , float3( 1,1,1 ) , staticSwitch53_g757);
				float3 FlickerHue1892 = lerpResult51_g757;
				float3 vertexToFrag7_g763 = i.ase_texcoord4.xyz;
				float dotResult3_g763 = dot( -vertexToFrag7_g763 , float3( 0,1,0 ) );
				float4 transform1952 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
				#ifdef _PARTICLEMODE_ON
				float4 staticSwitch1917 = float4( i.ase_texcoord2.xyz , 0.0 );
				#else
				float4 staticSwitch1917 = transform1952;
				#endif
				float3 _Vector0 = float3(1,0,1);
				float Dist41_g764 = distance( ( staticSwitch1917.xyz * _Vector0 ) , ( _Vector0 * _WorldSpaceCameraPos ) );
				float4 appendResult2057 = (float4(( ( ( (temp_output_200_0).rgb * ( (temp_output_200_0).a * surfaceMask487 * NormalsMasking552 * 0.4 ) ) + staticSwitch1971 ) * FlickerHue1892 ) , ( (( DayAlpha )?( saturate( ( dotResult3_g763 * 4.0 ) ) ):( 1.0 )) * FlickerAlpha416 * (( DistanceFade )?( ( saturate( ( 1.0 - ( ( Dist41_g764 - _FarFade ) / _FarTransition ) ) ) * saturate( ( ( Dist41_g764 - _CloseFade ) / _CloseTransition ) ) ) ):( 1.0 )) )));
				
				
				finalColor = appendResult2057;
				return finalColor;
			}
			ENDCG
		}
	}
	
	
	Fallback Off
}
/*ASEBEGIN
Version=19501
Node;AmplifyShaderEditor.CommentaryNode;480;-1731.524,-1077.199;Inherit;False;1472.708;443.8386;;15;2062;55;420;478;680;264;711;255;262;263;654;261;260;259;539;World SphericalMask;0.9034846,0.5330188,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;484;-4352.669,-1078.827;Inherit;False;1617.816;369.3069;;10;742;1914;1913;466;1892;463;467;477;416;2060;Radius;0.5613208,0.8882713,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;2149;-1706.979,-1027.095;Inherit;False;Reconstruct World Pos from Depth VR;-1;;754;474d2b03c8647914986393f8dfbd9fe4;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;476;-2694.234,-1059.704;Inherit;False;909.0739;351.2957;;7;653;137;252;541;709;254;486;Particle transform;0.5424528,1,0.9184569,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;539;-1377.606,-1026.894;Inherit;False;ReconstructedPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;742;-4257.768,-911.8267;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1914;-4315.652,-979.697;Inherit;False;Property;_randomOffset;randomOffset;24;1;[HideInInspector];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;611;-4708.271,-128;Inherit;False;2751.38;492.5285;;23;591;1075;1074;589;585;587;583;712;582;716;584;717;962;961;964;621;2003;730;620;731;1300;586;623;Halo Position;0.4446237,0.4431373,0.8588235,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;-2650.645,-1016.229;Inherit;False;539;ReconstructedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;252;-2665.634,-904.9504;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;1913;-3989.652,-912.697;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2026;-4732.404,458.479;Inherit;False;1216.422;271.0526;Get Normals;5;1927;2025;2041;12;2160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;254;-2435.062,-972.353;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;463;-3587.511,-839.5694;Inherit;False;Property;_SizeFlickering;Size Flickering;23;0;Create;True;0;0;0;False;0;False;0.1;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2060;-3716.636,-985.2504;Inherit;False;FlickerFunction;18;;757;f6225b1ef66c663478bc4f0259ec00df;0;4;9;FLOAT;0;False;8;FLOAT;0;False;21;FLOAT;0;False;29;FLOAT;0;False;2;FLOAT;0;FLOAT3;45
Node;AmplifyShaderEditor.TexCoordVertexDataNode;717;-4659.074,96;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GrabScreenPosition;12;-4648.42,517.6443;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;137;-2270.084,-866.4276;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-3418.404,-985.4626;Inherit;False;FlickerAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;467;-3314.451,-838.9294;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;584;-4451.074,-48;Inherit;False;Object;Clip;True;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;716;-4451.074,96;Inherit;False;World;Clip;True;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;582;-4227.074,64;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;653;-2042.199,-865.5414;Inherit;False;ParticlePos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;466;-3164.095,-985.5343;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;259;-1407.874,-789.6442;Inherit;False;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;712;-4227.074,-48;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformPositionNode;583;-4051.075,64;Inherit;False;World;Clip;True;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;587;-3827.075,48;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;260;-1640.797,-813.7918;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;2041;-4437.687,517.7169;Float;False;#ifdef STEREO_INSTANCING_ON$return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthNormalsTexture,uvs)@$#else$return SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture,sampler_CameraDepthNormalsTexture,uvs)@$#endif;4;Create;1;True;uvs;FLOAT2;0,0;In;;Inherit;False;NormalTex;True;False;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;689;-1910.635,-96;Inherit;False;1707.476;518.5552;;20;2014;2009;2008;2010;2004;616;1294;593;648;656;726;737;738;594;722;2049;2050;2051;2052;2053;Halo Masking;1,0.6179246,0.9947789,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;477;-2978.031,-986.1696;Inherit;False;FlickerSize;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;261;-1211.053,-813.9485;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;654;-1271.828,-883.7238;Inherit;False;653;ParticlePos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;731;-3171.075,112;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;620;-3331.075,48;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;585;-3795.075,-48;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;589;-3651.075,73;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeViewNormalStereoHlpNode;2160;-4300.311,517.6641;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;513;-1582.23,-543.8651;Inherit;False;1290.465;351.589;;5;853;1929;542;506;505;Noise;1,0.6084906,0.6084906,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;263;-1147.08,-1027.044;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;262;-1048.119,-862.232;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;680;-909.8984,-914.6563;Inherit;False;Constant;_s;s;20;0;Create;True;0;0;0;False;0;False;0.45;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;478;-911.4405,-843.5002;Inherit;False;477;FlickerSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;730;-2963.075,48;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;1074;-3635.075,-48;Inherit;False;True;True;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OrthoParams;2050;-1887.904,104.975;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;1075;-3539.075,73;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformDirectionNode;2025;-4014.398,517.4789;Inherit;False;View;World;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;506;-1499.657,-371.927;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;255;-911.3533,-1026.605;Inherit;False;Property;_ParticleMode;Particle Mode;31;0;Create;True;0;0;0;False;3;Space(20);Header(___Extra Settings___);Space(10);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;-736.6204,-896.0656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;542;-1503.032,-443.7211;Inherit;False;539;ReconstructedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;2003;-2723.075,48;Inherit;False;PerspectiveScalingFunction;-1;;758;ae280d8cb1effe748857bbeed4caf0b3;0;1;9;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;621;-2931.075,176;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;-3411.075,-48;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2052;-1678.285,78.19335;Inherit;False;Constant;_Float4;Float 4;23;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;2051;-1679.677,153.2958;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;722;-1648.716,244.2001;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1927;-3771.398,517.4789;Inherit;False;worldNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;510;5.103966,-1080.573;Inherit;False;1051.51;320.2816;;9;771;745;765;66;769;767;487;485;514;Light Mask Hardness;1,0.8561655,0.3632075,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;505;-1255.966,-443.2927;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1929;-1089.745,-372.812;Inherit;False;1927;worldNormals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;264;-643.9969,-1025.174;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;623;-2419.075,-48;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;964;-2675.075,176;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;961;-2435.075,80;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;2049;-1441.388,201.1643;Inherit;False;Constant;_Float3;Float 3;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;738;-1444.616,268.4;Inherit;False;0.1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;-1692.116,5.800004;Inherit;False;Property;_HaloSize;Halo Size;9;1;[Header];Create;True;0;0;0;False;0;False;1;4.35;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2053;-1532.285,78.19335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2015;-866.6163,-468.5807;Inherit;False;3DNoiseMap;26;;759;2fca756491ec7bf4e9c71d18280c45cc;0;5;56;FLOAT;0;False;1;FLOAT3;0,0,0;False;21;FLOAT3;0,0,0;False;7;FLOAT;0;False;54;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;55;-535.5539,-1025.4;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;586;-2275.075,-48;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;42.73463,-868.8215;Inherit;False;Property;_LightSoftness;Light Softness;2;0;Create;True;0;0;0;False;1;Space(5);False;0.5;0.455;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;737;-1388.916,53.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;656;-1218.916,115.7;Inherit;False;477;FlickerSize;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;726;-1282.916,201.5999;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;962;-2252.075,151;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;442;-4174.457,-624;Inherit;False;2387.036;387.6452;Be sure to have a renderer feature that writes to _CameraNormalsTexture for this to work;20;2094;565;566;2109;438;655;552;862;863;551;562;1289;471;1882;550;549;563;436;2027;2110;Normal Direction Masking;0.6086246,0.5235849,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;853;-549.4682,-492.0063;Inherit;False;Property;___Noise___;___Noise___;25;0;Create;True;0;0;0;False;1;Space(25);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;2062;-400.5405,-1025.775;Inherit;False;1.1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;769;316.1792,-867.0805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;1300;-2099.076,-48;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;648;-978.2169,53.70005;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1356;-3422.513,461.0891;Inherit;False;1403.409;345.7733;Experimental screen shadows;4;1881;1850;1852;1851;;1,0.0518868,0.0518868,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;2094;-4127.636,-542.7913;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;509;-165.7451,-960.9916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;767;452.1794,-867.0805;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;593;-814.3171,-48;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;655;-3941.272,-394;Inherit;False;653;ParticlePos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1851;-3359.984,580.2638;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;2110;-3953.102,-542.6057;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;28.78838,-1027.972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;765;581.213,-870.0805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1294;-624.3171,-48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;565;-3957.262,-470;Inherit;False;539;ReconstructedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;753;-148.7889,-663.3845;Inherit;False;927.7325;257.7322;;5;651;752;754;643;642;HaloPosterize;0.4575472,0.7270408,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;682;-1896.036,499.5727;Inherit;False;1566.789;474.5671;;13;2046;683;2048;2047;2045;2044;721;675;667;637;636;635;720;Halo Penetration Fade;0.3773585,0.3773585,0.3773585,1;0;0
Node;AmplifyShaderEditor.NegateNode;2109;-3761.017,-394.3413;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;1852;-3119.984,580.2638;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;438;-3734.272,-543;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;-464,-48;Inherit;False;HaloMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;745;716.0555,-1029.319;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.04;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;500;872.3984,-667.6311;Inherit;False;989.2166;262.1571;;5;555;770;640;492;775;Light Posterize;0.5707547,1,0.9954711,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;566;-3563.272,-544;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1850;-2942.513,557.0894;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;2027;-3529.321,-447;Inherit;False;1927;worldNormals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;754;-48.70786,-603.0811;Inherit;False;616;HaloMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;643;-128,-512;Inherit;False;Property;_HaloPosterize;Halo Posterize;10;0;Create;True;0;0;0;False;0;False;1;1;1;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;2044;-1853.235,661.2757;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;720;-1851.573,801.4167;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;771;900.8933,-1028.466;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2059;-2683.386,557.0894;Inherit;False;ExperimentalScreenSpaceShadows;34;;760;79f826106fc5f154c96059cc1326b755;0;1;85;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;436;-3285.321,-544;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;775;1095.297,-605.5555;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;492;945.3987,-519.6932;Inherit;False;Property;_LightPosterize;Light Posterize;3;0;Create;True;0;0;0;False;0;False;1;50.4;1;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;642;144,-544;Inherit;False;SimplePosterize;-1;;761;163fbd1f7d6893e4ead4288913aedc26;0;2;9;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;635;-1551.573,569.4167;Inherit;False;539;ReconstructedPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;636;-1583.573,633.4167;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;721;-1583.573,777.4167;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;563;-3159.321,-544;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-3287.321,-448;Inherit;False;Property;_ShadingSoftness;Shading Softness;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1881;-2334.513,557.0894;Inherit;False;ScreenSpaceShadows;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;640;1232.082,-544.3308;Inherit;False;SimplePosterize;-1;;762;163fbd1f7d6893e4ead4288913aedc26;0;2;9;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;752;393.7577,-601.4481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;637;-1311.573,569.4167;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;667;-1311.573,681.4167;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;666;-172.3654,216.4607;Inherit;False;1781.457;432.7264;;13;1971;687;603;2054;686;685;617;608;481;650;649;669;652;Halo Mix;0,1,0.4267647,1;0;0
Node;AmplifyShaderEditor.PowerNode;550;-2999.321,-544;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1882;-2999.321,-448;Inherit;False;1881;ScreenSpaceShadows;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;770;1489.614,-606.1196;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;651;559.4694,-601.5095;Inherit;False;HaloPosterized;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;675;-1151.573,633.4167;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;684;-164.7677,-314.4586;Inherit;False;1670.703;440.3387;;13;141;143;2055;1976;553;488;202;200;140;201;607;707;557;Light Radius Mix;1,0.4198113,0.7623972,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1289;-2727.321,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;471;-2729.321,-443;Inherit;False;Property;_ShadingBlend;Shading Blend;4;0;Create;True;0;0;0;False;1;Space(5);False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;555;1637.652,-606.1025;Inherit;False;GradientMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;652;-156.3654,280.4608;Inherit;False;651;HaloPosterized;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;2045;-1010.396,633.7894;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2046;-1155.723,755.7162;Inherit;False;Property;_HaloDepthFade;Halo Depth Fade;11;0;Create;True;0;0;0;False;0;False;0.5;0;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;562;-2471.321,-544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;557;-116.7677,-250.4587;Inherit;False;555;GradientMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;2047;-852.1715,633.8682;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;669;53.20976,363.3625;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;863;-2359.321,-368;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;551;-2358.321,-544;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;649;467.6346,424.4609;Inherit;False;Property;_HaloTint;Halo Tint;8;1;[HDR];Create;True;1;___Halo___;0;0;False;0;False;1,1,1,1;2.484021,0.7022887,0,0.427451;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.VertexColorNode;650;675.6346,472.4609;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;2048;-707.3603,633.1129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;481;194.0595,339.4868;Inherit;True;Property;_GradientTexture;GradientTexture;0;2;[Header];[SingleLineTexture];Create;True;1;___Light Settings___;0;0;False;1;Space(10);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.OneMinusNode;707;92.23219,-163.4589;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;862;-2183.321,-464;Inherit;False;False;5;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;485;190.3592,-975.1706;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.999;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;607;235.2322,-186.4587;Inherit;True;Property;_ColorGradient;ColorGradient;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;481;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.VertexColorNode;201;715.2329,-58.45896;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;140;523.2328,-138.4589;Inherit;False;Property;_LightTint;Light Tint;1;1;[HDR];Create;True;1;___Light Settings___;0;0;False;0;False;1,1,1,1;2.118547,0.4788287,0,0.5254902;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;739.6346,280.4608;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;683;-572.5967,631.4382;Inherit;False;HaloPenetrationMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;552;-2007.323,-464;Inherit;False;NormalsMasking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;487;332.8367,-975.9942;Inherit;False;surfaceMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;811.2329,-250.4587;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;899.6346,424.4609;Inherit;False;616;HaloMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;685;867.6346,488.4608;Inherit;False;683;HaloPenetrationMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;686;900.6346,348.4608;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;2054;901.1951,280.5605;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;603;1125.635,348.4608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;202;955.2325,-181.4588;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;488;986.2322,-113.4589;Inherit;False;487;surfaceMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1976;986.2322,14.54076;Inherit;False;Constant;_intensityScale;intensityScale;20;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;553;954.2325,-49.45897;Inherit;False;552;NormalsMasking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;687;1267.635,280.4608;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;2055;955.8936,-249.5043;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;1178.232,-181.4588;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;1952;1248.188,723.303;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1916;1216.188,883.303;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1892;-3420.24,-915.9872;Inherit;False;FlickerHue;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1971;1408.135,256.5862;Inherit;False;Property;___Halo___;___Halo___;6;0;Create;True;0;0;0;False;1;Space(25);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;1351.232,-248.4587;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1917;1440.188,723.303;Inherit;False;Property;_ParticleMesh;ParticleMesh;31;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;255;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1384;1798.094,559.2362;Inherit;False;416;FlickerAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1977;1830.094,495.2361;Inherit;False;DayAlpha;32;;763;bc1f8ebe2e26696419e0099f8a3e27dc;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1988;1671.094,627.2362;Inherit;False;AdvancedCameraFade;12;;764;e6e830f789d28b746963801d61c2a1ec;0;6;40;FLOAT;0;False;46;FLOAT;0;False;47;FLOAT;0;False;48;FLOAT;0;False;17;FLOAT3;0,0,0;False;20;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;600;1663.325,232.2617;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1897;1834.026,297.5617;Inherit;False;1892;FlickerHue;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1901;1980.094,534.2362;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;657;2026.026,233.5617;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StickyNoteNode;486;-2248.26,-1019.167;Inherit;False;389.5999;134.3;Particle Custom Vertex stream setup !!;;1,0.9012449,0.3254717,1;1. Center = TexCoord0.xyz  (Particle Position)$$2. StableRandom.x TexCoord0.w (random flicker)$$3. Size.xyz = TexCoord1.xyz (Particle Size);0;0
Node;AmplifyShaderEditor.StickyNoteNode;709;-2676.301,-941.0137;Inherit;False;215;182;Center (Texcoord0.xyz);;1,1,1,1;;0;0
Node;AmplifyShaderEditor.StickyNoteNode;711;-1648.394,-848.5927;Inherit;False;208;181;Size.xyz (Texcoord1.xyz);;1,1,1,1;;0;0
Node;AmplifyShaderEditor.ObjectScaleNode;2004;-991.0323,263.4963;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMinOpNode;2010;-703.0322,311.4963;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;2008;-591.0323,311.4963;Inherit;False;0.1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;2009;-815.0322,279.4963;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;2014;-447.0324,311.4963;Inherit;False;Property;_ObjectScale;ObjectScale;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2057;2218.618,233.6295;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2017;2376.355,233.9467;Float;False;True;-1;2;;100;5;LazyEti/BIRP/FakePointLight;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;8;5;False;;1;False;;8;5;False;;1;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;True;1;False;;True;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;7;False;;True;True;1000;False;;2000;False;;True;2;RenderType=Overlay=RenderType;Queue=Overlay=Queue=0;True;3;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;7;Include;;False;;Native;False;0;0;;Custom;#ifdef STEREO_INSTANCING_ON;False;;Custom;False;0;0;;Custom;UNITY_DECLARE_TEX2DARRAY_NOSAMPLER(_CameraDepthNormalsTexture)@;False;;Custom;False;0;0;;Custom;#else;False;;Custom;False;0;0;;Custom;UNITY_DECLARE_TEX2D_NOSAMPLER(_CameraDepthNormalsTexture)@;False;;Custom;False;0;0;;Custom;#endif;False;;Custom;False;0;0;;Custom;SamplerState sampler_CameraDepthNormalsTexture@;False;;Custom;False;0;0;;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;True;0
WireConnection;539;0;2149;0
WireConnection;1913;1;1914;0
WireConnection;1913;0;742;4
WireConnection;254;0;541;0
WireConnection;254;1;252;0
WireConnection;2060;29;1913;0
WireConnection;137;0;254;0
WireConnection;416;0;2060;0
WireConnection;467;0;463;0
WireConnection;716;0;717;0
WireConnection;653;0;137;0
WireConnection;466;0;416;0
WireConnection;466;3;467;0
WireConnection;712;1;584;0
WireConnection;712;0;716;0
WireConnection;583;0;582;0
WireConnection;2041;0;12;0
WireConnection;477;0;466;0
WireConnection;261;0;260;0
WireConnection;261;1;259;0
WireConnection;585;0;712;0
WireConnection;585;1;583;0
WireConnection;589;0;587;1
WireConnection;589;1;587;2
WireConnection;2160;0;2041;0
WireConnection;263;0;539;0
WireConnection;262;0;654;0
WireConnection;262;1;261;0
WireConnection;730;1;620;0
WireConnection;730;0;731;0
WireConnection;1074;0;585;0
WireConnection;1075;0;589;0
WireConnection;2025;0;2160;0
WireConnection;255;1;263;0
WireConnection;255;0;262;0
WireConnection;420;0;680;0
WireConnection;420;1;478;0
WireConnection;2003;9;730;0
WireConnection;591;0;1074;0
WireConnection;591;1;1075;0
WireConnection;2051;0;2050;4
WireConnection;1927;0;2025;0
WireConnection;505;0;542;0
WireConnection;505;1;506;0
WireConnection;264;0;255;0
WireConnection;264;1;420;0
WireConnection;623;0;591;0
WireConnection;623;1;2003;0
WireConnection;964;0;621;0
WireConnection;964;1;730;0
WireConnection;738;0;722;1
WireConnection;2053;0;2052;0
WireConnection;2053;1;2051;0
WireConnection;2015;1;505;0
WireConnection;2015;21;1929;0
WireConnection;55;0;264;0
WireConnection;586;0;623;0
WireConnection;737;0;594;0
WireConnection;737;1;2053;0
WireConnection;726;1;2049;0
WireConnection;726;0;738;0
WireConnection;962;0;961;0
WireConnection;962;1;964;0
WireConnection;853;0;2015;0
WireConnection;2062;0;55;0
WireConnection;769;0;66;0
WireConnection;1300;0;962;0
WireConnection;1300;2;586;0
WireConnection;648;0;737;0
WireConnection;648;1;656;0
WireConnection;648;2;726;0
WireConnection;509;0;2062;0
WireConnection;509;1;853;0
WireConnection;767;0;769;0
WireConnection;593;0;1300;0
WireConnection;593;2;648;0
WireConnection;2110;0;2094;0
WireConnection;514;0;2062;0
WireConnection;514;1;509;0
WireConnection;765;0;767;0
WireConnection;1294;0;593;0
WireConnection;2109;0;655;0
WireConnection;1852;0;1851;0
WireConnection;438;0;2110;0
WireConnection;438;1;565;0
WireConnection;616;0;1294;0
WireConnection;745;0;514;0
WireConnection;745;1;767;0
WireConnection;745;2;765;0
WireConnection;566;1;438;0
WireConnection;566;0;2109;0
WireConnection;1850;0;1852;0
WireConnection;771;0;745;0
WireConnection;2059;85;1850;0
WireConnection;436;0;566;0
WireConnection;436;1;2027;0
WireConnection;775;0;771;0
WireConnection;642;9;754;0
WireConnection;642;8;643;0
WireConnection;721;1;2044;0
WireConnection;721;0;720;0
WireConnection;563;0;436;0
WireConnection;1881;0;2059;0
WireConnection;640;9;775;0
WireConnection;640;8;492;0
WireConnection;752;0;754;0
WireConnection;752;1;642;0
WireConnection;637;0;635;0
WireConnection;637;1;636;0
WireConnection;667;0;636;0
WireConnection;667;1;721;0
WireConnection;550;0;563;0
WireConnection;550;1;549;0
WireConnection;770;0;775;0
WireConnection;770;1;640;0
WireConnection;651;0;752;0
WireConnection;675;0;637;0
WireConnection;675;1;667;0
WireConnection;1289;0;550;0
WireConnection;1289;1;1882;0
WireConnection;555;0;770;0
WireConnection;2045;0;675;0
WireConnection;562;0;1289;0
WireConnection;562;1;471;0
WireConnection;2047;0;2045;0
WireConnection;2047;1;2046;0
WireConnection;669;0;652;0
WireConnection;551;0;562;0
WireConnection;2048;0;2047;0
WireConnection;481;1;669;0
WireConnection;707;0;557;0
WireConnection;862;1;471;0
WireConnection;862;2;551;0
WireConnection;862;3;863;0
WireConnection;862;4;863;0
WireConnection;485;0;514;0
WireConnection;607;1;707;0
WireConnection;608;0;652;0
WireConnection;608;1;481;0
WireConnection;608;2;649;0
WireConnection;608;3;650;0
WireConnection;683;0;2048;0
WireConnection;552;0;862;0
WireConnection;487;0;485;0
WireConnection;200;0;557;0
WireConnection;200;1;607;0
WireConnection;200;2;140;0
WireConnection;200;3;201;0
WireConnection;686;0;608;0
WireConnection;2054;0;608;0
WireConnection;603;0;686;0
WireConnection;603;1;617;0
WireConnection;603;2;685;0
WireConnection;202;0;200;0
WireConnection;687;0;2054;0
WireConnection;687;1;603;0
WireConnection;2055;0;200;0
WireConnection;143;0;202;0
WireConnection;143;1;488;0
WireConnection;143;2;553;0
WireConnection;143;3;1976;0
WireConnection;1892;0;2060;45
WireConnection;1971;0;687;0
WireConnection;141;0;2055;0
WireConnection;141;1;143;0
WireConnection;1917;1;1952;0
WireConnection;1917;0;1916;0
WireConnection;1988;17;1917;0
WireConnection;600;0;141;0
WireConnection;600;1;1971;0
WireConnection;1901;0;1977;0
WireConnection;1901;1;1384;0
WireConnection;1901;2;1988;0
WireConnection;657;0;600;0
WireConnection;657;1;1897;0
WireConnection;2010;0;2009;0
WireConnection;2010;1;2004;3
WireConnection;2008;0;2010;0
WireConnection;2009;0;2004;1
WireConnection;2009;1;2004;2
WireConnection;2014;1;2008;0
WireConnection;2057;0;657;0
WireConnection;2057;3;1901;0
WireConnection;2017;0;2057;0
ASEEND*/
//CHKSM=68CB1A12893086CA11FE70447F23454D23D21958