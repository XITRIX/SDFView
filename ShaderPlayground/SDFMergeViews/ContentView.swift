//
//  ContentView.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var sdfSmooth: Double = 14
    @State private var lqgSmooth: Double = 14
    var body: some View {
        VStack {
            VStack {
                ZStack {
                    Color(.secondarySystemBackground).ignoresSafeArea()
                    SDFGroup(smooth: sdfSmooth) {
                        VStack(spacing: 60) {
                            DraggableItem(radius: 18, color: .red) {
                                Text("One").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))

                            }
                            DraggableItem(radius: 18, color: .green) {
                                Text("Two").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                            DraggableItem(radius: 18, color: .blue) {
                                Text("Three").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                        }
                        .padding()
                    }
                }
                Slider(value: $sdfSmooth, in: 0 ... 40)
            }

            VStack {
                ZStack {
                    Color(.secondarySystemBackground).ignoresSafeArea()
                    GlassEffectContainer(spacing: lqgSmooth) {
                        VStack(spacing: 60) {
                            GlassDraggableItem(radius: 18, color: .red) {
                                Text("One").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))

                            }
                            GlassDraggableItem(radius: 18, color: .green) {
                                Text("Two").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                            GlassDraggableItem(radius: 18, color: .blue) {
                                Text("Three").padding()
                                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                        }
                        .padding()
                    }
                }
                Slider(value: $lqgSmooth, in: 0 ... 40)
            }
        }
//        .ignoresSafeArea()
    }
}

struct DraggableItem<Content: View>: View {
    let id = UUID()

    let radius: CGFloat
    let color: Color
    let baseOffset: CGSize
    @ViewBuilder var content: Content

    @State private var committed: CGSize = .zero     // persists between drags
    @GestureState private var dragging: CGSize = .zero // live during drag only

    init(radius: CGFloat, color: Color = .white, baseOffset: CGSize = .zero, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.baseOffset = baseOffset
        self.color = color
        self.content = content()
    }

    var body: some View {
        let total = CGSize(
            width: baseOffset.width + committed.width + dragging.width,
            height: baseOffset.height + committed.height + dragging.height
        )

        SDFItem(id: id, radius: radius, color: color) { content }
            .offset(total)
            .gesture(
                DragGesture()
                    .updating($dragging) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        committed.width += value.translation.width
                        committed.height += value.translation.height
                    }
            )
    }
}

struct GlassDraggableItem<Content: View>: View {
    let id = UUID()

    let radius: CGFloat
    let color: Color
    let baseOffset: CGSize
    @ViewBuilder var content: Content

    @State private var committed: CGSize = .zero     // persists between drags
    @GestureState private var dragging: CGSize = .zero // live during drag only

    init(radius: CGFloat, color: Color = .white, baseOffset: CGSize = .zero, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.baseOffset = baseOffset
        self.color = color
        self.content = content()
    }

    var body: some View {
        let total = CGSize(
            width: baseOffset.width + committed.width + dragging.width,
            height: baseOffset.height + committed.height + dragging.height
        )

        content
            .glassEffect(.regular.interactive(false).tint(color), in: .rect(cornerRadius: radius))
            .offset(total)
            .gesture(
                DragGesture()
                    .updating($dragging) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        committed.width += value.translation.width
                        committed.height += value.translation.height
                    }
            )
    }
}

#Preview {
    ContentView()
}
