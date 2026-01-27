#include <metal_stdlib>
using namespace metal;

inline float sdCircle(float2 p, float r) {
    return length(p) - r;
}

inline float sdRoundRect(float2 p, float2 b, float r) {
    float2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

inline half fillAA(float d) {
    float w = fwidth(d);
    return half(smoothstep(0.0, w, -d));
}

inline float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

[[stitchable]]
half4 sdfMorphShadertoy(float2 position,
                        half4 /*inColor*/,
                        float2 size,   // pixels
                        float time,    // seconds
                        float morph)   // 0..1
{
    // ShaderToy-ish:
    // fragCoord = position
    // iResolution = size
    // iTime = time

    // uv in 0..1
    float2 uv = position / size;

    // p centered at 0, aspect-corrected, roughly -1..1
    float2 p = (uv - 0.5) * 2.0;
    p.x *= size.x / size.y;

    // Optional: add a tiny "life" wobble using time
    float wobble = 0.03 * sin(time * 2.0);
//    p += wobble;

    // Define shapes in this normalized space
    float dA = sdCircle(p, 0.55);                       // circle radius
    float dB = sdRoundRect(p, float2(0.70, 0.42), 0.20); // half-size + corner radius

    float t = clamp(morph, 0.0, 1.0);

    // "morph" by sliding between a smooth-union and a smooth-intersection feel:
    // simplest practical: blend the *fields* but with extra smoothing around the transition.
    float k = mix(0.02, 0.22, 0.5 - 0.5*cos(t * 3.1415926)); // ease k over time
    float d = mix(dA, dB, t);
    d = smin(d, d, k);                   // re-smooth edges a bit (stabilizes look)
    
    half a = fillAA(d);

    // stroke: 1 in a thin band around the surface
    float strokePx = 2.0;
    float fw = fwidth(d);
    half stroke = half(1.0 - smoothstep(0.0, fw, fabs(d) - strokePx * fw));

    // base “main” color follows morph (no constant two colors)
    half3 colA = half3(0.2h, 0.7h, 1.0h);
    half3 colB = half3(1.0h, 0.4h, 0.8h);
    half3 baseColor = mix(colA, colB, half(t));

    // per-shape “who dominates” color (but we’ll apply it only near the edge)
    float band = 0.03;
    float w = smoothstep(-band, band, dA - dB);         // 0..1
    half3 domColor = mix(colA, colB, half(w));

    // edge mask: 1 near the surface, 0 deep inside/outside
    float edgeWidth = 0.04;
    half edge = half(1.0 - smoothstep(0.0, edgeWidth, fabs(d)));

    // final: mostly baseColor, with domColor only near the edge
    half3 shapeColor = mix(baseColor, domColor, edge);

    half3 bg = half3(0.0h);

    // Fill alpha (inside shape)
    half fillA = a;

    // Stroke alpha (outline only)
    half strokeA = stroke;

    // Combine: stroke sits on top of fill
    half outA = max(fillA, strokeA);

    // Colors
    half3 fillCol = shapeColor;
    half3 strokeCol = half3(1.0h);

    // “Over” compositing in premultiplied space (stroke over fill)
    half3 premulFill = fillCol * fillA;
    half3 premulStroke = strokeCol * strokeA;
    half3 outRGB = premulStroke + premulFill * (1.0h - strokeA);

    // Return premultiplied RGBA with transparent outside
    return half4(outRGB, outA);
}
