//
//  BeanCardView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI

struct ColorSwatchGridView: View {
    @Binding var selectedColor: ImageColor

    let spacing: CGFloat = 16
    let columnsPerRow = 7

    var rows: [[ImageColor]] {
        let allColors = ImageColor.allCases
        return stride(from: 0, to: allColors.count, by: columnsPerRow).map {
            Array(allColors[$0..<min($0 + columnsPerRow, allColors.count)])
        }
    }

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                let row = rows[rowIndex]

                HStack(spacing: spacing) {
                    if row.count < columnsPerRow {
                        Spacer(minLength: 0)
                    }

                    ForEach(row, id: \.self) { color in
                        ColorSwatchView(
                            color: color.color,
                            isSelected: selectedColor == color
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                    }

                    if row.count < columnsPerRow {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
}

#Preview {
    ColorSwatchGridView(selectedColor: .constant(.red))
}
