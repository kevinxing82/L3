// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sprites/Sprites-offset"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		//_Color ("Tint", Color) = (1,1,1,1)
		//[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}

		CGINCLUDE
		#pragma multi_compile _ PIXELSNAP_ON
		#include "UnityCG.cginc"
		
		struct appdata_t
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color    : COLOR;
			half2 texcoord  : TEXCOORD0;
		};
		
		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		
		v2f vert(appdata_t IN)
		{
			v2f OUT;
			float4 vertex = IN.vertex;
			OUT.vertex = UnityObjectToClipPos(vertex);
			OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.color);
			#endif

			return OUT;
		}
		
		fixed4 frag(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord);
			//c.rgb *= (1-c.a);
			//c.a = 1 - c.a;
			return c;
		}
	ENDCG

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
		
	}
	
}
