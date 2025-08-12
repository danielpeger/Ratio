//
//  PullAction.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 12..
//

import SwiftUI
import UIKit

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
    @ViewBuilder var content: () -> Content

    @State private var pullDistance: CGFloat = 0
    @State private var lastDistanceBeforeRelease: CGFloat = 0
    @State private var hasTriggered = false
    @State private var didHapticForCurrentDrag = false
    @State private var wasDragging = false

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
                // Observer must be inside ScrollView content so it can find the UIScrollView ancestor
                ScrollViewOffsetObserver { contentOffset, adjustedTop, isDragging in
                    let pull = max(0, -(contentOffset.y + adjustedTop))
                    if pullDistance != pull {
                        pullDistance = pull
                        let progress = min(max(Double(pullDistance / threshold), 0), 1)
                        onProgress(progress)
                        if isDragging && !didHapticForCurrentDrag && pullDistance > threshold {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            didHapticForCurrentDrag = true
                        }
                    }
                    // On release, decide whether to trigger based on threshold or haptic
                    if !isDragging && wasDragging {
                        if (pullDistance > threshold || didHapticForCurrentDrag) && !hasTriggered {
                            hasTriggered = true
                            onTrigger()
                        }
                        lastDistanceBeforeRelease = pullDistance
                    }
                    // While bouncing back, keep reporting progress. Reset only once bounce reaches zero.
                    if !isDragging && pull <= 0 {
                        pullDistance = 0
                        onProgress(0)
                        hasTriggered = false
                        didHapticForCurrentDrag = false
                    }
                    wasDragging = isDragging
                }
                .frame(height: 0)
                
                // Main content
                LazyVStack(spacing: 0) {
                    content()
                }
            }
            .background(Color(.secondarySystemBackground))
        }
        .scrollBounceBehavior(.always)
    }
}
