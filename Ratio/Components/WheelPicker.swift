//
//  WheelPicker.swift
//  HorizontalWheelPicker
//
//  Created by Balaji Venkatesh on 15/03/24.
//

import SwiftUI
import AudioToolbox

struct WheelPicker: View {
    /// Config
    var config: Config
    @Binding var value: CGFloat
    /// View Properties
    @State private var isLoaded: Bool = false
    @State private var selectedScrollId: Int? = nil
    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.width / 2
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: config.spacing) {
                    let totalTicks = max(config.maxValue - config.minValue, 0)
                    
                    ForEach(0...totalTicks, id: \.self) { index in
                        let tickValue = config.minValue + index
                        let isTenMultiple = tickValue % 10 == 0
                        // Map current value to the nearest integer index within bounds
                        let clampedCurrent = Int(min(max(round(value), CGFloat(config.minValue)), CGFloat(config.maxValue)))
                        let centerIndex = clampedCurrent - config.minValue
                        let isCenter = index == centerIndex
                        let baseHeight: CGFloat = isCenter ? 100 : (isTenMultiple ? 95 : 90)
                        
                        Rectangle()
                            .fill(isCenter ? Color.red : (isTenMultiple ? .primary.opacity(0.4) : .secondary.opacity(0.4)))
                            .transaction { t in
                                t.disablesAnimations = true
                            }
                            .frame(width: isCenter ? 1.5 : 1, height: 100, alignment: .bottom)
                            .mask {
                                Rectangle()
                                    .frame(height: baseHeight, alignment: .bottom)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .animation(.easeOut(duration: 0.2), value: centerIndex)
                            }
                            /*
                            .overlay(alignment: .bottom) {
                                if isTenMultiple && config.showsText {
                                    Text("\(tickValue)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .textScale(.secondary)
                                        .fixedSize()
                                        .offset(y: 20)
                                }
                            }
                            */
                            .visualEffect { content, proxy in
                                let rect = proxy.frame(in: .named("WHEEL"))
                                let centerX = size.width / 2
                                let signedDistance = rect.midX - centerX
                                let maxDistance = max(centerX, 1)
                                // Normalize to [-1, 1]
                                let t = max(min(signedDistance / maxDistance, 1), -1)
                                // Use Double math to ease type inference
                                let tD = Double(t)
                                let theta = (tD * Double(config.thetaMaxDeg)) * .pi / 180.0
                                let cosThetaD = max(cos(theta), 0.0)
                                // Rotation around vertical axis (negative for front-facing cylinder)
                                let angle = Angle(radians: -theta)
                                // Foreshortening along Y using cos(theta)
                                let curvaturePowerD = Double(config.curvaturePower)
                                let scaleYRaw = pow(cosThetaD, curvaturePowerD)
                                let clampedScaleY = max(CGFloat(scaleYRaw), config.minScaleY)
                                // Remove horizontal squash to avoid visual widening at edges
                                let xSquash: CGFloat = 1
                                return content
                                    .rotation3DEffect(
                                        angle,
                                        axis: (x: 0, y: 1, z: 0),
                                        anchor: .bottom,
                                        perspective: config.perspective
                                    )
                                    .scaleEffect(x: xSquash, y: clampedScaleY, anchor: .center)
                            }
                            .visualEffect { content, proxy in
                                let rect = proxy.frame(in: .named("WHEEL"))
                                let centerX = size.width / 2
                                let signedDistance = rect.midX - centerX
                                let maxDistance = max(centerX, 1)
                                // Normalize to [-1, 1]
                                let t = max(min(signedDistance / maxDistance, 1), -1)
                                let tAbs = abs(t)
                                // Coordinate warp: compress x near edges by scaling distance from center
                                let factor = 1 - min(max(config.edgeCompressionFactor, 0), 0.95) * pow(tAbs, max(config.edgeCompressionExponent, 0.5))
                                let offsetX = (factor - 1) * signedDistance
                                // Optional edge dimming
                                let theta = (Double(t) * Double(config.thetaMaxDeg)) * .pi / 180.0
                                let cosTheta = max(cos(theta), 0)
                                let opacity = config.minEdgeOpacity + (1 - config.minEdgeOpacity) * CGFloat(cosTheta)
                                return content
                                    .offset(x: offsetX)
                                    .opacity(opacity)
                            }
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedScrollId, anchor: .leading)
            .sensoryFeedback(.selection, trigger: selectedScrollId)
            .onChange(of: selectedScrollId) { oldValue, newValue in
                guard let newValue else { return }
                let mappedInt = config.minValue + newValue
                let mapped = CGFloat(min(max(mappedInt, config.minValue), config.maxValue))
                if mapped != value {
                    // Only update during active interaction or programmatic alignment
                    value = mapped
                    AudioServicesPlaySystemSound(SystemSoundID(1479))
                }
            }
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { tap in
                        let isRightHalf = tap.location.x > 0
                        let target = isRightHalf
                        ? min(value + 1, CGFloat(config.maxValue))
                        : max(value - 1, CGFloat(config.minValue))
                        if target != value {
                            value = target
                            AudioServicesPlaySystemSound(SystemSoundID(1479))
                        }
                    }
            )
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                    let clamped = Int(min(max(round(value), CGFloat(config.minValue)), CGFloat(config.maxValue)))
                    selectedScrollId = clamped - config.minValue
                }
            }
            .coordinateSpace(name: "WHEEL")
            // Edge fade overlays
            .overlay(alignment: .leading) {
                LinearGradient(colors: [Color(.secondarySystemGroupedBackground), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 40)
                    .frame(maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .trailing) {
                LinearGradient(colors: [.clear, Color(.secondarySystemGroupedBackground)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 40)
                    .frame(maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
        }
        /// Optional
        .onChange(of: config) { oldValue, newValue in
            value = CGFloat(newValue.minValue)
        }
        .onChange(of: value) { oldValue, newValue in
            // Keep scroll position in sync when value is changed externally
            let clamped = Int(min(max(round(newValue), CGFloat(config.minValue)), CGFloat(config.maxValue)))
            let newId = clamped - config.minValue
            if selectedScrollId != newId {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedScrollId = newId
                }
            }
        }
    }
    
    /// Picker Configuration
    struct Config: Equatable {
        var minValue: Int
        var maxValue: Int
        var spacing: CGFloat = 5
        var showsText: Bool = true
        // Cylinder distortion tuning
        var thetaMaxDeg: CGFloat = 30            // maximum rotation at edges
        var curvaturePower: CGFloat = 0.8        // foreshortening curve
        var minScaleY: CGFloat = 0.1            // minimum vertical scale at edges
        var edgeXSquash: CGFloat = 0.08          // horizontal squash near edges [0,1]
        var edgeCompression: CGFloat = 100         // legacy (unused) point offset compression
        var edgeCompressionFactor: CGFloat = 0.08 // [0, 0.95] strength of edge compression
        var edgeCompressionExponent: CGFloat = 5 // >= 0.5, curve steepness towards edges
        var minEdgeOpacity: CGFloat = 1       // fade near edges
        var perspective: CGFloat = 1           // 3D perspective strength
    }
}

#Preview {
    @Previewable @State var config: WheelPicker.Config = .init(
        minValue: 0,
        maxValue: 100,
        spacing: 10
    )
    @Previewable @State var value: CGFloat = 10
    
    VStack {
        Text(verbatim: "\(value)")
            .font(.largeTitle.bold())
            .contentTransition(.numericText(value: value))
            .animation(.snappy, value: value)
        WheelPicker(config: config, value: $value)
            .frame(height: 100)
        Divider().padding(.vertical, 8)
        VStack(alignment: .leading, spacing: 12) {
            Text("Cylinder Distortion Controls").font(.headline)
            // thetaMaxDeg
            HStack {
                Text("θ max")
                Slider(
                    value: Binding(
                        get: { Double(config.thetaMaxDeg) },
                        set: { config.thetaMaxDeg = CGFloat($0) }
                    ),
                    in: 0...90
                )
                Text("\(Int(config.thetaMaxDeg))°").monospacedDigit()
            }
            // curvaturePower
            HStack {
                Text("Curvature")
                Slider(
                    value: Binding(
                        get: { Double(config.curvaturePower) },
                        set: { config.curvaturePower = CGFloat($0) }
                    ),
                    in: 0.1...1.5
                )
                Text(String(format: "%.2f", Double(config.curvaturePower))).monospacedDigit()
            }
            // minScaleY
            HStack {
                Text("Min Scale Y")
                Slider(
                    value: Binding(
                        get: { Double(config.minScaleY) },
                        set: { config.minScaleY = CGFloat($0) }
                    ),
                    in: 0.1...1.0
                )
                Text(String(format: "%.2f", Double(config.minScaleY))).monospacedDigit()
            }
            // edgeXSquash
            HStack {
                Text("Edge X Squash")
                Slider(
                    value: Binding(
                        get: { Double(config.edgeXSquash) },
                        set: { config.edgeXSquash = CGFloat($0) }
                    ),
                    in: 0.0...0.4
                )
                Text(String(format: "%.2f", Double(config.edgeXSquash))).monospacedDigit()
            }
            // edgeCompression
            HStack {
                Text("Edge Compression")
                Slider(
                    value: Binding(
                        get: { Double(config.edgeCompression) },
                        set: { config.edgeCompression = CGFloat($0) }
                    ),
                    in: 0...200
                )
                Text(String(format: "%.0f", Double(config.edgeCompression))).monospacedDigit()
            }
            // edgeCompressionFactor
            HStack {
                Text("Edge Compression Factor")
                Slider(
                    value: Binding(
                        get: { Double(config.edgeCompressionFactor) },
                        set: { config.edgeCompressionFactor = CGFloat($0) }
                    ),
                    in: 0.0...0.95
                )
                Text(String(format: "%.2f", Double(config.edgeCompressionFactor))).monospacedDigit()
            }
            // edgeCompressionExponent
            HStack {
                Text("Edge Compression Exponent")
                Slider(
                    value: Binding(
                        get: { Double(config.edgeCompressionExponent) },
                        set: { config.edgeCompressionExponent = CGFloat($0) }
                    ),
                    in: 0.5...10.0
                )
                Text(String(format: "%.2f", Double(config.edgeCompressionExponent))).monospacedDigit()
            }
            // minEdgeOpacity
            HStack {
                Text("Min Edge Opacity")
                Slider(
                    value: Binding(
                        get: { Double(config.minEdgeOpacity) },
                        set: { config.minEdgeOpacity = CGFloat($0) }
                    ),
                    in: 0.0...1.0
                )
                Text(String(format: "%.2f", Double(config.minEdgeOpacity))).monospacedDigit()
            }
            // perspective
            HStack {
                Text("Perspective")
                Slider(
                    value: Binding(
                        get: { Double(config.perspective) },
                        set: { config.perspective = CGFloat($0) }
                    ),
                    in: 0.0...1.5
                )
                Text(String(format: "%.2f", Double(config.perspective))).monospacedDigit()
            }
        }
        .padding(.horizontal)
    }
}
