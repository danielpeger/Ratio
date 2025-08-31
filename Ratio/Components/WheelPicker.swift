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
                            .fill(isCenter ? Color.red : (isTenMultiple ? .primary.opacity(0.5) : .secondary.opacity(0.5)))
                            .transaction { t in
                                t.disablesAnimations = true
                            }
                            .frame(width: 1, height: 100, alignment: .bottom)
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
                            .visualEffect { content, proxy in
                                let rect = proxy.frame(in: .named("WHEEL"))
                                let centerX = size.width / 2
                                let signedDistance = rect.midX - centerX
                                let maxDistance = max(centerX, 1)
                                // Normalize to [-1, 1]
                                let t = max(min(signedDistance / maxDistance, 1), -1)
                                // Map horizontal position to an angular curve; adjust thetaMaxDeg to change curvature
                                let thetaMaxDeg: CGFloat = 40
                                let theta = (t * thetaMaxDeg) * .pi / 180
                                // Rotation directly uses theta for a cylindrical feel
                                let angle = Angle(radians: Double(theta))
                                // Perspective foreshortening approximation using cos(theta). Raise power for a tighter curve
                                let curvaturePower: CGFloat = 1
                                let scaleY = pow(cos(theta), curvaturePower)
                                let clampedScaleY = max(scaleY, 0.35)
                                return content
                                    .rotation3DEffect(angle, axis: (x: 0, y: 1, z: 0), anchor: .bottom, perspective: 1)
                                    .scaleEffect(y: clampedScaleY, anchor: .center)
                            }
                             */
                             
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedScrollId)
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
                    // Initialize scroll position from the current value once loaded
                    let clamped = Int(min(max(round(value), CGFloat(config.minValue)), CGFloat(config.maxValue)))
                    selectedScrollId = clamped - config.minValue
                }
            }
            .coordinateSpace(name: "WHEEL")
            // Edge fade overlays
            .overlay(alignment: .leading) {
                LinearGradient(colors: [Color(.secondarySystemGroupedBackground), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 32)
                    .frame(maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .trailing) {
                LinearGradient(colors: [.clear, Color(.secondarySystemGroupedBackground)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 32)
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
    }
}
