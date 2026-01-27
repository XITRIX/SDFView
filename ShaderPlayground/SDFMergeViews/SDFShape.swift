//
//  SDFShape.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import simd

/// Must match the Metal struct layout (16 bytes).
struct SDFShape: Equatable {
    var center: SIMD2<Float>     // pixels
    var halfSize: SIMD2<Float>   // pixels (for rect)
    var radius: Float            // pixels (for circle OR corner radius)
    var kind: UInt32             // 0=circle, 1=roundRect
    var color: SIMD4<Float>     // RGBA 0..1
    var _pad: UInt32 = 0
}
