//
//  UIKitWheelPicker.swift
//  Ratio
//
//  A UIScrollView-backed wheel picker with native scroll physics.
//  Mirrors WheelPicker inputs and renders ticks with Core Graphics for performance.
//

import SwiftUI
import UIKit
import AudioToolbox

struct UIKitWheelPicker: UIViewRepresentable {
	var config: WheelPicker.Config
	@Binding var value: CGFloat
    /// 0 = .fast, 1 = .normal
    var decelerationFactor: CGFloat = 0.2

	final class WheelDrawingView: UIView {
		var config: WheelPicker.Config
		var stepWidth: CGFloat
		var totalSteps: Int { config.count * config.steps }
		// Selection animation state
		private(set) var selectedIndex: Int = -1
		private var selectedCurrentHeight: CGFloat = 90
		private var animationStartTime: CFTimeInterval = 0
		private var animationDuration: CFTimeInterval = 0.6
		private var displayLink: CADisplayLink?

		init(config: WheelPicker.Config, stepWidth: CGFloat) {
			self.config = config
			self.stepWidth = stepWidth
			super.init(frame: .zero)
			isOpaque = true
			contentMode = .redraw
			backgroundColor = .clear
		}

		required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

		func setSelectedInstant(index: Int) {
			selectedIndex = index
			selectedCurrentHeight = 100
			displayLink?.invalidate()
			displayLink = nil
			setNeedsDisplay()
		}

		func setSelected(index: Int) {
			guard index != selectedIndex else { return }
			selectedIndex = index
			// Start animation towards 100pt
			selectedCurrentHeight = 90
			animationStartTime = CACurrentMediaTime()
			startDisplayLink()
		}

		private func startDisplayLink() {
			displayLink?.invalidate()
			let link = CADisplayLink(target: self, selector: #selector(stepAnimation))
			link.add(to: .main, forMode: .common)
			displayLink = link
		}

		@objc private func stepAnimation() {
			let elapsed = CACurrentMediaTime() - animationStartTime
			let t = max(0, min(1, elapsed / animationDuration))
			// Spring-like ease: 1 - e^{-d t} cos(omega t)
			let damping: Double = 6.0 // higher = less bounce; tuned to approx bounce 0.15
			let omega: Double = 8.5
			let progress = 1.0 - exp(-damping * t) * cos(omega * t)
			let base: CGFloat = 90
			let target: CGFloat = 100
			selectedCurrentHeight = base + (target - base) * CGFloat(progress)
			setNeedsDisplay()
			if t >= 1 {
				displayLink?.invalidate()
				displayLink = nil
				selectedCurrentHeight = target
				setNeedsDisplay()
			}
		}

		override func draw(_ rect: CGRect) {
			guard let ctx = UIGraphicsGetCurrentContext() else { return }

			let height = bounds.height
			let firstIndex = max(0, Int(floor(rect.minX / stepWidth)) - 4)
			let lastIndex = min(totalSteps, Int(ceil(rect.maxX / stepWidth)) + 4)

			ctx.setLineWidth(1)

			for i in firstIndex...lastIndex where i >= 0 && i <= totalSteps {
				let remainder = i % config.steps
				let x = 1 + CGFloat(i) * stepWidth
				var h: CGFloat
				if i == selectedIndex {
					ctx.setStrokeColor(UIColor.systemRed.cgColor)
					h = selectedCurrentHeight
				} else {
					let color: UIColor = (remainder == 0)
						? UIColor.label.withAlphaComponent(0.5)
						: UIColor.secondaryLabel.withAlphaComponent(0.25)
					ctx.setStrokeColor(color.cgColor)
					h = (remainder == 0) ? 95 : 90
				}
				ctx.beginPath()
				ctx.move(to: CGPoint(x: x, y: height - h))
				ctx.addLine(to: CGPoint(x: x, y: height))
				ctx.strokePath()
			}
			// all strokes done per tick
		}
	}

	final class Coordinator: NSObject, UIScrollViewDelegate {
		var parent: UIKitWheelPicker
		let haptic = UISelectionFeedbackGenerator()
		var lastReportedIndex: Int = -1
		var isInitializing: Bool = true
		var widthConstraint: NSLayoutConstraint?
		var programmaticTargetIndex: Int? = nil
		var lastBoundValue: CGFloat = .nan
		var stepWidth: CGFloat { parent.stepWidth }
		var totalSteps: Int { parent.totalSteps }

		init(parent: UIKitWheelPicker) {
			self.parent = parent
			super.init()
			haptic.prepare()
		}

		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			if isInitializing { return }
			let inset = scrollView.contentInset.left
			let effectiveX = scrollView.contentOffset.x + inset
			let maxX = CGFloat(totalSteps) * stepWidth
			// Ignore updates while overscrolling (elastic beyond range)
			guard effectiveX >= 0 && effectiveX <= maxX else { return }
			let index = clampIndex(Int(round((effectiveX - 1) / stepWidth)))
			// During programmatic animations (tap/value change), keep selection fixed to target to avoid flicker
			if let target = programmaticTargetIndex {
				if let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
					drawing.setSelectedInstant(index: target)
				}
				lastReportedIndex = target
				return
			}
			if index != lastReportedIndex {
				lastReportedIndex = index
				// Always update drawing selection so center tick styles track programmatic or user scroll
				if let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
					drawing.setSelected(index: index)
				}
				// Only update binding/haptics/audio during active user motion
				if scrollView.isDragging || scrollView.isDecelerating || scrollView.isTracking {
					let mapped = (CGFloat(index) / CGFloat(parent.config.steps)) * CGFloat(parent.config.multiplier)
					if mapped != parent.value { parent.value = mapped }
					haptic.selectionChanged()
					AudioServicesPlaySystemSound(SystemSoundID(1479))
				}
			}
		}

		func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			let inset = scrollView.contentInset.left
			let proposedX = targetContentOffset.pointee.x + inset
			let nearestIndex = clampIndex(Int(round((proposedX - 1) / stepWidth)))
			let targetX = (1 + CGFloat(nearestIndex) * stepWidth) - inset
			targetContentOffset.pointee = CGPoint(x: targetX, y: 0)
		}

		func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }

		func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }

		func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { programmaticTargetIndex = nil }

		private func snapToNearest(_ scrollView: UIScrollView) { }

		private func clampIndex(_ i: Int) -> Int {
			return max(0, min(totalSteps, i))
		}

		@objc func handleTap(_ recognizer: UITapGestureRecognizer) {
			guard let scrollView = recognizer.view as? UIScrollView else { return }
			let location = recognizer.location(in: scrollView)
			let isRightHalf = location.x >= scrollView.bounds.midX
			let maxValue = CGFloat(parent.config.count * parent.config.multiplier)
			let currentRounded = Int(parent.value.rounded())
			// No-op when already at bounds and tapping further out of range
			if (!isRightHalf && currentRounded <= 0) || (isRightHalf && currentRounded >= Int(maxValue)) {
				return
			}
			let proposed = currentRounded + (isRightHalf ? 1 : -1)
			// Ignore taps that would exceed bounds (do not clamp; treat as no-op)
			if proposed < 0 || proposed > Int(maxValue) { return }
			let nextValue = proposed
			let idx = clampIndex((nextValue * parent.config.steps) / parent.config.multiplier)
			let inset = scrollView.contentInset.left
			let targetX = (1 + CGFloat(idx) * stepWidth) - inset
			lastReportedIndex = idx
			programmaticTargetIndex = idx
			parent.value = (CGFloat(idx) / CGFloat(parent.config.steps)) * CGFloat(parent.config.multiplier)
			if let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
				drawing.setSelected(index: idx)
			}
			haptic.selectionChanged()
			AudioServicesPlaySystemSound(SystemSoundID(1479))
			scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
		}
	}

	func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

	private var stepWidth: CGFloat { config.spacing + 1 }
	private var totalSteps: Int { config.count * config.steps }

	func makeUIView(context: Context) -> UIScrollView {
		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
        let fast = UIScrollView.DecelerationRate.fast.rawValue
        let normal = UIScrollView.DecelerationRate.normal.rawValue
        let t = max(0, min(1, decelerationFactor))
        let interpolated = fast + (normal - fast) * t
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: interpolated)
		scrollView.bounces = true
		scrollView.alwaysBounceHorizontal = true
		scrollView.clipsToBounds = false
		scrollView.delegate = context.coordinator

		// Tap to increment/decrement similar to SwiftUI simultaneousGesture
		let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
		scrollView.addGestureRecognizer(tap)

		let content = WheelDrawingView(config: config, stepWidth: stepWidth)
		content.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(content)

		let clg = scrollView.contentLayoutGuide
		let flg = scrollView.frameLayoutGuide
		NSLayoutConstraint.activate([
			content.topAnchor.constraint(equalTo: clg.topAnchor),
			content.bottomAnchor.constraint(equalTo: clg.bottomAnchor),
			content.leadingAnchor.constraint(equalTo: clg.leadingAnchor),
			content.trailingAnchor.constraint(equalTo: clg.trailingAnchor),
			content.heightAnchor.constraint(equalTo: flg.heightAnchor)
		])

		// Width equals total content width
		let contentWidth = 2 + CGFloat(totalSteps) * stepWidth
		let widthC = content.widthAnchor.constraint(equalToConstant: contentWidth)
		widthC.isActive = true
		context.coordinator.widthConstraint = widthC

		// Centering: inset so a tick can align with visual center
		DispatchQueue.main.async {
			let centerInset = scrollView.bounds.width / 2
			scrollView.contentInset = UIEdgeInsets(top: 0, left: centerInset, bottom: 0, right: centerInset)
			updateOffset(scrollView, coordinator: context.coordinator)
			// Ensure initial selected tick is highlighted immediately
			let initialIndex = clampIndex((Int(value) * config.steps) / config.multiplier)
			content.setSelectedInstant(index: initialIndex)
			context.coordinator.isInitializing = false
		}

		return scrollView
	}

	func updateUIView(_ scrollView: UIScrollView, context: Context) {
		if let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
			if drawing.config != config || drawing.stepWidth != stepWidth {
				drawing.config = config
				drawing.stepWidth = stepWidth
				drawing.setNeedsDisplay()
				let contentWidth = 2 + CGFloat(totalSteps) * stepWidth
				if let wc = context.coordinator.widthConstraint {
					wc.constant = contentWidth
				} else {
					let wc = drawing.widthAnchor.constraint(equalToConstant: contentWidth)
					wc.isActive = true
					context.coordinator.widthConstraint = wc
				}
			}
		}
		let desiredInset = scrollView.bounds.width / 2
		let currentInset = scrollView.contentInset.left
		if abs(currentInset - desiredInset) > 0.5 {
			scrollView.contentInset = UIEdgeInsets(top: 0, left: desiredInset, bottom: 0, right: desiredInset)
		}
		// If a programmatic animation is in progress, avoid interfering
		if context.coordinator.programmaticTargetIndex == nil {
			// If the bound value changed programmatically while idle, scroll to it
			let bound = value
			if bound != context.coordinator.lastBoundValue {
				context.coordinator.lastBoundValue = bound
				updateOffset(scrollView, coordinator: context.coordinator)
			} else {
				updateOffset(scrollView, coordinator: context.coordinator)
			}
		} else {
			// Keep the drawing in sync with the target while the animation is running
			if let target = context.coordinator.programmaticTargetIndex,
			   let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
				drawing.setSelected(index: target)
			}
		}
	}

	private func updateOffset(_ scrollView: UIScrollView, coordinator: Coordinator? = nil) {
		let idx = clampIndex((Int(value) * config.steps) / config.multiplier)
		let targetX = (1 + CGFloat(idx) * stepWidth) - scrollView.contentInset.left
		// Only sync when idle (not dragging/decelerating)
		if scrollView.isDragging || scrollView.isDecelerating { return }
		if abs(scrollView.contentOffset.x - targetX) > 0.5 {
			coordinator?.programmaticTargetIndex = idx
			scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
		}
		// Update selected tick styles to match programmatic value changes
		if let drawing = scrollView.subviews.compactMap({ $0 as? WheelDrawingView }).first {
			drawing.setSelected(index: idx)
		}
	}

	private func clampIndex(_ i: Int) -> Int {
		return max(0, min(totalSteps, i))
	}
}

#Preview {
	@Previewable @State var config: WheelPicker.Config = .init(
		count: 10,
		steps: 10,
		spacing: 10,
		multiplier: 10
	)
	@Previewable @State var value: CGFloat = 11

	VStack {
		Text(verbatim: "\(value)")
			.font(.largeTitle.bold())
			.contentTransition(.numericText(value: value))
			.animation(.snappy, value: value)
        UIKitWheelPicker(config: config, value: $value)
            .frame(height: 100)
	}
}


