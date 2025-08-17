//
//  YayView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 08..
//

import SwiftUI
import UIKit

struct YayView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var pinned: Bool
    
    var isPinnable: Bool
    var onPinToggle: (() -> Void)?
    var onDone: (() -> Void)?
    
    @State private var hapticTimer: Timer? = nil
    private let effectRepeatDelay: TimeInterval = 1.2
    @State private var bounceTick: Int = 0

    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "heart.fill")
                .font(.system(size: 120))
                .symbolEffect(.bounce.up.byLayer, value: bounceTick)
            VStack(spacing: 16) {
                Text("Yay, you've brewed a great coffee!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                if isPinnable {
                    Text("Pin it if you'd like to remember it and reproduce it later.")
                        .font(.title3)
                        .foregroundStyle(Color(.systemBackground))
                        .opacity(0.75)
                        .multilineTextAlignment(.center)
                } else {
                    Text("To save it for later, add it to a bean.")
                        .font(.title3)
                        .foregroundStyle(Color(.systemBackground))
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
                        .fontWeight(.medium)
                        .foregroundStyle(.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(14)
                        .background(Color(.systemBackground))
                        .contentShape(Capsule())
                }
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color(.systemBackground))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 32)
        .background(Color.red.gradient)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    onDone?()
                }
            }
        }
        // Make navigation bar items systemBackground color
        .toolbarBackground(Color("RedGradientTopColor"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(colorScheme == .dark ? .light : .dark, for: .navigationBar)
        .tint(.black)
        .animation(.none, value: pinned)
        .onAppear {
            // Fire immediately then repeat in sync using the same tick driving the effect
            tickBounceAndHaptic()
            startHapticTimer()
        }
        .onDisappear {
            stopHapticTimer()
        }
    }
}

private extension YayView {
    func startHapticTimer() {
        stopHapticTimer()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: effectRepeatDelay, repeats: true) { _ in
            tickBounceAndHaptic()
        }
    }
    
    func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    func playDoubleHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            generator.impactOccurred()
        }
    }

    func tickBounceAndHaptic() {
        withAnimation(.easeInOut(duration: 0.35)) {
            bounceTick &+= 1
        }
        playDoubleHaptic()
    }
}

#Preview {
    @Previewable @State var pinned: Bool = false

    YayView(pinned: $pinned, isPinnable: true)
}
