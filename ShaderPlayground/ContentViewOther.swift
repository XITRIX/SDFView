//
//  ContentViewOther.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 23.01.2026.
//

import SwiftUI
internal import Combine

struct ContentViewOther: View {
    @State private var start = Date()

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { geo in
                let t = Float(timeline.date.timeIntervalSince(start)) // small, precise
                let m = Float(0.5 + 0.5 * sin(Double(t)))

                Rectangle()
                    .colorEffect(
                        Shader(
                            function: .init(library: .default, name: "sdfMorphShadertoy"),
                            arguments: [
                                .float2(Float(geo.size.width), Float(geo.size.height)),
                                .float(t),
                                .float(m)
                            ]
                        )
                    )
            }
        }
        .frame(width: 380, height: 220)
        .padding()
    }
}

#Preview {
    ContentViewOther()
}
