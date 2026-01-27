//
//  SDFPreferences.swift
//  ShaderPlayground
//
//  Created by Даниил Виноградов on 24.01.2026.
//

import SwiftUI

struct SDFItemSpec: Equatable {
    var id: UUID
    var rect: CGRect
    var radius: CGFloat
    var color: Color
}

struct SDFItemSpecKey: PreferenceKey {
    static var defaultValue: [SDFItemSpec] = []
    static func reduce(value: inout [SDFItemSpec], nextValue: () -> [SDFItemSpec]) {
        value.append(contentsOf: nextValue())
    }
}
