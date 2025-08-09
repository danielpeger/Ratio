//
//  YayView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 08..
//

import SwiftUI

struct YayView: View {
    @Binding var pinned: Bool
    
    var isPinnable: Bool
    var onPinToggle: (() -> Void)?
    var onDone: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 120))
            VStack(spacing: 16) {
                Text("Yay, you've brewed a great coffee!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                if isPinnable {
                    Text("Pin it if you'd like to remember it and reproduce it later.")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .opacity(0.75)
                        .multilineTextAlignment(.center)
                } else {
                    Text("To save it for later, add it to a bean.")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .opacity(0.75)
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
            if isPinnable {
                Button(action: {
                    pinned.toggle()
                    onPinToggle?()
                }) {
                    Label(pinned ? "Unpin brew" : "Pin brew", systemImage: pinned ? "pin.slash.fill" : "pin")
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
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 32)
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

    YayView(pinned: $pinned, isPinnable: true)
}
