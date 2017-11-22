Shader "Custom/GeometryShaders/VoxelizerEffect"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_VoxelSize("Voxel Size", Range(0, 1)) = .1
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
			float _VoxelSize;

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

			[maxvertexcount(24)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f o;

				float4 v0 = IN[0].vertex;
				float4 v1 = IN[1].vertex;
				float4 v2 = IN[2].vertex;
				
				float4 vM = (v0 + v1 + v2) / 3; // Middle point
				
				float3 edgeA;
				float3 edgeB;
				float3 normal;
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				//Cube Points
				float4 cp0 = vM + float4(-1, -1, -1, 0) * _VoxelSize;
				float4 cp1 = vM + float4(+1, -1, -1, 0) * _VoxelSize;
				float4 cp2 = vM + float4(-1, +1, -1, 0) * _VoxelSize;
				float4 cp3 = vM + float4(+1, +1, -1, 0) * _VoxelSize;
				float4 cp4 = vM + float4(-1, -1, +1, 0) * _VoxelSize;
				float4 cp5 = vM + float4(+1, -1, +1, 0) * _VoxelSize;
				float4 cp6 = vM + float4(-1, +1, +1, 0) * _VoxelSize;
				float4 cp7 = vM + float4(+1, +1, +1, 0) * _VoxelSize;

				// Left face
				normal = float3(-1, 0, 0);				
				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp2);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp6);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp4);
				triStream.Append(o);

				triStream.RestartStrip();
				
				// Right face
				normal = float3(1, 0, 0);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp3);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp5);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp7);
				triStream.Append(o);

				triStream.RestartStrip();
				
				//Bottom face
				normal = float3(0, -1, 0);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp4);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp5);
				triStream.Append(o);

				triStream.RestartStrip();
				
				//Top face
				normal = float3(0, 1, 0);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp3);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp2);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp7);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp6);
				triStream.Append(o);

				triStream.RestartStrip();

				//Back face
				normal = float3(0, 0, -1);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp1);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp0);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp3);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp2);
				triStream.Append(o);

				triStream.RestartStrip();
				
				//Front face
				normal = float3(0, 0, 1);

				normal = normalize(mul(normal, (float3x3) unity_WorldToObject));

				o.light = max(0, dot(normal, -lightDirection));

				o.pos = UnityObjectToClipPos(cp4);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp5);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp6);
				triStream.Append(o);

				o.pos = UnityObjectToClipPos(cp7);
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