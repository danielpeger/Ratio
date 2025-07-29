//
//  ColorSwatchView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI

struct ColorSwatchView: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .stroke(color, lineWidth: 3)
                    .frame(width: 36, height: 36)
                Circle()
                    .fill(color)
                    .frame(width: 26, height: 26)
            }
            else {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
            }
        }
    }
}

#Preview {
    ColorSwatchView(color: .blue, isSelected: true)
}
