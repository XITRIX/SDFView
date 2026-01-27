//
//  SDFMetalView.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import SwiftUI
import MetalKit

struct SDFInputs: Equatable {
    var shapes: [SDFShape] = []
    var smoothK: Float = 40   // pixels, tweak later
    var displayScale: Float = 1
    var globalOffset: SIMD2<Float> = .zero
}

struct SDFMetalView: UIViewRepresentable {
    var inputs: SDFInputs
    @Environment(\.displayScale) private var displayScale

    final class Coordinator: NSObject, MTKViewDelegate {
        var renderer: SDFRenderer!

        init(_ parent: SDFMetalView) {
            super.init()
            self.renderer = SDFRenderer()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.drawableSize = size
        }

        func draw(in view: MTKView) {
            renderer.draw(in: view)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        view.colorPixelFormat = .bgra8Unorm
        view.isOpaque = false
        view.framebufferOnly = true
//        view.isPaused = true
//        view.enableSetNeedsDisplay = true
//        view.preferredFramesPerSecond = 120

        view.delegate = context.coordinator
        context.coordinator.renderer.configure(with: view.device!)

        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        var v = inputs
        v.displayScale = Float(displayScale)
        context.coordinator.renderer.inputs = v
//        uiView.setNeedsDisplay()
//        uiView.draw()
    }
}
