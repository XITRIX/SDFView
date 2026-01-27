//
//  SDFGroup.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import SwiftUI
import simd

struct SDFGroup<Content: View>: View {
    @State private var inputs = SDFInputs()
    @ViewBuilder var content: Content

    @Environment(\.displayScale) private var displayScale: CGFloat

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            SDFMetalView(inputs: inputs)
                .ignoresSafeArea()

            content
        }
        .coordinateSpace(name: "SDFGroupSpace")
        .overlayPreferenceValue(SDFItemSpecKey.self) { specs in
            GeometryReader { proxy in
                Color.clear
                    .onAppear { updateInputs(specs: specs, proxy: proxy) }
                    .onChange(of: specs) { _, newSpecs in
                        updateInputs(specs: newSpecs, proxy: proxy)
                    }
            }
        }
    }

    private func updateInputs(specs: [SDFItemSpec], proxy: GeometryProxy) {
        let size = proxy.size
        let sorted = specs.sorted { $0.id.uuidString < $1.id.uuidString }

        let maxShapes = 64
        var shapes: [SDFShape] = []
        shapes.reserveCapacity(min(sorted.count, maxShapes))

        let scale = Float(displayScale) // ✅ points -> pixels

        for spec in sorted.prefix(maxShapes) {
            let rect = spec.rect

            // points
            let cxPt = rect.midX - size.width / 2
            let cyPt = (size.height / 2) - rect.midY

            // pixels
            let cx = Float(cxPt) * scale
            let cy = Float(cyPt) * scale
            let r  = Float(spec.radius) * scale

            let w = Float(rect.width) * scale
            let h = Float(rect.height) * scale

            let half = SIMD2(w/2, h/2)

            shapes.append(
                SDFShape(
                    center: SIMD2(Float(cxPt) * scale, Float(cyPt) * scale),
                    halfSize: half,
                    radius: Float(spec.radius) * scale,  // treat SDFItem "radius" as corner radius now
                    kind: 1,
                    color: spec.color.rgbaSIMD()
                )
            )
        }

        inputs = SDFInputs(
            shapes: shapes,
            smoothK: inputs.smoothK,
            globalOffset: SIMD2(0, -4.5 * Float(displayScale))
        )
    }

}
