#include "objectHF.hlsli"
#include "skyHF.hlsli"

float4 main(float4 pos : SV_POSITION, float2 clipspace : TEXCOORD) : SV_TARGET
{
	float4 unprojected = mul(g_xCamera.InvVP, float4(clipspace, 0.0f, 1.0f));
	unprojected.xyz /= unprojected.w;

	const float3 V = normalize(unprojected.xyz - g_xCamera.CamPos);

	float4 color = float4(DEGAMMA_SKY(texture_globalenvmap.SampleLevel(sampler_linear_clamp, V, 0).rgb), 1);
	CalculateClouds(color.rgb, V, false);

	float4 pos2DPrev = mul(g_xCamera.PrevVP, float4(unprojected.xyz, 1));
	float2 velocity = ((pos2DPrev.xy / pos2DPrev.w - g_xCamera.TemporalAAJitterPrev) - (clipspace - g_xCamera.TemporalAAJitter)) * float2(0.5f, -0.5f);

	return color;
}

