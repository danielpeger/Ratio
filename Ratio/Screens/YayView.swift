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
                Text("Yay, you've made a great brew!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                Text("Pin it if you'd like to remember and recreate.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button(action: {
                pinned.toggle()
                onPinToggle?()
            }) {
                Label(pinned ? "Pinned" : "Pin brew", systemImage: pinned ? "pin.fill" : "pin")
                    .fontWeight(.bold)
                    .foregroundColor(.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

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
        // Make navigation bar items (including Back) white for this screen
        .toolbarBackground(Color.accentColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .animation(.none, value: pinned)
    }
}

#Preview {
    @Previewable @State var pinned: Bool = false

    YayView(pinned: $pinned)
}
