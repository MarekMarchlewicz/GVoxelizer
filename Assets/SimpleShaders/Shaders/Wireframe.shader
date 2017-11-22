Shader "Custom/GeometryShaders/Wireframe"
{
	Properties
	{
		_FrontColor("Color", Color) = (1,1,1,1)
		_BackColor("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" }

		// Render Front
		Pass
		{
			Cull Back
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			float4 _FrontColor;
			float _Width;

			struct v2g
			{
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 bcc : TEXCOORD0;
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

				g2f o;

				o.pos = UnityObjectToClipPos(v0);
				o.bcc = float3(1., 0., 0.);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v1);
				o.bcc = float3(0, 1, 0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v2);
				o.bcc = float3(0, 0, 1);
				triStream.Append(o);
			}

			half GetEdgeFactor(float3 bcc)
			{
				float3 zero = float3(0, 0, 0);
				float3 fw = fwidth(bcc);

				float3 edge3 = smoothstep(zero, fw, bcc);

				float edge = 1 - min(min(edge3.x, edge3.y), edge3.z);

				return edge;
			}

			half4 frag(g2f i) : COLOR
			{
				half edge = GetEdgeFactor(i.bcc);

				if (edge <= 0)
					discard;

				return _FrontColor;
			}

			ENDCG
		}

		// Render Back
		Pass
		{
			Cull Front

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			float4 _BackColor;
			float _Width;

			struct v2g
			{
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 bcc : TEXCOORD0;
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

				g2f o;

				o.pos = UnityObjectToClipPos(v0);
				o.bcc = float3(1., 0., 0.);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v1);
				o.bcc = float3(0, 1, 0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(v2);
				o.bcc = float3(0, 0, 1);
				triStream.Append(o);
			}

			half GetEdgeFactor(float3 bcc)
			{
				float3 zero = float3(0, 0, 0);
				float3 fw = fwidth(bcc);

				float3 edge3 = smoothstep(zero, fw, bcc);

				float edge = 1 - min(min(edge3.x, edge3.y), edge3.z);

				return edge;
			}

			half4 frag(g2f i) : COLOR
			{
				half edge = GetEdgeFactor(i.bcc);

				if (edge <= 0)
					discard;

				return _BackColor;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}