#define DISABLE_DECALS
#define DISABLE_ENVMAPS
#define SHADOW_MASK_ENABLED
#include "globals.hlsli"
#include "objectHF.hlsli"
#include "hairparticleHF.hlsli"

[earlydepthstencil]
float4 main(VertexToPixel input) : SV_Target
{
	ShaderMaterial material = HairGetMaterial();

	float4 color = 1;

	[branch]
	if (material.texture_basecolormap_index >= 0 && (g_xFrame.Options & OPTION_BIT_DISABLE_ALBEDO_MAPS) == 0)
	{
		color = bindless_textures[material.texture_basecolormap_index].Sample(sampler_linear_wrap, input.tex);
		color.rgb = DEGAMMA(color.rgb);
	}
	color *= material.baseColor;

	float opacity = 1;
	float3 V = g_xCamera.CamPos - input.pos3D;
	float dist = length(V);
	V /= dist;
	float emissive = 0;

	const uint2 pixel = input.pos.xy;
	const float2 ScreenCoord = pixel * g_xFrame.InternalResolution_rcp;

	Surface surface;
	surface.create(material, color, 0);
	surface.P = input.pos3D;
	surface.N = input.nor;
	surface.V = V;
	surface.pixel = input.pos.xy;

#ifndef PREPASS
#ifndef ENVMAPRENDERING
#ifndef TRANSPARENT
	surface.occlusion *= texture_ao.SampleLevel(sampler_linear_clamp, ScreenCoord, 0).r;
#endif // TRANSPARENT
#endif // ENVMAPRENDERING
#endif // PREPASS

	surface.update();

	Lighting lighting;
	lighting.create(0, 0, GetAmbient(surface.N), 0);

	float depth = input.pos.z;
	float3 reflection = 0;

	TiledLighting(surface, lighting);


	ApplyLighting(surface, lighting, color);

	ApplyFog(dist, g_xCamera.CamPos, V, color);

	return color;
}
