#ifndef WI_OBJECTSHADER_HF
#define WI_OBJECTSHADER_HF

#ifdef TRANSPARENT
#define DISABLE_TRANSPARENT_SHADOWMAP
#endif

#ifdef PLANARREFLECTION
#define DISABLE_ENVMAPS
#define DISABLE_VOXELGI
#endif

#ifdef WATER
#define DISABLE_VOXELGI
#endif

#define LIGHTMAP_QUALITY_BICUBIC


#include "globals.hlsli"
#include "brdf.hlsli"
#include "lightingHF.hlsli"
#include "ShaderInterop_SurfelGI.h"

// DEFINITIONS
//////////////////

PUSHCONSTANT(push, ObjectPushConstants);

inline uint GetSubsetIndex()
{
	return push.GetSubsetIndex();
}
inline ShaderMesh GetMesh()
{
	return load_mesh(push.GetMeshIndex());
}
inline ShaderMaterial GetMaterial()
{
	return load_material(push.GetMaterialIndex());
}
inline ShaderMaterial GetMaterial1()
{
	return load_material(GetMesh().blendmaterial1);
}
inline ShaderMaterial GetMaterial2()
{
	return load_material(GetMesh().blendmaterial2);
}
inline ShaderMaterial GetMaterial3()
{
	return load_material(GetMesh().blendmaterial3);
}

#define sampler_objectshader			bindless_samplers[g_xFrame.ObjectShaderSamplerIndex]

#define texture_basecolormap			bindless_textures[GetMaterial().texture_basecolormap_index]
#define texture_normalmap				bindless_textures[GetMaterial().texture_normalmap_index]
#define texture_surfacemap				bindless_textures[GetMaterial().texture_surfacemap_index]
#define texture_emissivemap				bindless_textures[GetMaterial().texture_emissivemap_index]
#define texture_displacementmap			bindless_textures[GetMaterial().texture_displacementmap_index]
#define texture_occlusionmap			bindless_textures[GetMaterial().texture_occlusionmap_index]
#define texture_transmissionmap			bindless_textures[GetMaterial().texture_transmissionmap_index]
#define texture_sheencolormap			bindless_textures[GetMaterial().texture_sheencolormap_index]
#define texture_sheenroughnessmap		bindless_textures[GetMaterial().texture_sheenroughnessmap_index]
#define texture_clearcoatmap			bindless_textures[GetMaterial().texture_clearcoatmap_index]
#define texture_clearcoatroughnessmap	bindless_textures[GetMaterial().texture_clearcoatroughnessmap_index]
#define texture_clearcoatnormalmap		bindless_textures[GetMaterial().texture_clearcoatnormalmap_index]
#define texture_specularmap				bindless_textures[GetMaterial().texture_specularmap_index]

#define texture_blend1_basecolormap		bindless_textures[GetMaterial1().texture_basecolormap_index]
#define texture_blend1_normalmap		bindless_textures[GetMaterial1().texture_normalmap_index]
#define texture_blend1_surfacemap		bindless_textures[GetMaterial1().texture_surfacemap_index]
#define texture_blend1_emissivemap		bindless_textures[GetMaterial1().texture_emissivemap_index]

#define texture_blend2_basecolormap		bindless_textures[GetMaterial2().texture_basecolormap_index]
#define texture_blend2_normalmap		bindless_textures[GetMaterial2().texture_normalmap_index]
#define texture_blend2_surfacemap		bindless_textures[GetMaterial2().texture_surfacemap_index]
#define texture_blend2_emissivemap		bindless_textures[GetMaterial2().texture_emissivemap_index]

#define texture_blend3_basecolormap		bindless_textures[GetMaterial3().texture_basecolormap_index]
#define texture_blend3_normalmap		bindless_textures[GetMaterial3().texture_normalmap_index]
#define texture_blend3_surfacemap		bindless_textures[GetMaterial3().texture_surfacemap_index]
#define texture_blend3_emissivemap		bindless_textures[GetMaterial3().texture_emissivemap_index]



// These are bound by RenderPath (based on Render Path):
STRUCTUREDBUFFER(EntityTiles, uint, TEXSLOT_RENDERPATH_ENTITYTILES);
TEXTURE2D(texture_reflection, float4, TEXSLOT_RENDERPATH_REFLECTION);		// rgba: scene color from reflected camera angle
TEXTURE2D(texture_refraction, float4, TEXSLOT_RENDERPATH_REFRACTION);		// rgba: scene color from primary camera angle
TEXTURE2D(texture_waterriples, float4, TEXSLOT_RENDERPATH_WATERRIPPLES);	// rgb: snorm8 water ripple normal map
TEXTURE2D(texture_ao, float, TEXSLOT_RENDERPATH_AO);						// r: ambient occlusion
TEXTURE2D(texture_ssr, float4, TEXSLOT_RENDERPATH_SSR);						// rgb: screen space ray-traced reflections, a: reflection blend based on ray hit or miss
TEXTURE2D(texture_rtshadow, uint4, TEXSLOT_RENDERPATH_RTSHADOW);			// bitmask for max 16 shadows' visibility
TEXTURE2D(texture_surfelgi, float3, TEXSLOT_RENDERPATH_SURFELGI);

// Use these to compile this file as shader prototype:
//#define OBJECTSHADER_COMPILE_VS				- compile vertex shader prototype
//#define OBJECTSHADER_COMPILE_PS				- compile pixel shader prototype

// Use these to define the expected layout for the shader:
//#define OBJECTSHADER_LAYOUT_SHADOW			- layout for shadow pass
//#define OBJECTSHADER_LAYOUT_SHADOW_TEX		- layout for shadow pass and alpha test or transparency
//#define OBJECTSHADER_LAYOUT_PREPASS			- layout for prepass
//#define OBJECTSHADER_LAYOUT_PREPASS_TEX		- layout for prepass and alpha test or dithering
//#define OBJECTSHADER_LAYOUT_COMMON			- layout for common passes

// Use these to enable features for the shader:
//	(Some of these are enabled automatically with OBJECTSHADER_LAYOUT defines)
//#define OBJECTSHADER_USE_CLIPPLANE				- shader will be clipped according to camera clip planes
//#define OBJECTSHADER_USE_WIND						- shader will use procedural wind animation
//#define OBJECTSHADER_USE_COLOR					- shader will use colors (material color, vertex color...)
//#define OBJECTSHADER_USE_DITHERING				- shader will use dithered transparency
//#define OBJECTSHADER_USE_UVSETS					- shader will sample textures with uv sets
//#define OBJECTSHADER_USE_ATLAS					- shader will use atlas
//#define OBJECTSHADER_USE_NORMAL					- shader will use normals
//#define OBJECTSHADER_USE_TANGENT					- shader will use tangents, normal mapping
//#define OBJECTSHADER_USE_POSITION3D				- shader will use world space positions
//#define OBJECTSHADER_USE_EMISSIVE					- shader will use emissive
//#define OBJECTSHADER_USE_RENDERTARGETARRAYINDEX	- shader will use dynamic render target slice selection
//#define OBJECTSHADER_USE_NOCAMERA					- shader will not use camera space transform
//#define OBJECTSHADER_USE_INSTANCEID				- shader will use instance ID


#ifdef OBJECTSHADER_LAYOUT_SHADOW
#define OBJECTSHADER_USE_WIND
#endif // OBJECTSHADER_LAYOUT_SHADOW

#ifdef OBJECTSHADER_LAYOUT_SHADOW_TEX
#define OBJECTSHADER_USE_WIND
#define OBJECTSHADER_USE_UVSETS
#define OBJECTSHADER_USE_COLOR
#endif // OBJECTSHADER_LAYOUT_SHADOW_TEX

#ifdef OBJECTSHADER_LAYOUT_PREPASS
#define OBJECTSHADER_USE_CLIPPLANE
#define OBJECTSHADER_USE_WIND
#define OBJECTSHADER_USE_INSTANCEID
#endif // OBJECTSHADER_LAYOUT_SHADOW

#ifdef OBJECTSHADER_LAYOUT_PREPASS_TEX
#define OBJECTSHADER_USE_CLIPPLANE
#define OBJECTSHADER_USE_WIND
#define OBJECTSHADER_USE_UVSETS
#define OBJECTSHADER_USE_DITHERING
#define OBJECTSHADER_USE_INSTANCEID
#endif // OBJECTSHADER_LAYOUT_SHADOW_TEX

#ifdef OBJECTSHADER_LAYOUT_COMMON
#define OBJECTSHADER_USE_CLIPPLANE
#define OBJECTSHADER_USE_WIND
#define OBJECTSHADER_USE_UVSETS
#define OBJECTSHADER_USE_ATLAS
#define OBJECTSHADER_USE_COLOR
#define OBJECTSHADER_USE_NORMAL
#define OBJECTSHADER_USE_TANGENT
#define OBJECTSHADER_USE_POSITION3D
#define OBJECTSHADER_USE_EMISSIVE
#define OBJECTSHADER_USE_INSTANCEID
#endif // OBJECTSHADER_LAYOUT_COMMON

struct VertexInput
{
	uint vertexID : SV_VertexID;
	uint instanceID : SV_InstanceID;

	float4 GetPosition()
	{
		return float4(bindless_buffers[GetMesh().vb_pos_nor_wind].Load<float3>(vertexID * 16), 1);
	}
	float3 GetNormal()
	{
		const uint normal_wind = bindless_buffers[GetMesh().vb_pos_nor_wind].Load<uint4>(vertexID * 16).w;
		float3 normal;
		normal.x = (float)((normal_wind >> 0u) & 0xFF) / 255.0 * 2 - 1;
		normal.y = (float)((normal_wind >> 8u) & 0xFF) / 255.0 * 2 - 1;
		normal.z = (float)((normal_wind >> 16u) & 0xFF) / 255.0 * 2 - 1;
		return normal;
	}
	float GetWindWeight()
	{
		const uint normal_wind = bindless_buffers[GetMesh().vb_pos_nor_wind].Load<uint4>(vertexID * 16).w;
		return ((normal_wind >> 24u) & 0xFF) / 255.0;
	}

	float2 GetUV0()
	{
		[branch]
		if (GetMesh().vb_uv0 < 0)
			return 0;
		return unpack_half2(bindless_buffers[GetMesh().vb_uv0].Load<uint>(vertexID * 4));
	}
	float2 GetUV1()
	{
		[branch]
		if (GetMesh().vb_uv1 < 0)
			return 0;
		return unpack_half2(bindless_buffers[GetMesh().vb_uv1].Load<uint>(vertexID * 4));
	}

	ShaderMeshInstancePointer GetInstancePointer()
	{
		if (push.instances >= 0)
			return bindless_buffers[push.instances].Load<ShaderMeshInstancePointer>(push.instance_offset + instanceID * 8);

		ShaderMeshInstancePointer poi;
		poi.init();
		return poi;
	}

	float2 GetAtlasUV()
	{
		[branch]
		if (GetMesh().vb_atl < 0)
			return 0;
		return unpack_half2(bindless_buffers[GetMesh().vb_atl].Load<uint>(vertexID * 4));
	}

	float4 GetVertexColor()
	{
		[branch]
		if (GetMesh().vb_col < 0)
			return 1;
		return unpack_rgba(bindless_buffers[GetMesh().vb_col].Load<uint>(vertexID * 4));
	}

	float4 GetTangent()
	{
		[branch]
		if (GetMesh().vb_tan < 0)
			return 0;
		return unpack_utangent(bindless_buffers[GetMesh().vb_tan].Load<uint>(vertexID * 4)) * 2 - 1;
	}

	ShaderMeshInstance GetInstance()
	{
		if (push.instances >= 0)
			return load_instance(GetInstancePointer().instanceID);

		ShaderMeshInstance inst;
		inst.init();
		return inst;
	}
};


struct VertexSurface
{
	float4 position;
	float4 uvsets;
	float2 atlas;
	float4 color;
	float3 normal;
	float4 tangent;
	uint emissiveColor;

	inline void create(in ShaderMaterial material, in VertexInput input)
	{
		position = input.GetPosition();
		color = material.baseColor * unpack_rgba(input.GetInstance().color);
		color.a *= 1 - input.GetInstancePointer().GetDither();
		emissiveColor = input.GetInstance().emissive;

		if (material.IsUsingVertexColors())
		{
			color *= input.GetVertexColor();
		}
		
		normal = normalize(mul((float3x3)input.GetInstance().transformInverseTranspose.GetMatrix(), input.GetNormal()));

		tangent = input.GetTangent();
		tangent.xyz = normalize(mul((float3x3)input.GetInstance().transformInverseTranspose.GetMatrix(), tangent.xyz));

		uvsets = float4(input.GetUV0() * material.texMulAdd.xy + material.texMulAdd.zw, input.GetUV1());

		atlas = input.GetAtlasUV();

		position = mul(input.GetInstance().transform.GetMatrix(), position);


#ifdef OBJECTSHADER_USE_WIND
		if (material.IsUsingWind())
		{
			const float windweight = input.GetWindWeight();
			const float waveoffset = dot(position.xyz, g_xFrame.WindDirection) * g_xFrame.WindWaveSize + (position.x + position.y + position.z) * g_xFrame.WindRandomness;
			const float3 wavedir = g_xFrame.WindDirection * windweight;
			const float3 wind = sin(g_xFrame.Time * g_xFrame.WindSpeed + waveoffset) * wavedir;
			position.xyz += wind;
		}
#endif // OBJECTSHADER_USE_WIND
	}
};

struct PixelInput
{
	precise float4 pos : SV_POSITION;

#ifdef OBJECTSHADER_USE_INSTANCEID
	uint instanceID : INSTANCEID;
#endif // OBJECTSHADER_USE_INSTANCEID

#ifdef OBJECTSHADER_USE_CLIPPLANE
	float  clip : SV_ClipDistance0;
#endif // OBJECTSHADER_USE_CLIPPLANE

#ifdef OBJECTSHADER_USE_DITHERING
	nointerpolation float dither : DITHER;
#endif // OBJECTSHADER_USE_DITHERING

#ifdef OBJECTSHADER_USE_EMISSIVE
	uint emissiveColor : EMISSIVECOLOR;
#endif // OBJECTSHADER_USE_EMISSIVE

#ifdef OBJECTSHADER_USE_COLOR
	float4 color : COLOR;
#endif // OBJECTSHADER_USE_COLOR

#ifdef OBJECTSHADER_USE_UVSETS
	float4 uvsets : UVSETS;
#endif // OBJECTSHADER_USE_UVSETS

#ifdef OBJECTSHADER_USE_ATLAS
	float2 atl : ATLAS;
#endif // OBJECTSHADER_USE_ATLAS

#ifdef OBJECTSHADER_USE_NORMAL
	float3 nor : NORMAL;
#endif // OBJECTSHADER_USE_NORMAL

#ifdef OBJECTSHADER_USE_TANGENT
	float4 tan : TANGENT;
#endif // OBJECTSHADER_USE_TANGENT

#ifdef OBJECTSHADER_USE_POSITION3D
	float3 pos3D : WORLDPOSITION;
#endif // OBJECTSHADER_USE_POSITION3D

#ifdef OBJECTSHADER_USE_RENDERTARGETARRAYINDEX
#ifdef VPRT_EMULATION
	uint RTIndex : RTINDEX;
#else
	uint RTIndex : SV_RenderTargetArrayIndex;
#endif // VPRT_EMULATION
#endif // OBJECTSHADER_USE_RENDERTARGETARRAYINDEX
};


// METHODS
////////////

inline void ApplyEmissive(in Surface surface, inout Lighting lighting)
{
	lighting.direct.specular += surface.emissiveColor.rgb * surface.emissiveColor.a;
}

inline void LightMapping(in int lightmap, in float2 ATLAS, inout Lighting lighting)
{
	[branch]
	if (lightmap >= 0 && any(ATLAS))
	{
		Texture2D<float4> texture_lightmap = bindless_textures[NonUniformResourceIndex(lightmap)];
#ifdef LIGHTMAP_QUALITY_BICUBIC
		lighting.indirect.diffuse = SampleTextureCatmullRom(texture_lightmap, sampler_linear_clamp, ATLAS).rgb;
#else
		lighting.indirect.diffuse = texture_lightmap.SampleLevel(sampler_linear_clamp, ATLAS, 0).rgb;
#endif // LIGHTMAP_QUALITY_BICUBIC
	}
}

inline void NormalMapping(in float4 uvsets, inout float3 N, in float3x3 TBN, out float3 bumpColor)
{
	[branch]
	if (GetMaterial().normalMapStrength > 0 && GetMaterial().uvset_normalMap >= 0)
	{
		const float2 UV_normalMap = GetMaterial().uvset_normalMap == 0 ? uvsets.xy : uvsets.zw;
		float3 normalMap = float3(texture_normalmap.Sample(sampler_objectshader, UV_normalMap).rg, 1);
		bumpColor = normalMap.rgb * 2 - 1;
		N = normalize(lerp(N, mul(bumpColor, TBN), GetMaterial().normalMapStrength));
		bumpColor *= GetMaterial().normalMapStrength;
	}
	else
	{
		bumpColor = 0;
	}
}

inline float3 PlanarReflection(in Surface surface, in float2 bumpColor)
{
	float4 reflectionUV = mul(g_xCamera.ReflVP, float4(surface.P, 1));
	reflectionUV.xy /= reflectionUV.w;
	reflectionUV.xy = reflectionUV.xy * float2(0.5, -0.5) + 0.5;
	return texture_reflection.SampleLevel(sampler_linear_clamp, reflectionUV.xy + bumpColor*GetMaterial().normalMapStrength, 0).rgb;
}

#define NUM_PARALLAX_OCCLUSION_STEPS 32
inline void ParallaxOcclusionMapping(inout float4 uvsets, in float3 V, in float3x3 TBN)
{
	[branch]
	if (GetMaterial().parallaxOcclusionMapping > 0 && GetMaterial().uvset_displacementMap >= 0)
	{
		V = mul(TBN, V);
		float layerHeight = 1.0 / NUM_PARALLAX_OCCLUSION_STEPS;
		float curLayerHeight = 0;
		float2 dtex = GetMaterial().parallaxOcclusionMapping * V.xy / NUM_PARALLAX_OCCLUSION_STEPS;
		float2 originalTextureCoords = GetMaterial().uvset_displacementMap == 0 ? uvsets.xy : uvsets.zw;
		float2 currentTextureCoords = originalTextureCoords;
		float2 derivX = ddx_coarse(currentTextureCoords);
		float2 derivY = ddy_coarse(currentTextureCoords);
		float heightFromTexture = 1 - texture_displacementmap.SampleGrad(sampler_linear_wrap, currentTextureCoords, derivX, derivY).r;
		uint iter = 0;
		[loop]
		while (heightFromTexture > curLayerHeight && iter < NUM_PARALLAX_OCCLUSION_STEPS)
		{
			curLayerHeight += layerHeight;
			currentTextureCoords -= dtex;
			heightFromTexture = 1 - texture_displacementmap.SampleGrad(sampler_linear_wrap, currentTextureCoords, derivX, derivY).r;
			iter++;
		}
		float2 prevTCoords = currentTextureCoords + dtex;
		float nextH = heightFromTexture - curLayerHeight;
		float prevH = 1 - texture_displacementmap.SampleGrad(sampler_linear_wrap, prevTCoords, derivX, derivY).r - curLayerHeight + layerHeight;
		float weight = nextH / (nextH - prevH);
		float2 finalTextureCoords = prevTCoords * weight + currentTextureCoords * (1.0 - weight);
		float2 difference = finalTextureCoords - originalTextureCoords;
		uvsets += difference.xyxy;
	}
}

inline void ForwardLighting(inout Surface surface, inout Lighting lighting)
{
#ifndef DISABLE_DECALS
	[branch]
	if (xForwardDecalMask != 0)
	{
		// decals are enabled, loop through them first:
		float4 decalAccumulation = 0;
		const float3 P_dx = ddx_coarse(surface.P);
		const float3 P_dy = ddy_coarse(surface.P);

		uint bucket_bits = xForwardDecalMask;

		[loop]
		while (bucket_bits != 0)
		{
			// Retrieve global entity index from local bucket, then remove bit from local bucket:
			const uint bucket_bit_index = firstbitlow(bucket_bits);
			const uint entity_index = bucket_bit_index;
			bucket_bits ^= 1u << bucket_bit_index;

			[branch]
			if (decalAccumulation.a < 1)
			{
				ShaderEntity decal = load_entity(g_xFrame.DecalArrayOffset + entity_index);
				if ((decal.layerMask & surface.layerMask) == 0)
					continue;

				float4x4 decalProjection = load_entitymatrix(decal.GetMatrixIndex());
				int decalTexture = asint(decalProjection[3][0]);
				int decalNormal = asint(decalProjection[3][1]);
				decalProjection[3] = float4(0, 0, 0, 1);
				const float3 clipSpacePos = mul(decalProjection, float4(surface.P, 1)).xyz;
				const float3 uvw = clipSpacePos.xyz * float3(0.5, -0.5, 0.5) + 0.5;
				[branch]
				if (is_saturated(uvw))
				{
					float4 decalColor = 1;
					[branch]
					if (decalTexture >= 0)
					{
						// mipmapping needs to be performed by hand:
						const float2 decalDX = mul(P_dx, (float3x3)decalProjection).xy;
						const float2 decalDY = mul(P_dy, (float3x3)decalProjection).xy;
						decalColor = bindless_textures[NonUniformResourceIndex(decalTexture)].SampleGrad(sampler_objectshader, uvw.xy, decalDX, decalDY);
					}
					// blend out if close to cube Z:
					float edgeBlend = 1 - pow(saturate(abs(clipSpacePos.z)), 8);
					decalColor.a *= edgeBlend;
					decalColor *= decal.GetColor();
					// apply emissive:
					lighting.direct.specular += max(0, decalColor.rgb * decal.GetEmissive() * edgeBlend);
					// perform manual blending of decals:
					//  NOTE: they are sorted top-to-bottom, but blending is performed bottom-to-top
					decalAccumulation.rgb = (1 - decalAccumulation.a) * (decalColor.a*decalColor.rgb) + decalAccumulation.rgb;
					decalAccumulation.a = decalColor.a + (1 - decalColor.a) * decalAccumulation.a;
					[branch]
					if (decalAccumulation.a >= 1.0)
					{
						// force exit:
						break;
					}
				}
			}
			else
			{
				// force exit:
				break;
			}

		}

		surface.albedo.rgb = lerp(surface.albedo.rgb, decalAccumulation.rgb, decalAccumulation.a);
	}
#endif // DISABLE_DECALS


#ifndef DISABLE_ENVMAPS
	// Apply environment maps:
	float4 envmapAccumulation = 0;

#ifndef ENVMAPRENDERING
#ifndef DISABLE_LOCALENVPMAPS
	[branch]
	if (xForwardEnvProbeMask != 0)
	{
		uint bucket_bits = xForwardEnvProbeMask;

		[loop]
		while (bucket_bits != 0)
		{
			// Retrieve global entity index from local bucket, then remove bit from local bucket:
			const uint bucket_bit_index = firstbitlow(bucket_bits);
			const uint entity_index = bucket_bit_index;
			bucket_bits ^= 1u << bucket_bit_index;

			[branch]
			if (envmapAccumulation.a < 1)
			{
				ShaderEntity probe = load_entity(g_xFrame.EnvProbeArrayOffset + entity_index);
				if ((probe.layerMask & surface.layerMask) == 0)
					continue;

				const float4x4 probeProjection = load_entitymatrix(probe.GetMatrixIndex());
				const float3 clipSpacePos = mul(probeProjection, float4(surface.P, 1)).xyz;
				const float3 uvw = clipSpacePos.xyz * float3(0.5, -0.5, 0.5) + 0.5;
				[branch]
				if (is_saturated(uvw))
				{
					const float4 envmapColor = EnvironmentReflection_Local(surface, probe, probeProjection, clipSpacePos);
					// perform manual blending of probes:
					//  NOTE: they are sorted top-to-bottom, but blending is performed bottom-to-top
					envmapAccumulation.rgb = (1 - envmapAccumulation.a) * (envmapColor.a * envmapColor.rgb) + envmapAccumulation.rgb;
					envmapAccumulation.a = envmapColor.a + (1 - envmapColor.a) * envmapAccumulation.a;
					[branch]
					if (envmapAccumulation.a >= 1.0)
					{
						// force exit:
						break;
					}
				}
			}
			else
			{
				// force exit:
				break;
			}

		}
	}
#endif // DISABLE_LOCALENVPMAPS
#endif //ENVMAPRENDERING

	// Apply global envmap where there is no local envmap information:
	[branch]
	if (envmapAccumulation.a < 0.99)
	{
		envmapAccumulation.rgb = lerp(EnvironmentReflection_Global(surface), envmapAccumulation.rgb, envmapAccumulation.a);
	}
	lighting.indirect.specular += max(0, envmapAccumulation.rgb);
#endif // DISABLE_ENVMAPS

#ifndef DISABLE_VOXELGI
	VoxelGI(surface, lighting);
#endif //DISABLE_VOXELGI

	[branch]
	if (any(xForwardLightMask))
	{
		// Loop through light buckets for the draw call:
		const uint first_item = 0;
		const uint last_item = first_item + g_xFrame.LightArrayCount - 1;
		const uint first_bucket = first_item / 32;
		const uint last_bucket = min(last_item / 32, 1); // only 2 buckets max (uint2) for forward pass!
		[loop]
		for (uint bucket = first_bucket; bucket <= last_bucket; ++bucket)
		{
			uint bucket_bits = xForwardLightMask[bucket];

			[loop]
			while (bucket_bits != 0)
			{
				// Retrieve global entity index from local bucket, then remove bit from local bucket:
				const uint bucket_bit_index = firstbitlow(bucket_bits);
				const uint entity_index = bucket * 32 + bucket_bit_index;
				bucket_bits ^= 1u << bucket_bit_index;

				ShaderEntity light = load_entity(g_xFrame.LightArrayOffset + entity_index);
				if ((light.layerMask & surface.layerMask) == 0)
					continue;

				if (light.GetFlags() & ENTITY_FLAG_LIGHT_STATIC)
				{
					continue; // static lights will be skipped (they are used in lightmap baking)
				}

				switch (light.GetType())
				{
				case ENTITY_TYPE_DIRECTIONALLIGHT:
				{
					DirectionalLight(light, surface, lighting);
				}
				break;
				case ENTITY_TYPE_POINTLIGHT:
				{
					PointLight(light, surface, lighting);
				}
				break;
				case ENTITY_TYPE_SPOTLIGHT:
				{
					SpotLight(light, surface, lighting);
				}
				break;
				}
			}
		}
	}

}

inline void TiledLighting(inout Surface surface, inout Lighting lighting)
{
	const uint2 tileIndex = uint2(floor(surface.pixel / TILED_CULLING_BLOCKSIZE));
	const uint flatTileIndex = flatten2D(tileIndex, g_xFrame.EntityCullingTileCount.xy) * SHADER_ENTITY_TILE_BUCKET_COUNT;


#ifndef DISABLE_DECALS
	[branch]
	if (g_xFrame.DecalArrayCount > 0)
	{
		// decals are enabled, loop through them first:
		float4 decalAccumulation = 0;
		const float3 P_dx = ddx_coarse(surface.P);
		const float3 P_dy = ddy_coarse(surface.P);

		// Loop through decal buckets in the tile:
		const uint first_item = g_xFrame.DecalArrayOffset;
		const uint last_item = first_item + g_xFrame.DecalArrayCount - 1;
		const uint first_bucket = first_item / 32;
		const uint last_bucket = min(last_item / 32, max(0, SHADER_ENTITY_TILE_BUCKET_COUNT - 1));
		[loop]
		for (uint bucket = first_bucket; bucket <= last_bucket; ++bucket)
		{
			uint bucket_bits = EntityTiles[flatTileIndex + bucket];

			// This is the wave scalarizer from Improved Culling - Siggraph 2017 [Drobot]:
			bucket_bits = WaveReadLaneFirst(WaveActiveBitOr(bucket_bits));

			[loop]
			while (bucket_bits != 0)
			{
				// Retrieve global entity index from local bucket, then remove bit from local bucket:
				const uint bucket_bit_index = firstbitlow(bucket_bits);
				const uint entity_index = bucket * 32 + bucket_bit_index;
				bucket_bits ^= 1u << bucket_bit_index;

				[branch]
				if (entity_index >= first_item && entity_index <= last_item && decalAccumulation.a < 1)
				{
					ShaderEntity decal = load_entity(entity_index);
					if ((decal.layerMask & surface.layerMask) == 0)
						continue;

					float4x4 decalProjection = load_entitymatrix(decal.GetMatrixIndex());
					int decalTexture = asint(decalProjection[3][0]);
					int decalNormal = asint(decalProjection[3][1]);
					decalProjection[3] = float4(0, 0, 0, 1);
					const float3 clipSpacePos = mul(decalProjection, float4(surface.P, 1)).xyz;
					const float3 uvw = clipSpacePos.xyz * float3(0.5, -0.5, 0.5) + 0.5;
					[branch]
					if (is_saturated(uvw))
					{
						// mipmapping needs to be performed by hand:
						float4 decalColor = 1;
						[branch]
						if (decalTexture >= 0)
						{
							const float2 decalDX = mul(P_dx, (float3x3)decalProjection).xy;
							const float2 decalDY = mul(P_dy, (float3x3)decalProjection).xy;
							decalColor = bindless_textures[NonUniformResourceIndex(decalTexture)].SampleGrad(sampler_objectshader, uvw.xy, decalDX, decalDY);
						}
						// blend out if close to cube Z:
						float edgeBlend = 1 - pow(saturate(abs(clipSpacePos.z)), 8);
						decalColor.a *= edgeBlend;
						decalColor *= decal.GetColor();
						// apply emissive:
						lighting.direct.specular += max(0, decalColor.rgb * decal.GetEmissive() * edgeBlend);
						// perform manual blending of decals:
						//  NOTE: they are sorted top-to-bottom, but blending is performed bottom-to-top
						decalAccumulation.rgb = (1 - decalAccumulation.a) * (decalColor.a*decalColor.rgb) + decalAccumulation.rgb;
						decalAccumulation.a = decalColor.a + (1 - decalColor.a) * decalAccumulation.a;
						[branch]
						if (decalAccumulation.a >= 1.0)
						{
							// force exit:
							bucket = SHADER_ENTITY_TILE_BUCKET_COUNT;
							break;
						}
					}
				}
				else if (entity_index > last_item)
				{
					// force exit:
					bucket = SHADER_ENTITY_TILE_BUCKET_COUNT;
					break;
				}

			}
		}

		surface.albedo.rgb = lerp(surface.albedo.rgb, decalAccumulation.rgb, decalAccumulation.a);
	}
#endif // DISABLE_DECALS


#ifndef DISABLE_ENVMAPS
	// Apply environment maps:
	float4 envmapAccumulation = 0;

#ifndef DISABLE_LOCALENVPMAPS
	[branch]
	if (g_xFrame.EnvProbeArrayCount > 0)
	{
		// Loop through envmap buckets in the tile:
		const uint first_item = g_xFrame.EnvProbeArrayOffset;
		const uint last_item = first_item + g_xFrame.EnvProbeArrayCount - 1;
		const uint first_bucket = first_item / 32;
		const uint last_bucket = min(last_item / 32, max(0, SHADER_ENTITY_TILE_BUCKET_COUNT - 1));
		[loop]
		for (uint bucket = first_bucket; bucket <= last_bucket; ++bucket)
		{
			uint bucket_bits = EntityTiles[flatTileIndex + bucket];

			// Bucket scalarizer - Siggraph 2017 - Improved Culling [Michal Drobot]:
			bucket_bits = WaveReadLaneFirst(WaveActiveBitOr(bucket_bits));

			[loop]
			while (bucket_bits != 0)
			{
				// Retrieve global entity index from local bucket, then remove bit from local bucket:
				const uint bucket_bit_index = firstbitlow(bucket_bits);
				const uint entity_index = bucket * 32 + bucket_bit_index;
				bucket_bits ^= 1u << bucket_bit_index;

				[branch]
				if (entity_index >= first_item && entity_index <= last_item && envmapAccumulation.a < 1)
				{
					ShaderEntity probe = load_entity(entity_index);
					if ((probe.layerMask & surface.layerMask) == 0)
						continue;

					const float4x4 probeProjection = load_entitymatrix(probe.GetMatrixIndex());
					const float3 clipSpacePos = mul(probeProjection, float4(surface.P, 1)).xyz;
					const float3 uvw = clipSpacePos.xyz * float3(0.5, -0.5, 0.5) + 0.5;
					[branch]
					if (is_saturated(uvw))
					{
						const float4 envmapColor = EnvironmentReflection_Local(surface, probe, probeProjection, clipSpacePos);
						// perform manual blending of probes:
						//  NOTE: they are sorted top-to-bottom, but blending is performed bottom-to-top
						envmapAccumulation.rgb = (1 - envmapAccumulation.a) * (envmapColor.a * envmapColor.rgb) + envmapAccumulation.rgb;
						envmapAccumulation.a = envmapColor.a + (1 - envmapColor.a) * envmapAccumulation.a;
						[branch]
						if (envmapAccumulation.a >= 1.0)
						{
							// force exit:
							bucket = SHADER_ENTITY_TILE_BUCKET_COUNT;
							break;
						}
					}
				}
				else if (entity_index > last_item)
				{
					// force exit:
					bucket = SHADER_ENTITY_TILE_BUCKET_COUNT;
					break;
				}

			}
		}
	}
#endif // DISABLE_LOCALENVPMAPS
	
	// Apply global envmap where there is no local envmap information:
	[branch]
	if (envmapAccumulation.a < 0.99)
	{
		envmapAccumulation.rgb = lerp(EnvironmentReflection_Global(surface), envmapAccumulation.rgb, envmapAccumulation.a);
	}
	lighting.indirect.specular += max(0, envmapAccumulation.rgb);
#endif // DISABLE_ENVMAPS

#ifndef DISABLE_VOXELGI
	VoxelGI(surface, lighting);
#endif //DISABLE_VOXELGI

	[branch]
	if (g_xFrame.LightArrayCount > 0)
	{
		uint4 shadow_mask_packed = 0;
#ifdef SHADOW_MASK_ENABLED
		[branch]
		if (g_xFrame.Options & OPTION_BIT_SHADOW_MASK)
		{
			shadow_mask_packed = texture_rtshadow[surface.pixel / 2];
		}
#endif // SHADOW_MASK_ENABLED

		// Loop through light buckets in the tile:
		const uint first_item = g_xFrame.LightArrayOffset;
		const uint last_item = first_item + g_xFrame.LightArrayCount - 1;
		const uint first_bucket = first_item / 32;
		const uint last_bucket = min(last_item / 32, max(0, SHADER_ENTITY_TILE_BUCKET_COUNT - 1));
		[loop]
		for (uint bucket = first_bucket; bucket <= last_bucket; ++bucket)
		{
			uint bucket_bits = EntityTiles[flatTileIndex + bucket];

			// Bucket scalarizer - Siggraph 2017 - Improved Culling [Michal Drobot]:
			bucket_bits = WaveReadLaneFirst(WaveActiveBitOr(bucket_bits));

			[loop]
			while (bucket_bits != 0)
			{
				// Retrieve global entity index from local bucket, then remove bit from local bucket:
				const uint bucket_bit_index = firstbitlow(bucket_bits);
				const uint entity_index = bucket * 32 + bucket_bit_index;
				bucket_bits ^= 1u << bucket_bit_index;

				// Check if it is a light and process:
				[branch]
				if (entity_index >= first_item && entity_index <= last_item)
				{
					ShaderEntity light = load_entity(entity_index);
					if ((light.layerMask & surface.layerMask) == 0)
						continue;

					if (light.GetFlags() & ENTITY_FLAG_LIGHT_STATIC)
					{
						continue; // static lights will be skipped (they are used in lightmap baking)
					}

					float shadow_mask = 1;
#ifdef SHADOW_MASK_ENABLED
					[branch]
					if (g_xFrame.Options & OPTION_BIT_SHADOW_MASK && light.IsCastingShadow())
					{
						uint shadow_index = entity_index - g_xFrame.LightArrayOffset;
						if (shadow_index < 16)
						{
							uint mask_shift = (shadow_index % 4) * 8;
							uint mask_bucket = shadow_index / 4;
							uint mask = (shadow_mask_packed[mask_bucket] >> mask_shift) & 0xFF;
							if (mask == 0)
							{
								continue;
							}
							shadow_mask = mask / 255.0;
						}
					}
#endif // SHADOW_MASK_ENABLED

					switch (light.GetType())
					{
					case ENTITY_TYPE_DIRECTIONALLIGHT:
					{
						DirectionalLight(light, surface, lighting, shadow_mask);
					}
					break;
					case ENTITY_TYPE_POINTLIGHT:
					{
						PointLight(light, surface, lighting, shadow_mask);
					}
					break;
					case ENTITY_TYPE_SPOTLIGHT:
					{
						SpotLight(light, surface, lighting, shadow_mask);
					}
					break;
					}
				}
				else if (entity_index > last_item)
				{
					// force exit:
					bucket = SHADER_ENTITY_TILE_BUCKET_COUNT;
					break;
				}

			}
		}
	}


#ifndef TRANSPARENT
	[branch]
	if (g_xFrame.Options & OPTION_BIT_SURFELGI_ENABLED && surfel_cellvalid(surfel_cell(surface.P)))
	{
		lighting.indirect.diffuse = texture_surfelgi[surface.pixel];
	}
#endif // TRANSPARENT

}

inline void ApplyLighting(in Surface surface, in Lighting lighting, inout float4 color)
{
	LightingPart combined_lighting = CombineLighting(surface, lighting);
	color.rgb = lerp(surface.albedo * combined_lighting.diffuse, surface.refraction.rgb, surface.refraction.a) + combined_lighting.specular;
}

inline void ApplyFog(in float distance, float3 P, float3 V, inout float4 color)
{
	const float fogAmount = GetFogAmount(distance, P, V);
	
	if (g_xFrame.Options & OPTION_BIT_REALISTIC_SKY)
	{
		const float3 skyLuminance = texture_skyluminancelut.SampleLevel(sampler_point_clamp, float2(0.5, 0.5), 0).rgb;
		color.rgb = lerp(color.rgb, skyLuminance, fogAmount);
	}
	else
	{
		const float3 V = float3(0.0, -1.0, 0.0);
		color.rgb = lerp(color.rgb, GetDynamicSkyColor(V, false, false, false, true), fogAmount);
	}
}


// OBJECT SHADER PROTOTYPE
///////////////////////////

#ifdef OBJECTSHADER_COMPILE_VS

// Vertex shader base:
PixelInput main(VertexInput input)
{
	PixelInput Out;

#ifdef OBJECTSHADER_USE_INSTANCEID
	Out.instanceID = input.GetInstancePointer().instanceID;
#endif // OBJECTSHADER_USE_INSTANCEID

	VertexSurface surface;
	surface.create(GetMaterial(), input);

	Out.pos = surface.position;

#ifndef OBJECTSHADER_USE_NOCAMERA
	Out.pos = mul(g_xCamera.VP, Out.pos);
#endif // OBJECTSHADER_USE_NOCAMERA

#ifdef OBJECTSHADER_USE_CLIPPLANE
	Out.clip = dot(surface.position, g_xCamera.ClipPlane);
#endif // OBJECTSHADER_USE_CLIPPLANE

#ifdef OBJECTSHADER_USE_POSITION3D
	Out.pos3D = surface.position.xyz;
#endif // OBJECTSHADER_USE_POSITION3D

#ifdef OBJECTSHADER_USE_COLOR
	Out.color = surface.color;
#endif // OBJECTSHADER_USE_COLOR

#ifdef OBJECTSHADER_USE_DITHERING
	Out.dither = surface.color.a;
#endif // OBJECTSHADER_USE_DITHERING

#ifdef OBJECTSHADER_USE_UVSETS
	Out.uvsets = surface.uvsets;
#endif // OBJECTSHADER_USE_UVSETS

#ifdef OBJECTSHADER_USE_ATLAS
	Out.atl = surface.atlas;
#endif // OBJECTSHADER_USE_ATLAS

#ifdef OBJECTSHADER_USE_NORMAL
	Out.nor = surface.normal;
#endif // OBJECTSHADER_USE_NORMAL

#ifdef OBJECTSHADER_USE_TANGENT
	Out.tan = surface.tangent;
#endif // OBJECTSHADER_USE_TANGENT

#ifdef OBJECTSHADER_USE_EMISSIVE
	Out.emissiveColor = surface.emissiveColor;
#endif // OBJECTSHADER_USE_EMISSIVE

#ifdef OBJECTSHADER_USE_RENDERTARGETARRAYINDEX
	const uint frustum_index = input.GetInstancePointer().GetFrustumIndex();
	Out.RTIndex = xCubemapRenderCams[frustum_index].properties.x;
#ifndef OBJECTSHADER_USE_NOCAMERA
	Out.pos = mul(xCubemapRenderCams[frustum_index].VP, surface.position);
#endif // OBJECTSHADER_USE_NOCAMERA
#endif // OBJECTSHADER_USE_RENDERTARGETARRAYINDEX

	return Out;
}

#endif // OBJECTSHADER_COMPILE_VS



#ifdef OBJECTSHADER_COMPILE_PS

// Possible switches:
//	OUTPUT_GBUFFER		-	assemble object shader for gbuffer exporting
//	PREPASS				-	assemble object shader for depth prepass rendering
//	TRANSPARENT			-	assemble object shader for forward or tile forward transparent rendering
//	ENVMAPRENDERING		-	modify object shader for envmap rendering
//	PLANARREFLECTION	-	include planar reflection sampling
//	POM					-	include parallax occlusion mapping computation
//	WATER				-	include specialized water shader code
//	TERRAIN				-	include specialized terrain material blending code


#ifdef DISABLE_ALPHATEST
[earlydepthstencil]
#endif // DISABLE_ALPHATEST


// entry point:
#ifdef PREPASS
uint2 main(PixelInput input, in uint primitiveID : SV_PrimitiveID) : SV_TARGET
#else
float4 main(PixelInput input, in bool is_frontface : SV_IsFrontFace) : SV_TARGET
#endif // PREPASS


// Pixel shader base:
{
	const float depth = input.pos.z;
	const float lineardepth = input.pos.w;
	const float2 pixel = input.pos.xy;
	const float2 ScreenCoord = pixel * g_xFrame.InternalResolution_rcp;
	float3 bumpColor = 0;

#ifndef DISABLE_ALPHATEST
#ifndef TRANSPARENT
#ifndef ENVMAPRENDERING
#ifdef OBJECTSHADER_USE_DITHERING
	// apply dithering:
	clip(dither(pixel + GetTemporalAASampleRotation()) - (1 - input.dither));
#endif // OBJECTSHADER_USE_DITHERING
#endif // DISABLE_ALPHATEST
#endif // TRANSPARENT
#endif // ENVMAPRENDERING


	Surface surface;
	surface.init();


#ifdef OBJECTSHADER_USE_NORMAL
	if (is_frontface == false)
	{
		input.nor = -input.nor;
	}
	surface.N = normalize(input.nor);
#endif // OBJECTSHADER_USE_NORMAL

#ifdef OBJECTSHADER_USE_POSITION3D
	surface.P = input.pos3D;
	surface.V = g_xCamera.CamPos - surface.P;
	float dist = length(surface.V);
	surface.V /= dist;
#endif // OBJECTSHADER_USE_POSITION3D

#ifdef OBJECTSHADER_USE_TANGENT
#if 0
	float3x3 TBN = compute_tangent_frame(surface.N, surface.P, input.uvsets.xy);
#else
	float4 tangent = input.tan;
	tangent.xyz = normalize(tangent.xyz);
	float3 binormal = normalize(cross(tangent.xyz, surface.N) * tangent.w);
	float3x3 TBN = float3x3(tangent.xyz, binormal, surface.N);
#endif

#ifdef POM
	ParallaxOcclusionMapping(input.uvsets, surface.V, TBN);
#endif // POM

#endif // OBJECTSHADER_USE_TANGENT



	float4 color = 1;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
#ifdef PREPASS
	if (GetMaterial().uvset_baseColorMap >= 0)
#else
	if (GetMaterial().uvset_baseColorMap >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
#endif // PREPASS
	{
		const float2 UV_baseColorMap = GetMaterial().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		float4 baseColorMap = texture_basecolormap.Sample(sampler_objectshader, UV_baseColorMap);
		baseColorMap.rgb = DEGAMMA(baseColorMap.rgb);
		color *= baseColorMap;
	}
#endif // OBJECTSHADER_USE_UVSETS


#ifdef OBJECTSHADER_USE_COLOR
	color *= input.color;
#endif // OBJECTSHADER_USE_COLOR



#ifndef DISABLE_ALPHATEST
	float alphatest = GetMaterial().alphaTest;
#ifndef TRANSPARENT
#ifndef ENVMAPRENDERING
	if (g_xFrame.Options & OPTION_BIT_TEMPORALAA_ENABLED)
	{
		alphatest = clamp(blue_noise(pixel, lineardepth).r, 0, 0.99);
	}
#endif // ENVMAPRENDERING
#endif // TRANSPARENT
	clip(color.a - alphatest);
#endif // DISABLE_ALPHATEST



#ifndef WATER
#ifdef OBJECTSHADER_USE_TANGENT
	NormalMapping(input.uvsets, surface.N, TBN, bumpColor);
#endif // OBJECTSHADER_USE_TANGENT
#endif // WATER


	float4 surfaceMap = 1;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
	if (GetMaterial().uvset_surfaceMap >= 0)
	{
		const float2 UV_surfaceMap = GetMaterial().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surfaceMap = texture_surfacemap.Sample(sampler_objectshader, UV_surfaceMap);
	}
#endif // OBJECTSHADER_USE_UVSETS


	float4 specularMap = 1;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
	if (GetMaterial().uvset_specularMap >= 0)
	{
		const float2 UV_specularMap = GetMaterial().uvset_specularMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		specularMap = texture_specularmap.Sample(sampler_objectshader, UV_specularMap);
		specularMap.rgb = DEGAMMA(specularMap.rgb);
	}
#endif // OBJECTSHADER_USE_UVSETS



	surface.create(GetMaterial(), color, surfaceMap, specularMap);


	// Emissive map:
	surface.emissiveColor = GetMaterial().emissiveColor;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
	if (surface.emissiveColor.a > 0 && GetMaterial().uvset_emissiveMap >= 0)
	{
		const float2 UV_emissiveMap = GetMaterial().uvset_emissiveMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		float4 emissiveMap = texture_emissivemap.Sample(sampler_objectshader, UV_emissiveMap);
		emissiveMap.rgb = DEGAMMA(emissiveMap.rgb);
		surface.emissiveColor *= emissiveMap;
	}
#endif // OBJECTSHADER_USE_UVSETS



#ifdef TERRAIN
	surface.N = 0;
	surface.albedo = 0;
	surface.f0 = 0;
	surface.roughness = 0;
	surface.occlusion = 0;
	surface.emissiveColor = 0;

	float4 sam;
	float4 blend_weights = input.color;
	blend_weights /= blend_weights.x + blend_weights.y + blend_weights.z + blend_weights.w;
	float3 baseN = normalize(input.nor);

	[branch]
	if (blend_weights.x > 0)
	{
		float4 color2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial().uvset_baseColorMap >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
		{
			float2 uv = GetMaterial().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			color2 = texture_basecolormap.Sample(sampler_objectshader, uv);
			color2.rgb = DEGAMMA(color2.rgb);
		}
#endif // OBJECTSHADER_USE_UVSETS

		float4 surfaceMap2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial().uvset_surfaceMap >= 0)
		{
			float2 uv = GetMaterial().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			surfaceMap2 = texture_surfacemap.Sample(sampler_objectshader, uv);
		}
#endif // OBJECTSHADER_USE_UVSETS

		Surface surface2;
		surface2.N = baseN;
		surface2.create(GetMaterial(), color2, surfaceMap2);

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial().normalMapStrength > 0 && GetMaterial().uvset_normalMap >= 0)
		{
			float2 uv = GetMaterial().uvset_normalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam.rgb = texture_normalmap.Sample(sampler_objectshader, uv).rgb;
			sam.rgb = sam.rgb * 2 - 1;
			surface2.N = lerp(baseN, mul(sam.rgb, TBN), GetMaterial().normalMapStrength);
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface2.emissiveColor = GetMaterial().emissiveColor;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial().uvset_emissiveMap >= 0 && any(GetMaterial().emissiveColor))
		{
			float2 uv = GetMaterial().uvset_emissiveMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam = texture_emissivemap.Sample(sampler_objectshader, uv);
			sam.rgb = DEGAMMA(sam.rgb);
			surface2.emissiveColor *= sam;
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface.N += surface2.N * blend_weights.x;
		surface.albedo += surface2.albedo * blend_weights.x;
		surface.f0 += surface2.f0 * blend_weights.x;
		surface.roughness += surface2.roughness * blend_weights.x;
		surface.occlusion += surface2.occlusion * blend_weights.x;
		surface.emissiveColor += surface2.emissiveColor * blend_weights.x;
	}

	[branch]
	if (blend_weights.y > 0)
	{
		float4 color2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial1().uvset_baseColorMap >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
		{
			float2 uv = GetMaterial1().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			color2 = texture_blend1_basecolormap.Sample(sampler_objectshader, uv);
			color2.rgb = DEGAMMA(color2.rgb);
		}
#endif // OBJECTSHADER_USE_UVSETS

		float4 surfaceMap2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial1().uvset_surfaceMap >= 0)
		{
			float2 uv = GetMaterial1().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			surfaceMap2 = texture_blend1_surfacemap.Sample(sampler_objectshader, uv);
		}
#endif // OBJECTSHADER_USE_UVSETS

		Surface surface2;
		surface2.N = baseN;
		surface2.create(GetMaterial1(), color2, surfaceMap2);

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial1().normalMapStrength > 0 && GetMaterial1().uvset_normalMap >= 0)
		{
			float2 uv = GetMaterial1().uvset_normalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam.rgb = texture_blend1_normalmap.Sample(sampler_objectshader, uv).rgb;
			sam.rgb = sam.rgb * 2 - 1;
			surface2.N = lerp(baseN, mul(sam.rgb, TBN), GetMaterial1().normalMapStrength);
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface2.emissiveColor = GetMaterial1().emissiveColor;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial1().uvset_emissiveMap >= 0 && any(GetMaterial().emissiveColor))
		{
			float2 uv = GetMaterial1().uvset_emissiveMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam = texture_blend1_emissivemap.Sample(sampler_objectshader, uv);
			sam.rgb = DEGAMMA(sam.rgb);
			surface2.emissiveColor *= sam;
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface.N += surface2.N * blend_weights.y;
		surface.albedo += surface2.albedo * blend_weights.y;
		surface.f0 += surface2.f0 * blend_weights.y;
		surface.roughness += surface2.roughness * blend_weights.y;
		surface.occlusion += surface2.occlusion * blend_weights.y;
		surface.emissiveColor += surface2.emissiveColor * blend_weights.y;
	}

	[branch]
	if (blend_weights.z > 0)
	{
		float4 color2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial2().uvset_baseColorMap >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
		{
			float2 uv = GetMaterial2().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			color2 = texture_blend2_basecolormap.Sample(sampler_objectshader, uv);
			color2.rgb = DEGAMMA(color2.rgb);
		}
#endif // OBJECTSHADER_USE_UVSETS

		float4 surfaceMap2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial2().uvset_surfaceMap >= 0)
		{
			float2 uv = GetMaterial2().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			surfaceMap2 = texture_blend2_surfacemap.Sample(sampler_objectshader, uv);
		}
#endif // OBJECTSHADER_USE_UVSETS

		Surface surface2;
		surface2.N = baseN;
		surface2.create(GetMaterial2(), color2, surfaceMap2);

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial2().normalMapStrength > 0 && GetMaterial2().uvset_normalMap >= 0)
		{
			float2 uv = GetMaterial2().uvset_normalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam.rgb = texture_blend2_normalmap.Sample(sampler_objectshader, uv).rgb;
			sam.rgb = sam.rgb * 2 - 1;
			surface2.N = lerp(baseN, mul(sam.rgb, TBN), GetMaterial2().normalMapStrength);
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface2.emissiveColor = GetMaterial2().emissiveColor;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial2().uvset_emissiveMap >= 0 && any(GetMaterial2().emissiveColor))
		{
			float2 uv = GetMaterial2().uvset_emissiveMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam = texture_blend2_emissivemap.Sample(sampler_objectshader, uv);
			sam.rgb = DEGAMMA(sam.rgb);
			surface2.emissiveColor *= sam;
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface.N += surface2.N * blend_weights.z;
		surface.albedo += surface2.albedo * blend_weights.z;
		surface.f0 += surface2.f0 * blend_weights.z;
		surface.roughness += surface2.roughness * blend_weights.z;
		surface.occlusion += surface2.occlusion * blend_weights.z;
		surface.emissiveColor += surface2.emissiveColor * blend_weights.z;
	}

	[branch]
	if (blend_weights.w > 0)
	{
		float4 color2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial3().uvset_baseColorMap >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
		{
			float2 uv = GetMaterial3().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			color2 = texture_blend3_basecolormap.Sample(sampler_objectshader, uv);
			color2.rgb = DEGAMMA(color2.rgb);
		}
#endif // OBJECTSHADER_USE_UVSETS

		float4 surfaceMap2 = 1;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial3().uvset_surfaceMap >= 0)
		{
			float2 uv = GetMaterial3().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			surfaceMap2 = texture_blend3_surfacemap.Sample(sampler_objectshader, uv);
		}
#endif // OBJECTSHADER_USE_UVSETS

		Surface surface2;
		surface2.N = baseN;
		surface2.create(GetMaterial3(), color2, surfaceMap2);

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial3().normalMapStrength > 0 && GetMaterial3().uvset_normalMap >= 0)
		{
			float2 uv = GetMaterial3().uvset_normalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam.rgb = texture_blend3_normalmap.Sample(sampler_objectshader, uv).rgb;
			sam.rgb = sam.rgb * 2 - 1;
			surface2.N = lerp(baseN, mul(sam.rgb, TBN), GetMaterial3().normalMapStrength);
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface2.emissiveColor = GetMaterial3().emissiveColor;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial3().uvset_emissiveMap >= 0 && any(GetMaterial3().emissiveColor))
		{
			float2 uv = GetMaterial3().uvset_emissiveMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			sam = texture_blend3_emissivemap.Sample(sampler_objectshader, uv);
			sam.rgb = DEGAMMA(sam.rgb);
			surface2.emissiveColor *= sam;
		}
#endif // OBJECTSHADER_USE_UVSETS

		surface.N += surface2.N * blend_weights.w;
		surface.albedo += surface2.albedo * blend_weights.w;
		surface.f0 += surface2.f0 * blend_weights.w;
		surface.roughness += surface2.roughness * blend_weights.w;
		surface.occlusion += surface2.occlusion * blend_weights.w;
		surface.emissiveColor += surface2.emissiveColor * blend_weights.w;
	}

	surface.N = normalize(surface.N);

#endif // TERRAIN



#ifdef OBJECTSHADER_USE_EMISSIVE
	surface.emissiveColor *= unpack_rgba(input.emissiveColor);
#endif // OBJECTSHADER_USE_EMISSIVE


#ifdef OBJECTSHADER_USE_UVSETS
	// Secondary occlusion map:
	[branch]
	if (GetMaterial().IsOcclusionEnabled_Secondary() && GetMaterial().uvset_occlusionMap >= 0)
	{
		const float2 UV_occlusionMap = GetMaterial().uvset_occlusionMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surface.occlusion *= texture_occlusionmap.Sample(sampler_objectshader, UV_occlusionMap).r;
	}
#endif // OBJECTSHADER_USE_UVSETS


#ifndef PREPASS
#ifndef ENVMAPRENDERING
#ifndef TRANSPARENT
	surface.occlusion *= texture_ao.SampleLevel(sampler_linear_clamp, ScreenCoord, 0).r;
#endif // TRANSPARENT
#endif // ENVMAPRENDERING
#endif // PREPASS


#ifdef BRDF_ANISOTROPIC
	surface.anisotropy = GetMaterial().parallaxOcclusionMapping;
	surface.T = tangent.xyz;
	surface.B = normalize(cross(tangent.xyz, surface.N) * tangent.w); // Compute bitangent again after normal mapping
#endif // BRDF_ANISOTROPIC


#ifdef BRDF_SHEEN
	surface.sheen.color = GetMaterial().sheenColor.rgb;
	surface.sheen.roughness = GetMaterial().sheenRoughness;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
	if (GetMaterial().uvset_sheenColorMap >= 0)
	{
		const float2 UV_sheenColorMap = GetMaterial().uvset_sheenColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surface.sheen.color *= DEGAMMA(texture_sheencolormap.Sample(sampler_objectshader, UV_sheenColorMap).rgb);
	}
	[branch]
	if (GetMaterial().uvset_sheenRoughnessMap >= 0)
	{
		const float2 uvset_sheenRoughnessMap = GetMaterial().uvset_sheenRoughnessMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surface.sheen.roughness *= texture_sheenroughnessmap.Sample(sampler_objectshader, uvset_sheenRoughnessMap).a;
	}
#endif // OBJECTSHADER_USE_UVSETS
#endif // BRDF_SHEEN


#ifdef BRDF_CLEARCOAT
	surface.clearcoat.factor = GetMaterial().clearcoat;
	surface.clearcoat.roughness = GetMaterial().clearcoatRoughness;
	surface.clearcoat.N = input.nor;

#ifdef OBJECTSHADER_USE_UVSETS
	[branch]
	if (GetMaterial().uvset_clearcoatMap >= 0)
	{
		const float2 UV_clearcoatMap = GetMaterial().uvset_clearcoatMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surface.clearcoat.factor *= texture_clearcoatmap.Sample(sampler_objectshader, UV_clearcoatMap).r;
	}
	[branch]
	if (GetMaterial().uvset_clearcoatRoughnessMap >= 0)
	{
		const float2 uvset_clearcoatRoughnessMap = GetMaterial().uvset_clearcoatRoughnessMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surface.clearcoat.roughness *= texture_clearcoatroughnessmap.Sample(sampler_objectshader, uvset_clearcoatRoughnessMap).g;
	}
#ifdef OBJECTSHADER_USE_TANGENT
	[branch]
	if (GetMaterial().uvset_clearcoatNormalMap >= 0)
	{
		const float2 uvset_clearcoatNormalMap = GetMaterial().uvset_clearcoatNormalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		float3 clearcoatNormalMap = texture_clearcoatnormalmap.Sample(sampler_objectshader, uvset_clearcoatNormalMap).rgb;
		clearcoatNormalMap.b = clearcoatNormalMap.b == 0 ? 1 : clearcoatNormalMap.b; // fix for missing blue channel
		clearcoatNormalMap = clearcoatNormalMap * 2 - 1;
		surface.clearcoat.N = mul(clearcoatNormalMap, TBN);
	}
#endif // OBJECTSHADER_USE_TANGENT

	surface.clearcoat.N = normalize(surface.clearcoat.N);

#endif // OBJECTSHADER_USE_UVSETS
#endif // BRDF_CLEARCOAT


	surface.sss = GetMaterial().subsurfaceScattering;
	surface.sss_inv = GetMaterial().subsurfaceScattering_inv;

	surface.pixel = pixel;
	surface.screenUV = ScreenCoord;

	surface.layerMask = GetMaterial().layerMask;

	surface.update();

	float3 ambient = GetAmbient(surface.N);
	ambient = lerp(ambient, ambient * surface.sss.rgb, saturate(surface.sss.a));

	Lighting lighting;
	lighting.create(0, 0, ambient, 0);



#ifdef WATER

	//NORMALMAP
	float2 bumpColor0 = 0;
	float2 bumpColor1 = 0;
	float2 bumpColor2 = 0;
	[branch]
	if (GetMaterial().uvset_normalMap >= 0)
	{
		const float2 UV_normalMap = GetMaterial().uvset_normalMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		bumpColor0 = 2 * texture_normalmap.Sample(sampler_objectshader, UV_normalMap - GetMaterial().texMulAdd.ww).rg - 1;
		bumpColor1 = 2 * texture_normalmap.Sample(sampler_objectshader, UV_normalMap + GetMaterial().texMulAdd.zw).rg - 1;
	}
	bumpColor2 = texture_waterriples.SampleLevel(sampler_linear_clamp, ScreenCoord, 0).rg;
	bumpColor = float3(bumpColor0 + bumpColor1 + bumpColor2, 1)  * GetMaterial().refraction;
	surface.N = normalize(lerp(surface.N, mul(normalize(bumpColor), TBN), GetMaterial().normalMapStrength));
	bumpColor *= GetMaterial().normalMapStrength;

	//REFLECTION
	float4 reflectionUV = mul(g_xCamera.ReflVP, float4(surface.P, 1));
	reflectionUV.xy /= reflectionUV.w;
	reflectionUV.xy = reflectionUV.xy * float2(0.5, -0.5) + 0.5;
	lighting.indirect.specular += texture_reflection.SampleLevel(sampler_linear_mirror, reflectionUV.xy + bumpColor.rg, 0).rgb * surface.F;
#endif // WATER



#ifdef TRANSPARENT
	[branch]
	if (GetMaterial().transmission > 0)
	{
		surface.transmission = GetMaterial().transmission;

#ifdef OBJECTSHADER_USE_UVSETS
		[branch]
		if (GetMaterial().uvset_transmissionMap >= 0)
		{
			const float2 UV_transmissionMap = GetMaterial().uvset_transmissionMap == 0 ? input.uvsets.xy : input.uvsets.zw;
			float transmissionMap = texture_transmissionmap.Sample(sampler_objectshader, UV_transmissionMap).r;
			surface.transmission *= transmissionMap;
		}
#endif // OBJECTSHADER_USE_UVSETS

		float2 size;
		float mipLevels;
		texture_refraction.GetDimensions(0, size.x, size.y, mipLevels);
		const float2 normal2D = mul((float3x3)g_xCamera.View, surface.N.xyz).xy;
		float2 perturbatedRefrTexCoords = ScreenCoord.xy + normal2D * GetMaterial().refraction;
		float4 refractiveColor = texture_refraction.SampleLevel(sampler_linear_clamp, perturbatedRefrTexCoords, surface.roughness * mipLevels);
		surface.refraction.rgb = surface.albedo * refractiveColor.rgb;
		surface.refraction.a = surface.transmission;
	}
#endif // TRANSPARENT


#ifdef OBJECTSHADER_USE_ATLAS
	LightMapping(load_instance(input.instanceID).lightmap, input.atl, lighting);
#endif // OBJECTSHADER_USE_ATLAS


#ifdef OBJECTSHADER_USE_EMISSIVE
	ApplyEmissive(surface, lighting);
#endif // OBJECTSHADER_USE_EMISSIVE


#ifdef PLANARREFLECTION
	lighting.indirect.specular += PlanarReflection(surface, bumpColor.rg) * surface.F;
#endif


#ifdef FORWARD
	ForwardLighting(surface, lighting);
#endif // FORWARD


#ifdef TILEDFORWARD
	TiledLighting(surface, lighting);
#endif // TILEDFORWARD


#ifndef WATER
#ifndef ENVMAPRENDERING
#ifndef TRANSPARENT
	float4 ssr = texture_ssr.SampleLevel(sampler_linear_clamp, ScreenCoord, 0);
	lighting.indirect.specular = lerp(lighting.indirect.specular, ssr.rgb * surface.F, ssr.a);
#endif // TRANSPARENT
#endif // ENVMAPRENDERING
#endif // WATER


#ifdef WATER
	// WATER REFRACTION
	float sampled_lineardepth = texture_lineardepth.SampleLevel(sampler_point_clamp, ScreenCoord.xy + bumpColor.rg, 0) * g_xCamera.ZFarP;
	float depth_difference = sampled_lineardepth - lineardepth;
	surface.refraction.rgb = texture_refraction.SampleLevel(sampler_linear_mirror, ScreenCoord.xy + bumpColor.rg * saturate(0.5 * depth_difference), 0).rgb;
	if (depth_difference < 0)
	{
		// Fix cutoff by taking unperturbed depth diff to fill the holes with fog:
		sampled_lineardepth = texture_lineardepth.SampleLevel(sampler_point_clamp, ScreenCoord.xy, 0) * g_xCamera.ZFarP;
		depth_difference = sampled_lineardepth - lineardepth;
	}
	// WATER FOG:
	surface.refraction.a = 1 - saturate(color.a * 0.1 * depth_difference);
	color.a = 1;
#endif // WATER


#ifdef UNLIT
	lighting.direct.diffuse = 1;
	lighting.indirect.diffuse = 0;
	lighting.direct.specular = 0;
	lighting.indirect.specular = 0;
#endif // UNLIT


	ApplyLighting(surface, lighting, color);


#ifdef OBJECTSHADER_USE_POSITION3D
	ApplyFog(dist, g_xCamera.CamPos, surface.V, color);
#endif // OBJECTSHADER_USE_POSITION3D


	color = max(0, color);


	// end point:
#ifdef PREPASS
	PrimitiveID prim;
	prim.primitiveIndex = primitiveID;
	prim.instanceIndex = input.instanceID;
	prim.subsetIndex = GetSubsetIndex();
	return prim.pack();
#else
	return color;
#endif // PREPASS

}


#endif // OBJECTSHADER_COMPILE_PS



#endif // WI_OBJECTSHADER_HF

