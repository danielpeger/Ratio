//
//  YayView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 08..
//

import SwiftUI

struct YayView: View {
    @Binding var pinned: Bool
    
    var onPinToggle: (() -> Void)?
    var onDone: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 120))
            VStack(spacing: 12) {
                Text("Yay, you've logged a great brew!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text("Pin it if you'd like to remember and recreate.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button(pinned ? "Pinned" : "Pin brew", systemImage: pinned ? "pin.fill" : "pin") {
                pinned.toggle()
                onPinToggle?()
            }
            .bold()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.white)
            .foregroundColor(.accent)
            .cornerRadius(12)

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 32)
        .foregroundStyle(.white)
        .background(.accent)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    onDone?()
                }
            }
        }
        .animation(.none, value: pinned)
    }
}

#Preview {
    @Previewable @State var pinned: Bool = false

    YayView(pinned: $pinned)
}
