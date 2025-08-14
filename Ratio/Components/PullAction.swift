//
//  PullAction.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 12..
//

import SwiftUI
import UIKit
import AudioToolbox

// MARK: - UIKit bridge to observe UIScrollView contentOffset (includes rubber-band bounce)
private struct ScrollViewOffsetObserver: UIViewRepresentable {
    var onChange: (_ contentOffset: CGPoint, _ adjustedInsetTop: CGFloat, _ isDragging: Bool) -> Void
    
    func makeUIView(context: Context) -> ObserverView {
        let v = ObserverView()
        v.onChange = onChange
        return v
    }
    
    func updateUIView(_ uiView: ObserverView, context: Context) {}
    
    final class ObserverView: UIView {
        var onChange: ((_ contentOffset: CGPoint, _ adjustedInsetTop: CGFloat, _ isDragging: Bool) -> Void)?
        weak var scrollView: UIScrollView?
        private var contentOffsetObservation: NSKeyValueObservation?
        private var draggingObservation: NSKeyValueObservation?
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            attachIfNeeded()
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            attachIfNeeded()
        }
        
        private func attachIfNeeded() {
            guard scrollView == nil else { return }
            var current: UIView? = self
            while let view = current?.superview {
                if let sv = view as? UIScrollView {
                    scrollView = sv
                    observe(sv)
                    break
                }
                current = view
            }
        }
        
        private func observe(_ sv: UIScrollView) {
            contentOffsetObservation = sv.observe(\.contentOffset, options: [.new]) { [weak self] scroll, change in
                guard let self, let newValue = change.newValue else { return }
                self.onChange?(newValue, scroll.adjustedContentInset.top, scroll.isDragging)
            }
            draggingObservation = sv.observe(\.isDragging, options: [.new]) { [weak self] scroll, change in
                guard let self, let isDragging = change.newValue else { return }
                self.onChange?(scroll.contentOffset, scroll.adjustedContentInset.top, isDragging)
            }
        }
        
        deinit {
            contentOffsetObservation = nil
            draggingObservation = nil
        }
    }
}

/// A scroll container that detects pull-down distance and shows a custom plus animation.
/// Triggers `onTrigger` when released past the threshold.
struct PullActionScrollView<Content: View>: View {
    let threshold: CGFloat
    let onTrigger: () -> Void
    let onProgress: (Double) -> Void
    @Environment(\.isSearching) private var isSearching
    @ViewBuilder var content: () -> Content
    
    @State private var pullDistance: CGFloat = 0
    @State private var lastDistanceBeforeRelease: CGFloat = 0
    @State private var hasTriggered = false
    @State private var hasCrossedThresholdThisDrag = false
    @State private var wasDragging = false
    @State private var isHoldingAtOne = false
    
    // No named coordinate space needed anymore
    init(
        threshold: CGFloat,
        onTrigger: @escaping () -> Void,
        onProgress: @escaping (Double) -> Void = { _ in },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.threshold = threshold
        self.onTrigger = onTrigger
        self.onProgress = onProgress
        self.content = content
    }
    
    var body: some View {
        ScrollView {            
            VStack(spacing: 0) {
                if !isSearching {
                    // Observer must be inside ScrollView content so it can find the UIScrollView ancestor
                    ScrollViewOffsetObserver { contentOffset, adjustedTop, isDragging in
                        let pull = max(0, -(contentOffset.y + adjustedTop))
                        let previousPull = pullDistance
                        // Detect drag start: reset crossing state and allow next trigger; stop holding 1
                        if isDragging && !wasDragging {
                            DispatchQueue.main.async {
                                hasCrossedThresholdThisDrag = false
                                hasTriggered = false
                                isHoldingAtOne = false
                            }
                        }
                        if pullDistance != pull {
                            let didCrossNow = isDragging && !hasCrossedThresholdThisDrag && previousPull < threshold && pull >= threshold
                            if didCrossNow {
                                AudioServicesPlaySystemSound(SystemSoundID(1397))
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                DispatchQueue.main.async {
                                    hasCrossedThresholdThisDrag = true
                                    onProgress(1.0)
                                }
                            } else if (!isDragging && isHoldingAtOne) || (isDragging && hasCrossedThresholdThisDrag) {
                                // Keep progress pinned to 1 during post-trigger bounce, and while dragging after threshold
                                DispatchQueue.main.async { onProgress(1.0) }
                            } else {
                                let normalized = min(max(Double(pull / threshold), 0), 0.999)
                                DispatchQueue.main.async { onProgress(normalized) }
                            }
                            DispatchQueue.main.async { pullDistance = pull }
                        }
                        // On release, decide whether to trigger based on threshold or haptic
                        if !isDragging && wasDragging {
                            if hasCrossedThresholdThisDrag && !hasTriggered {
                                DispatchQueue.main.async {
                                hasTriggered = true
                                isHoldingAtOne = true
                                onProgress(1.0)
                                onTrigger()
                                }
                            }
                            DispatchQueue.main.async { lastDistanceBeforeRelease = pull }
                        }
                        // While bouncing back, keep reporting progress. Reset only once bounce reaches zero.
                        if !isDragging && pull <= 0 {
                            DispatchQueue.main.async { pullDistance = 0 }
                            // If we are holding at one (i.e., after a trigger), do NOT emit 0 here.
                            // This avoids rapid 1 -> 0 -> 1 flips at offset 0 which cause the AddCircle to flicker.
                            if isHoldingAtOne || hasTriggered {
                                DispatchQueue.main.async { onProgress(1) }
                            } else {
                                DispatchQueue.main.async { onProgress(0) }
                            }
                            DispatchQueue.main.async {
                                hasCrossedThresholdThisDrag = false
                                // Allow next trigger while still visually holding progress at 1.
                                // Keep isHoldingAtOne until the next drag begins (where we reset it),
                                // so the visual stays stable at rest.
                                hasTriggered = false
                            }
                        }
                        DispatchQueue.main.async { wasDragging = isDragging }
                    }
                    .frame(height: 0)
                }
                
                // Main content
                LazyVStack(spacing: 0) {
                    content()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .scrollBounceBehavior(.always)
        .onDisappear {
            // Reset held state and visual progress when navigating away (e.g., switching tabs)
            DispatchQueue.main.async {
                isHoldingAtOne = false
                hasTriggered = false
                hasCrossedThresholdThisDrag = false
                wasDragging = false
                pullDistance = 0
                lastDistanceBeforeRelease = 0
                onProgress(0)
            }
        }
        .onAppear {
            // Ensure we don't remain visually at 1 after returning
            DispatchQueue.main.async {
                isHoldingAtOne = false
                hasTriggered = false
                onProgress(0)
            }
        }
    }
}

struct AddCircle: View {
    @Binding var progress: Double
    @State private var rippleTrigger: Int = 0
    @State private var rippleScale: CGFloat = 1
    @State private var hasAnimatedSinceReset: Bool = false
    
    var body: some View {
        let size = max(0, progress) * 32
        
        ZStack {
            Image(systemName: "plus")
                .foregroundStyle(.accent)
                .frame(width: 32, height: 32)
            Circle()
                .fill(.red)
                .frame(width: size, height: size)
            Image(systemName: "plus")
                .foregroundStyle(Color(.systemBackground))
                .mask(
                    Circle()
                        .frame(width: size, height: size)
                )
        }
        .overlay {
            Circle()
                .stroke(.red, lineWidth: 0.5)
                .phaseAnimator([0.0, 1.0, 0.0], trigger: rippleTrigger) { view, phase in
                    let opacity = (progress == 0) ? 0 : phase
                    view.opacity(opacity)
                } animation: { _ in
                        .easeOut(duration: 0.25)
                }
                .scaleEffect(rippleScale)
                .animation(.easeOut(duration: 0.5), value: rippleScale)
                .transaction { tx in
                    if progress == 0 {
                        tx.animation = nil
                    } else if hasAnimatedSinceReset {
                        // Disable opacity animation for subsequent 1.0 hits until reset
                        tx.animation = nil
                    }
                }
        }
        .onChange(of: progress) { _, newValue in
            if newValue == 1.0 {
                if !hasAnimatedSinceReset {
                    rippleTrigger += 1
                    rippleScale = 2
                    hasAnimatedSinceReset = true
                }
            } else if newValue == 0.0 {
                hasAnimatedSinceReset = false
                // Reset without animation
                withAnimation(nil) {
                    rippleScale = 1
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var progress: Double = 0.0
    
    AddCircle(progress: $progress)
    
    Slider(
        value: $progress,
        in: 0...1,
    )
}

