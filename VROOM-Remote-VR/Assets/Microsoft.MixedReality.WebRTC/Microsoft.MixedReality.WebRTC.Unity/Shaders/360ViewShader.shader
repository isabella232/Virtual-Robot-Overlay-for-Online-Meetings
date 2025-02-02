﻿Shader "Custom/360ViewShader"
{
	Properties
	{
		[Toggle(MIRROR)] _Mirror("Horizontal Mirror", Float) = 0
		[HideInEditor][NoScaleOffset] _YPlane("Y plane", 2D) = "white" {}
		[HideInEditor][NoScaleOffset] _UPlane("U plane", 2D) = "white" {}
		[HideInEditor][NoScaleOffset] _VPlane("V plane", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Cull Off

		CGPROGRAM

		#pragma surface surf Lambert vertex:vert	//alpha
		#pragma multi_compile __ MIRROR

		#include "UnityCG.cginc"

		struct Input
		{
			float2 uv_YPlane;
		};

		sampler2D _YPlane;
		sampler2D _UPlane;
		sampler2D _VPlane;

		void vert(inout appdata_full v)
		{
			v.normal.xyz = v.normal * -1;
		}

		float3 yuv2rgb(float3 yuv)
		{
			// The YUV to RBA conversion, please refer to: http://en.wikipedia.org/wiki/YUV
			// Y'UV420p (I420) to RGB888 conversion section.
			float y_value = yuv[0];
			float u_value = yuv[1];
			float v_value = yuv[2];
			float r = y_value + 1.370705 * (v_value - 0.5);
			float g = y_value - 0.698001 * (v_value - 0.5) - (0.337633 * (u_value - 0.5));
			float b = y_value + 1.732446 * (u_value - 0.5);
			return float3(r, g, b);
		}

		void surf(Input IN, inout SurfaceOutput o)
		{
			float3 yuv;
#if !UNITY_UV_STARTS_AT_TOP
			IN.uv_YPlane.y = 1 - IN.uv_YPlane.y;
#endif
#ifdef MIRROR
			IN.uv_YPlane.x = 1 - IN.uv_YPlane.x;
#endif
			yuv.x = tex2D(_YPlane, IN.uv_YPlane).r;
			yuv.y = tex2D(_UPlane, IN.uv_YPlane).r;
			yuv.z = tex2D(_VPlane, IN.uv_YPlane).r;
			o.Albedo = yuv2rgb(yuv);
		}

		ENDCG
	}

		Fallback "Diffuse"
}
