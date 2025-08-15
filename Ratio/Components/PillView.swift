//
//  PillView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 31..
//

import SwiftUI

struct PillView: View {
    var text: String
    var large: Bool = false
    var selected: Bool = false
    var highlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .foregroundColor(selected ? Color("IncreasedContrastAccentColor") : Color(.secondaryLabel))
                .padding(.horizontal, large ? 16 : 12)
                .padding(.vertical, large ? 9 : 4)
        }
        .background(selected || highlighted ? Color("QuaternaryAccentColor") : Color(.systemGroupedBackground))
        .cornerRadius(100)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .strokeBorder(selected ? Color.accent : Color.clear)
        )
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    VStack(spacing: 20) {
        PillView(text: "thin")
        PillView(text: "grind finer", large: true)
        PillView(text: "dose more", large: true, selected: true)
    }
}
