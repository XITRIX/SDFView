//
//  SDFItem.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import SwiftUI

struct SDFItem<Content: View>: View {
    let id: UUID
    let radius: CGFloat
    let extraOffset: CGSize
    @ViewBuilder var content: Content

    private var color: Color

    init(
        id: UUID = UUID(),
        radius: CGFloat = 40,
        color: Color = .white,
        extraOffset: CGSize = .zero,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.radius = radius
        self.extraOffset = extraOffset
        self.color = color
        self.content = content()
    }

    var body: some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: SDFItemSpecKey.self,
                            value: [SDFItemSpec(
                                id: id,
                                rect: geo.frame(in: .named("SDFGroupSpace")),
                                radius: radius,
                                color: color
                            )]
                        )
                }
            )
    }
}
