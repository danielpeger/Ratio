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
                        .strokeBorder(noBorder ? Color.clear : Color(.separator).opacity(0.7), lineWidth: size == .large ? 1.5 : 1)
                        .shadow(color: size == .large ? .primary.opacity(0.12) : Color.clear, radius: 40, x: 0, y: 20)
                        .shadow(color: size == .large ? .primary.opacity(0.04) : Color.clear, radius: 4, x: 0, y: 2)
                        .frame(width: frameSize, height: frameSize)
                    Circle()
                        .inset(by: size == .large ? 2 : 1.5)
                        .fill(Color.clear)
                        .stroke(Gradient(colors: [
                            .white.opacity(0.4), .clear
                        ]), lineWidth: size == .large ? 1.5 : 1)
                        .frame(width: frameSize, height: frameSize)
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
