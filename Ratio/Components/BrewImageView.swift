//
//  BrewImageView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

// Hacky modifier to add a tertiary red background to the image when selected.
struct SelectedFillModifier: ViewModifier {
    let selected: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if selected {
                    Circle()
                        .fill(Color.accent.tertiary)
                        .stroke(Color.accent)
                }
            }
    }
}

enum ImageSize: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case small = "small"
    case medium = "medium"
    case large = "large"
}

struct BrewImageView: View {
    var rating: Rating
    var size: ImageSize = .small
    var tertiary: Bool = false
    var selected: Bool = false
    
    private var frameSize: CGFloat {
        switch size {
        case .small:
            return 44
        case .medium:
            return 54
        case .large:
            return 120
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small:
            return 24
        case .medium:
            return 32
        case .large:
            return 64
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(tertiary ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
                .modifier(SelectedFillModifier(selected: selected))
                .frame(width: frameSize, height: frameSize)
            Text(rating.rawValue)
                .font(.system(size: iconSize))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BrewImageView(rating: .good, size: .small)
        BrewImageView(rating: .neutral, size: .medium, selected: true)
        BrewImageView(rating: .bad, size: .large, tertiary: true)
    }
}
