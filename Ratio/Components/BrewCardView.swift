//
//  BrewCardView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 05..
//

import SwiftUI
import Flow

private enum BrewCardStyle {
    static let metricsHorizontalPadding: CGFloat = 8
    static let verticalPadding: CGFloat = 12
    static let staggerDelay: Double = 0.03
}

struct BrewCardView: View {
    var brew: Brew
    var showPills: Bool = true

    @State private var displayBrew: Brew

    init(brew: Brew, showPills: Bool = true) {
        self.brew = brew
        self.showPills = showPills
        self._displayBrew = State(initialValue: brew)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MetricsRow(brew: displayBrew)
                .padding(.horizontal, BrewCardStyle.metricsHorizontalPadding)

            PillsSection(
                taste: displayBrew.tasteArray.map { $0.rawValue },
                tips: displayBrew.tipArray.map { $0.rawValue },
                showPills: showPills,
                staggerDelay: BrewCardStyle.staggerDelay
            )
        }
        .onChange(of: brew) { _, newBrew in
            withAnimation {
                displayBrew = newBrew
            }
        }
    }
}

private struct MetricsRow: View {
    let brew: Brew
    var body: some View {
        HStack {
            MetricItem(title: "Dose", value: "\(brew.dose)g", numericValue: Double(brew.dose))
            Spacer()
            Divider()
            Spacer()
            MetricItem(title: "Grind", value: "\(brew.grind)", numericValue: Double(brew.grind))
            Spacer()
            Divider()
            Spacer()
            MetricItem(title: "Yield", value: "\(brew.yield)g", numericValue: Double(brew.yield))
            Spacer()
            Divider()
            Spacer()
            MetricItem(title: "Time", value: "\(brew.time)s", numericValue: Double(brew.time))
        }
    }
}

private struct MetricItem: View {
    let title: String
    let value: String
    let numericValue: Double?
    var body: some View {
        VStack {
            Text(title)
            NumericText(text: value, numericValue: numericValue)
                .foregroundColor(.secondary)
        }
    }
}

private struct NumericText: View {
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

private struct PillsSection: View {
    let tasteInput: [String]
    let tipsInput: [String]
    let showPills: Bool
    let staggerDelay: Double

    @State private var localTaste: [String] = []
    @State private var localTips: [String] = []
    @State private var visibleItemIndices: Set<Int> = []
    @State private var animationToken = UUID()

    init(taste: [String], tips: [String], showPills: Bool, staggerDelay: Double) {
        self.tasteInput = taste
        self.tipsInput = tips
        self.showPills = showPills
        self.staggerDelay = staggerDelay
        _localTaste = State(initialValue: taste)
        _localTips = State(initialValue: tips)
    }

    private var itemCount: Int { localTaste.count + localTips.count + 1 } // +1 for divider index 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if visibleItemIndices.contains(0) {
                Divider()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.vertical, BrewCardStyle.verticalPadding)
            }
            HFlow {
                ForEach(Array(localTaste.enumerated()), id: \.element) { index, taste in
                    if visibleItemIndices.contains(index + 1) {
                        PillView(text: taste)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                ForEach(Array(localTips.enumerated()), id: \.element) { index, tip in
                    let tipIndex = localTaste.count + index + 1
                    if visibleItemIndices.contains(tipIndex) {
                        PillView(text: tip)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear {
            if showPills { presentAll() } else { visibleItemIndices = [] }
        }
        .onChange(of: showPills) { _, newValue in
            if newValue {
                // Resync to the latest inputs and animate from a clean state
                localTaste = tasteInput
                localTips = tipsInput
                visibleItemIndices = []
                presentAll()
            } else {
                // Animate out in reverse
                dismissAllReverse()
            }
        }
        .onChange(of: tasteInput) { _, newTaste in
            handleItemsChange(newTaste: newTaste, newTips: tipsInput)
        }
        .onChange(of: tipsInput) { _, newTips in
            handleItemsChange(newTaste: tasteInput, newTips: newTips)
        }
    }

    private func presentAll() {
        let token = UUID()
        animationToken = token
        for index in 0..<itemCount {
            let delay = Double(index) * staggerDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard token == animationToken else { return }
                withAnimation(.default) {
                    _ = visibleItemIndices.insert(index)
                }
            }
        }
    }

    private func dismissAllReverse(completion: (() -> Void)? = nil) {
        let token = UUID()
        animationToken = token
        for index in (0..<itemCount).reversed() {
            let delay = Double(itemCount - 1 - index) * staggerDelay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard token == animationToken else { return }
                withAnimation(.default) {
                    _ = visibleItemIndices.remove(index)
                    if index == 0 {
                        visibleItemIndices = []
                        completion?()
                    }
                }
            }
        }
    }

    private func handleItemsChange(newTaste: [String], newTips: [String]) {
        if !showPills {
            // Hidden: do nothing now. We'll resync on next showPills=true.
            return
        } else {
            // Visible: animate out then in with new data
            dismissAllReverse { [newTaste, newTips] in
                localTaste = newTaste
                localTips = newTips
                presentAll()
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

// Transition with animation delay modifier
//
// .transition(.asymmetric(insertion: AnyTransition.move(edge: .top).combined(with: .opacity).animation(.default.delay(transitionDelayForwards)),removal: AnyTransition.move(edge: .top).combined(with: .opacity).animation(.default.delay(transitionDelayBackwards))))

