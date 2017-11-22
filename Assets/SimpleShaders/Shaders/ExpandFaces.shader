Shader "Custom/GeometryShaders/ExpandFaces"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_ExpandAmount("Expand Amount", Range(0, 5)) = 0
	}

	SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			float4 _Color;
			float _ExpandAmount;

			struct v2g
			{
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float4 light : TEXCOORD0;
			};

			v2g vert(appdata_base v)
			{
				v2g o;
				o.vertex = v.vertex;

				return o;
			}

			v2g vert(appdata_full v)
			{
				v2g o;
				o.vertex = v.vertex;
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float3 edgeA = v1 - v0;
				float3 edgeB = v2 - v0;

				float3 normal = normalize(cross(normalize(edgeA), normalize(edgeB)));

				v0 += float4(normal * _ExpandAmount, 0);
				v1 += float4(normal * _ExpandAmount, 0);
				v2 += float4(normal * _ExpandAmount, 0);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				g2f o;

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(v0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v2);
				triStream.Append(o);
			}

			half4 frag(g2f i) : COLOR
			{
				half4 col = i.light * _Color;
				return col;
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}