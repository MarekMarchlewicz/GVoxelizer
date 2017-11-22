Shader "Custom/GeometryShaders/AddExtraGeometry"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
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

			[maxvertexcount(9)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f o;

				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;

				float len = (length(v0) + length(v1) + length(v2)) / 3;

				float4 vM = normalize((v0 + v1 + v2) / 3) * len; // Middle point
				
				float3 edgeA;
				float3 edgeB;
				float3 normal;
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				// Triangle 1 01m

				edgeA = v1 - v0;
				edgeB = vM - v0;

				normal = normalize(cross(edgeA, edgeB));
				
				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(v0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(vM);
				triStream.Append(o);

				triStream.RestartStrip();

				// Triangle 2 0m2

				edgeA = vM - v0;
				edgeB = v2 - v0;

				normal = normalize(cross(edgeA, edgeB));

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
								
				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(v0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(vM);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v2);
				triStream.Append(o);

				triStream.RestartStrip();

				// Triangle 3 m12

				edgeA = v1 - vM;
				edgeB = v2 - vM;

				normal = normalize(cross(edgeA, edgeB));

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(vM);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v2);
				triStream.Append(o);

				triStream.RestartStrip();
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