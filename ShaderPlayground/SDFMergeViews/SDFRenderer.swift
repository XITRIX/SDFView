//
//  SDFRenderer.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import Metal
import MetalKit
import simd

final class SDFRenderer {
    private var device: MTLDevice!
    private var queue: MTLCommandQueue!
    private var pipeline: MTLRenderPipelineState!

    var inputs = SDFInputs()
    var drawableSize: CGSize = .zero

    struct Uniforms {
        var resolution: SIMD2<Float>
        var time: Float
        var shapeCount: UInt32
        var smoothK: Float
    }

    private var startTime = CACurrentMediaTime()

    func configure(with device: MTLDevice) {
        self.device = device
        self.queue = device.makeCommandQueue()

        let library = device.makeDefaultLibrary()!
        let v = library.makeFunction(name: "fullscreen_vertex")!
        let f = library.makeFunction(name: "sdf_fragment")!

        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction = v
        desc.fragmentFunction = f
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm
        desc.colorAttachments[0].isBlendingEnabled = true
        desc.colorAttachments[0].rgbBlendOperation = .add
        desc.colorAttachments[0].alphaBlendOperation = .add
        desc.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        desc.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        desc.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        desc.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        pipeline = try! device.makeRenderPipelineState(descriptor: desc)
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let pass = view.currentRenderPassDescriptor
        else { return }

        let cmd = queue.makeCommandBuffer()!
        let enc = cmd.makeRenderCommandEncoder(descriptor: pass)!
        enc.setRenderPipelineState(pipeline)

        let t = Float(CACurrentMediaTime() - startTime)
        let scale = max(inputs.displayScale, 1)
        var u = Uniforms(
            resolution: SIMD2(Float(drawableSize.width), Float(drawableSize.height)),
            time: t,
            shapeCount: UInt32(inputs.shapes.count),
            smoothK: inputs.smoothK * scale
        )

        enc.setFragmentBytes(&u, length: MemoryLayout<Uniforms>.stride, index: 0)

        if !inputs.shapes.isEmpty {
            enc.setFragmentBytes(inputs.shapes,
                                 length: MemoryLayout<SDFShape>.stride * inputs.shapes.count,
                                 index: 1)
        }

        // 2 triangles for a fullscreen quad via vertex shader generating positions
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

        enc.endEncoding()
        cmd.present(drawable)
        cmd.commit()
    }
}
