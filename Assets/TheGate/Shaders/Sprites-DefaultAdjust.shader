// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Sprites/DefaultAdjust"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
		_Hue("Hue", Range(-0.5,0.5)) = 0.0
		_Saturation("Saturation", Range(0,2)) = 1.0	
		_Brightness("Brightness", Range(0,2)) = 1.0	
    }

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
            #pragma vertex SpriteVert
            #pragma fragment SpriteFragAdjust
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"
			uniform float _Hue;
			uniform float _Saturation;
			uniform float _Brightness;

			float3 rgb2hsv(float3 c)
			{
			  float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			  float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
			  float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

			  float d = q.x - min(q.w, q.y);
			  float e = 1.0e-10;
			  return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			float3 hsv2rgb(float3 c) 
			{
			  c = float3(c.x, clamp(c.yz, 0.0, 1.0));
			  float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			  float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
			  return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}

			inline fixed4 adjustColor(fixed4 color)
			{
				float3 hsv = rgb2hsv(color.rgb);
				
				hsv.x += _Hue; 
				hsv.y *= _Saturation; 
				hsv.z *= _Brightness;
				
				color.rgb = hsv2rgb(hsv);
				
				return color;
			}
			fixed4 SpriteFragAdjust(v2f IN) : SV_Target
			{
				return adjustColor(SpriteFrag(IN));
			}
        ENDCG
        }
    }
}
