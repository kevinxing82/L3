// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sprites/Default Shadow"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_Config ("offset", Vector) = (1, 1,0,0)
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
		fixed4 _Config;
		sampler2D _MainTex;
		
		v2f vertS2(appdata_t IN)
		{
			v2f OUT;
			float4 vertex = IN.vertex + _Config*3;
			OUT.vertex = UnityObjectToClipPos(vertex)*2;
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}

		fixed4 fragS2(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord) * fixed4(0,0,0,0.2);
			c.rgb *= c.a;
			return c;
		}
		
		v2f vertS1(appdata_t IN)
		{
			v2f OUT;
			float4 vertex = IN.vertex + _Config*2;
			OUT.vertex = UnityObjectToClipPos(vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}

		fixed4 fragS1(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord) * fixed4(0,0,0,0.3);
			c.rgb *= c.a;
			return c;
		}

		v2f vertS0(appdata_t IN)
		{
			v2f OUT;
			float4 vertex = IN.vertex + _Config;
			OUT.vertex = UnityObjectToClipPos(vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}

		fixed4 fragS0(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord) * fixed4(0,0,0,0.6);
			c.rgb *= c.a;
			return c;
		}
		
		v2f vert(appdata_t IN)
		{
			v2f OUT;
			float4 vertex = IN.vertex;
			OUT.vertex = UnityObjectToClipPos(vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}
		
		fixed4 frag(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord);
			c.rgb *= c.a;
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
			#pragma vertex vertS1
			#pragma fragment fragS1
			ENDCG
		}
	

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
		
	}
	
}
