//
//  Color+RGBA.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 25.01.2026.
//

import SwiftUI
import UIKit
import simd

extension Color {
    func rgbaSIMD() -> SIMD4<Float> {
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SIMD4(Float(r), Float(g), Float(b), Float(a))
    }
}
