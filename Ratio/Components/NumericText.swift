//
//  NumericText.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 08.
//

import SwiftUI

struct NumericText: View {
    let text: String
    let numericValue: Double?
    var body: some View {
        Group {
            if let numericValue {
                Text(text)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: numericValue))
            } else {
                Text(text)
                    .monospacedDigit()
            }
        }
    }
}