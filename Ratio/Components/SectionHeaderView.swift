//
//  SectionHeaderView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 28..
//

import SwiftUI

struct CustomLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

struct SectionHeader: View {
    let title: String
    var systemImage: String? = nil
    var reducedPadding: Bool = false
    
    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Label(title, systemImage: systemImage)
                    .labelStyle(CustomLabel(spacing: 4))
                    .foregroundColor(.accent)
            } else {
                Text(title)
            }
            Spacer()
        }
        .font(.system(size: 13))
        .foregroundColor(.secondary)
        .textCase(.uppercase)
        .padding(.horizontal, reducedPadding ? 16 : 32)
        .padding(.bottom, 7)
    }
}

#Preview {
    SectionHeader(title: "Hello world")
}
