//
//  TipPickerView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI

struct EllipsesSpacer: View {
    var body: some View {
        GeometryReader { geometry in
            let ellipsesCount = Int(geometry.size.width / 4) // Approximate width per ellipsis
            Text(String(repeating: ".", count: max(1, ellipsesCount)))
                .foregroundColor(Color(.opaqueSeparator))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 8) // Fixed height for the spacer
    }
}


struct TipPickerView: View {
    @Binding var tip: Bool?
    var trueOption: Tip
    var falseOption: Tip
    var onUserChange: ((Bool?) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            PillView(text: trueOption.rawValue, large: true, selected: tip == true)
                .onTapGesture {
                    withAnimation {
                        if(tip == true) {
                            tip = nil
                        } else {
                            tip = true
                        }
                        onUserChange?(tip)
                    }
                }
                
            EllipsesSpacer()
                .layoutPriority(0)
            
            PillView(text: falseOption.rawValue, large: true, selected: tip == false)
                .onTapGesture {
                    withAnimation {
                        if(tip == false) {
                            tip = nil
                        } else {
                            tip = false
                        }
                        onUserChange?(tip)
                    }
                }
        }
    }
}

#Preview {
    @Previewable @State var previewTip: Bool? = nil
    TipPickerView(tip: $previewTip, trueOption: .doseMore, falseOption: .doseLess)
        .padding()
}
