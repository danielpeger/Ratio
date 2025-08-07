//
//  BrewCardView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 05..
//

import SwiftUI
import Flow

struct BrewCardView: View {
    var brew: Brew
    var showPills: Bool = true
    
    @State private var displayBrew: Brew
    
    let delayInterval = 0.05
    
    init(brew: Brew, showPills: Bool = true) {
        self.brew = brew
        self.showPills = showPills
        self._displayBrew = State(initialValue: brew)
    }
    var animationLength: Int {
        return displayBrew.tasteArray.count + displayBrew.tipArray.count + 1
    }
    @State private var visibleIndicesState: Set<Int> = []
    @State private var isAnimating: Bool = false
    
    fileprivate func animateIn() {
        if isAnimating { return }
        isAnimating = true
        for index in 0..<animationLength {
            let delay = Double(index) * delayInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let animationBlock: () -> Void = {
                    visibleIndicesState.insert(index)
                    if index == animationLength - 1 {
                        isAnimating = false
                    }
                }
                withAnimation(.default, animationBlock)
            }
        }
    }
    
    fileprivate func animateOut() {
        if isAnimating { return }
        isAnimating = true
        for index in (0..<animationLength).reversed() {
            let delay = Double(animationLength - 1 - index) * delayInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let animationBlock: () -> Void = {
                    visibleIndicesState.remove(index)
                    if (index == 0) {
                        visibleIndicesState = []
                        isAnimating = false
                    }
                }
                withAnimation(.default, animationBlock)
            }
        }
    }
    
    var body: some View {
        // let pillsSection: Bool = showPills && (!brew.tasteArray.isEmpty || !brew.tipArray.isEmpty)

        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack {
                    Text("Dose")
                    Text("\(brew.dose)g")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(brew.dose)))
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Grind")
                    Text("\(brew.grind)")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(brew.grind)))
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Yield")
                    Text("\(brew.yield)g")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(brew.yield)))
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Time")
                    Text("\(brew.time)s")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(brew.time)))
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .padding(.horizontal, 8)
            if visibleIndicesState.contains(0) {
                Divider()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.vertical, 12)
            }
            HFlow {
                ForEach(Array(displayBrew.tasteArray.enumerated()), id: \.element) { index, taste in
                    if visibleIndicesState.contains(index + 1) {
                        PillView(text: taste.rawValue)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                ForEach(Array(displayBrew.tipArray.enumerated()), id: \.element) { index, tip in
                    let tipIndex = displayBrew.tasteArray.count + index + 1
                    if visibleIndicesState.contains(tipIndex) {
                        PillView(text: tip.rawValue)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear {
            if showPills {
                visibleIndicesState = Set(0..<animationLength)
            } else {
                visibleIndicesState = []
            }
        }
        .onChange(of: brew) { _, newBrew in
            if !isAnimating {
                if showPills {
                    withAnimation {
                        displayBrew = newBrew
                    }
                    animateIn()
                } else {
                    // Animate out current brew's pills first, then update to new brew
                    animateOut()
                    // Update displayBrew after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(animationLength) * delayInterval) {
                        withAnimation {
                            displayBrew = newBrew
                        }
                        if showPills {
                            animateIn()
                        }
                    }
                }
            }
        }
        .onChange(of: showPills) { _, newShowPills in
            if !isAnimating {
                if newShowPills {
                    animateIn()
                } else {
                    animateOut()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showPillsInPreview: Bool = true
    
    if let fifthBrew = createMockBrews().dropFirst(4).first {
        LazyVStack {
            BrewCardView(brew: fifthBrew, showPills: showPillsInPreview)
                .background(.white)
                .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        Button("Toggle pills"){
            showPillsInPreview.toggle()
        }
    }
}

/*
.transition(.asymmetric(insertion: AnyTransition.move(edge: .top).combined(with: .opacity).animation(.default.delay(transitionDelayForwards)),removal: AnyTransition.move(edge: .top).combined(with: .opacity).animation(.default.delay(transitionDelayBackwards))))
 */
