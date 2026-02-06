//
//  SDFShaders.metal
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

#include <metal_stdlib>
using namespace metal;

struct VOut {
    float4 position [[position]];
    float2 uv;
};

vertex VOut fullscreen_vertex(uint vid [[vertex_id]]) {
    float2 pos[6] = {
        {-1, -1}, { 1, -1}, {-1,  1},
        {-1,  1}, { 1, -1}, { 1,  1},
    };

    VOut o;
    o.position = float4(pos[vid], 0, 1);
    o.uv = (pos[vid] * 0.5 + 0.5); // 0..1
    return o;
}

struct Shape {
    float2 center;
    float2 halfSize;
    float radius;
    uint kind;
    float4 color;
    float2 _pad;
};

struct Uniforms {
    float2 resolution;
    float time;
    uint shapeCount;
    float smoothK;
};

float sdCircle(float2 p, float r) {
    return length(p) - r;
}

float sdRoundRect(float2 p, float2 b, float r) {
    // p: point relative to center
    // b: half-size
    float2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float smin(float a, float b, float k) {
    // Polynomial smooth min (cheap and common)
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

fragment float4 sdf_fragment(VOut in [[stage_in]],
                             constant Uniforms& u [[buffer(0)]],
                             constant Shape* shapes [[buffer(1)]]) {
    float2 p = (in.uv - 0.5) * float2(u.resolution.x, u.resolution.y);

    float dUnion = 1e9;

    float3 accum = float3(0.0);
    float wsum = 0.0;

    float falloff = 0.08; // tweak later; units are "per pixel"

    for (uint i = 0; i < u.shapeCount; i++) {
        float2 c = shapes[i].center;
        float2 local = p - c;

        float di;
        if (shapes[i].kind == 0) {
            di = sdCircle(local, shapes[i].radius);
        } else {
            di = sdRoundRect(local, shapes[i].halfSize, shapes[i].radius);
        }

        dUnion = (i == 0) ? di : smin(dUnion, di, u.smoothK);

        // Weighting: stronger influence inside/near the surface
        float w = exp(-max(di, 0.0) * falloff); // outside decays; inside stays ~1
        accum += shapes[i].color.rgb * w;
        wsum += w;
    }

    float3 col = (wsum > 0.0) ? (accum / wsum) : float3(1.0);

    // Base fill alpha from the SDF edge with antialiasing
    float aa = fwidth(dUnion);
    float fillA = smoothstep(aa, -aa, dUnion);

    // Edge highlight (rim) near the surface using screen-space derivatives
    float edgeBand = 2.5; // pixels around the edge
    float edgeMask = 1.0 - smoothstep(0.0, edgeBand, abs(dUnion));

    // Approximate normal from screen-space derivatives of the distance field
    float2 grad = float2(dfdx(dUnion), dfdy(dUnion));
    float2 n = (length(grad) > 1e-5) ? normalize(grad) : float2(0.0, 1.0);

    // Fake light coming from top-left
    float2 L = normalize(float2(-0.6, 0.8));
    float rim = pow(saturate(1.0 - dot(n, L)), 3.0) * edgeMask;

    // Compose: fill only inside, add rim highlight at the edge (no outer glow)
    float3 outRGB = col * fillA + rim * 0.35;
    float outA = fillA;

    return float4(outRGB, outA);
}

