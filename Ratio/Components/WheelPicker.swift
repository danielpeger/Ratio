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
    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.width / 2
            let maxValue = CGFloat(config.count * config.multiplier)
            
            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) { index in
                        let remainder = index % config.steps
                        // Ensure the divider at the center (matching current value) is 120pt tall
                        let centerIndex = Int(round((value * CGFloat(config.steps)) / CGFloat(config.multiplier)))
                        let isCenter = index == centerIndex
                        let baseHeight: CGFloat = isCenter ? 100 : (remainder == 0 ? 90 : 80)
                        
                        Rectangle()
                            .fill(isCenter ? Color.red : (remainder == 0 ? Color(.systemGray2) : Color(.systemGray5)))
                            .frame(width: 1, height: baseHeight, alignment: .bottom)
                            .frame(maxHeight: 100, alignment: .bottom)
                            /*
                            .overlay(alignment: .bottom) {
                                if remainder == 0 && config.showsText {
                                    Text("\((index / config.steps) * config.multiplier)")
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
                                // Map horizontal position to an angular curve; adjust thetaMaxDeg to change curvature
                                let thetaMaxDeg: CGFloat = 60
                                let theta = (t * thetaMaxDeg) * .pi / 180
                                // Rotation directly uses theta for a cylindrical feel
                                let angle = Angle(radians: Double(theta))
                                // Perspective foreshortening approximation using cos(theta). Raise power for a tighter curve
                                let curvaturePower: CGFloat = 0.4
                                let scaleY = pow(cos(theta), curvaturePower)
                                let clampedScaleY = max(scaleY, 0.35)
                                return content
                                    .rotation3DEffect(angle, axis: (x: 0, y: 1, z: 0), anchor: .bottom, perspective: 1)
                                    .scaleEffect(y: clampedScaleY, anchor: .center)
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.15), value: value)
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? (Int(value) * config.steps) / config.multiplier : nil
                return position
            }, set: { newValue in
                if let newValue { 
                    value = (CGFloat(newValue) / CGFloat(config.steps)) * CGFloat(config.multiplier)
                    UISelectionFeedbackGenerator().selectionChanged()
                    AudioServicesPlaySystemSound(SystemSoundID(1479))
                }
            }))
            /*
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(Color(.accent))
                    .frame(width: 1, height: 120)
                    .padding(.bottom, 10)
            }
             */
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { tap in
                        let isRightHalf = tap.location.x > 0
                        withAnimation {
                            if isRightHalf {
                                value = min(value + 1, maxValue)
                            } else {
                                value = max(value - 1, 0)
                            }
                        }
                    }
            )
            .safeAreaPadding(.horizontal, horizontalPadding)
            .onAppear {
                if !isLoaded { isLoaded = true }
            }
            .coordinateSpace(name: "WHEEL")
        }
        /// Optional
        .onChange(of: config) { oldValue, newValue in
            value = 0
        }
    }
    
    /// Picker Configuration
    struct Config: Equatable {
        var count: Int
        var steps: Int = 10
        var spacing: CGFloat = 5
        var multiplier: Int = 10
        var showsText: Bool = true
    }
}

#Preview {
    @Previewable @State var config: WheelPicker.Config = .init(
        count: 10,
        steps: 10,
        spacing: 10,
        multiplier: 10
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
