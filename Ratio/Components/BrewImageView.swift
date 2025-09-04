//
//  BrewImageView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

enum ImageSize: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case small = "small"
    case medium = "medium"
    case large = "large"
}

struct BrewImageView: View {
    @Environment(\.colorScheme) private var colorScheme

    var rating: Rating
    var size: ImageSize = .small
    var brightBackground: Bool = false
    var selected: Bool = false
    var noBorder: Bool = false
    
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
            if(selected) {
                Circle()
                    .fill(Color.accent.quaternary)
                    .strokeBorder(Color.accent)
                    .frame(width: frameSize, height: frameSize)
            } else {
                ZStack {
                    Circle()
                        .fill(brightBackground ? Color(.secondarySystemGroupedBackground) : Color(.systemGroupedBackground))
                        .strokeBorder(noBorder ? Color.clear : brightBackground ? Color(.separator).opacity(0.8) : Color(.separator).opacity(0.5), lineWidth: size == .large ? 1.5 : 1)
                        .shadow(color: size == .large ? .primary.opacity(0.12) : Color.clear, radius: 40, x: 0, y: 20)
                        .shadow(color: size == .large ? .primary.opacity(0.04) : Color.clear, radius: 4, x: 0, y: 2)
                        .frame(width: frameSize, height: frameSize)
                    if !noBorder {
                        Circle()
                            .inset(by: size == .large ? 2.25 : 1.5)
                            .fill(Color.clear)
                            .stroke(Gradient(colors: [
                                .white.opacity(colorScheme == .dark ? 0.25 : 0.4), .clear
                            ]), lineWidth: size == .large ? 1.5 : 1)
                            .frame(width: frameSize, height: frameSize)
                    }
                }
            }
            Text(rating.rawValue)
                .font(.system(size: iconSize))
        }
    }
}

#Preview {
        VStack(spacing: 20) {
            BrewImageView(rating: .good, size: .small)
            BrewImageView(rating: .neutral, size: .medium, selected: true)
            BrewImageView(rating: .bad, size: .large, brightBackground: true)
        }
}
