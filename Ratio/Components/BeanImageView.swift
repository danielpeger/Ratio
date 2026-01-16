//
//  BeanImageView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI
import UIKit
import ImageIO

struct BeanImageView: View {
    var color: ImageColor?
    var large: Bool = false
    var imageData: Data? = nil
    var groupedBgIcon: Bool = false
    var downsampleBeforeDisplay: Bool = true
    private let scanning: Binding<Bool>?
    private let scanningSucceded: Binding<Bool>?
    private let scanningFailed: Binding<Bool>?

    init(
        color: ImageColor? = nil,
        large: Bool = false,
        imageData: Data? = nil,
        groupedBgIcon: Bool = false,
        downsampleBeforeDisplay: Bool = true,
        scanning: Binding<Bool>? = nil,
        scanningSucceded: Binding<Bool>? = nil,
        scanningFailed: Binding<Bool>? = nil
    ) {
        self.color = color
        self.large = large
        self.imageData = imageData
        self.groupedBgIcon = groupedBgIcon
        self.downsampleBeforeDisplay = downsampleBeforeDisplay
        self.scanning = scanning
        self.scanningSucceded = scanningSucceded
        self.scanningFailed = scanningFailed
    }
    
    private var isScanning: Bool { scanning?.wrappedValue ?? false }
    @State private var scanPhase: Bool = false
    private var isSuccess: Bool { scanningSucceded?.wrappedValue ?? false }
    @State private var showSuccessIcon: Bool = false
    @State private var showSuccessText: Bool = false
    private var isFailure: Bool { scanningFailed?.wrappedValue ?? false }
    @State private var showFailureIcon: Bool = false
    @State private var showFailureText: Bool = false
    @State private var cachedImage: UIImage? = nil
    @State private var cachedImageData: Data? = nil
    @State private var cachedTargetSize: CGSize = .zero
    @State private var cachedDownsample: Bool = true

    var body: some View {
        ZStack (alignment: .top){
            if let uiImage = cachedImage {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                    .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                    .clipShape(RoundedRectangle(cornerRadius: large ? 30 : 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: large ? 30 : 11)
                                .strokeBorder(Color(.separator).opacity(0.8), lineWidth: large ? 1.5 : 1)
                        )
                        .shadow(color: large ? .primary.opacity(0.12) : Color.clear, radius: 40, x: 0, y: 20)
                        .shadow(color: large ? .primary.opacity(0.04) : Color.clear, radius: 4, x: 0, y: 2)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                    RoundedRectangle(cornerRadius: large ? 30 : 11)
                        .inset(by: large ? 2 : 1.5)
                        .fill(Color.clear)
                        .stroke(Gradient(colors: [
                            .white.opacity(0.4), .clear
                        ]), lineWidth: large ? 1.5 : 1)
                        .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: large ? 30 : 11)
                        .fill((color ?? .red).color.gradient)
                        .strokeBorder(Color(.separator).opacity(0.8), lineWidth: large ? 1.5 : 1)
                        .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                        .shadow(color: large ? (color ?? .red).color.opacity(0.24) : Color.clear, radius: 40, x: 0, y: 20)
                        .shadow(color: large ? (color ?? .red).color.opacity(0.08) : Color.clear, radius: 4, x: 0, y: 2)
                    RoundedRectangle(cornerRadius: large ? 30 : 11)
                        .inset(by: large ? 2 : 1.5)
                        .fill(Color.clear)
                        .stroke(Gradient(colors: [
                            .white.opacity(0.4), .clear
                        ]), lineWidth: large ? 1.5 : 1)
                        .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                    Image("beanbag")
                        .foregroundColor(groupedBgIcon ? Color(.systemGroupedBackground) : Color(.tertiarySystemBackground))
                        .font(.system(size: large ? 65 : 24))
                }
            }
            if isScanning {
                RoundedRectangle(cornerRadius: 100)
                    .fill(.accent)
                    .frame(width: 160, height: 2)
                    .offset(y: scanPhase ? 119 : -1)
                    .onAppear {
                        scanPhase = false
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                            scanPhase = true
                        }
                    }
                    .onDisappear {
                        scanPhase = false
                    }
            }
        }
        .overlay{
            if isSuccess {
                ZStack{
                    if showSuccessIcon {
                        Color.green.opacity(0.75)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .transition(.opacity)
                    }
                    VStack(spacing: 8){
                        if showSuccessIcon {
                            Image(systemName: "checkmark")
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Image(systemName: "checkmark")
                                .opacity(0)
                        }
                        if showSuccessText {
                            Text("Label info added")
                                .multilineTextAlignment(.center)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Text("Label info added")
                                .multilineTextAlignment(.center)
                                .opacity(0)
                        }
                    }
                    .padding(16)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                }
                .onAppear {
                    showSuccessIcon = false
                    showSuccessText = false
                    withAnimation(.default) { showSuccessIcon = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                        withAnimation(.default) { showSuccessText = true }
                    }
                    // Auto-dismiss with reverse staged transitions after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.default) { showSuccessText = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            withAnimation(.default) { showSuccessIcon = false }
                        }
                    }
                }
                .onDisappear {
                    showSuccessIcon = false
                    showSuccessText = false
                }
            } else if isFailure {
                ZStack{
                    if showFailureIcon {
                        Color.red.opacity(0.75)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .transition(.opacity)
                    }
                    VStack(spacing: 8){
                        if showFailureIcon {
                            Image(systemName: "xmark")
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Image(systemName: "xmark")
                                .opacity(0)
                        }
                        if showFailureText {
                            Text("No coffee info found")
                                .multilineTextAlignment(.center)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Text("No coffee info found")
                                .multilineTextAlignment(.center)
                                .opacity(0)
                        }
                    }
                    .padding(16)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                }
                .onAppear {
                    showFailureIcon = false
                    showFailureText = false
                    withAnimation(.default) { showFailureIcon = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                        withAnimation(.default) { showFailureText = true }
                    }
                    // Auto-dismiss with reverse staged transitions after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.default) { showFailureText = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            withAnimation(.default) { showFailureIcon = false }
                        }
                    }
                }
                .onDisappear {
                    showFailureIcon = false
                    showFailureText = false
                }
            }
        }
        .onAppear {
            updateCachedImage()
        }
        .onChange(of: imageData) { _, _ in
            updateCachedImage()
        }
        .onChange(of: large) { _, _ in
            updateCachedImage()
        }
        .onChange(of: downsampleBeforeDisplay) { _, _ in
            updateCachedImage()
        }
    }
}

private extension BeanImageView {
    var currentTargetSize: CGSize {
        CGSize(width: large ? 240 : 88, height: large ? 240 : 88)
    }

    func updateCachedImage() {
        guard let data = imageData else {
            cachedImage = nil
            cachedImageData = nil
            cachedTargetSize = .zero
            cachedDownsample = downsampleBeforeDisplay
            return
        }

        let targetSize = currentTargetSize
        if cachedImageData == data,
           cachedTargetSize == targetSize,
           cachedDownsample == downsampleBeforeDisplay {
            return
        }

        cachedImageData = data
        cachedTargetSize = targetSize
        cachedDownsample = downsampleBeforeDisplay
        cachedImage = makeUIImage(data: data, targetSize: targetSize, downsample: downsampleBeforeDisplay)
    }

    func makeUIImage(data: Data, targetSize: CGSize, downsample: Bool) -> UIImage? {
        if downsample {
            return downsampledImage(from: data, to: targetSize)
        } else {
            return UIImage(data: data)
        }
    }

    func downsampledImage(from data: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let targetMaxPixels = max(pointSize.width, pointSize.height) * scale
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: targetMaxPixels,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgThumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale
        rendererFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: pointSize, format: rendererFormat)

        let image = renderer.image { ctx in
            ctx.cgContext.interpolationQuality = .high
            let sourceSizePts = CGSize(width: CGFloat(cgThumb.width) / scale, height: CGFloat(cgThumb.height) / scale)
            let fitScale = max(pointSize.width / sourceSizePts.width, pointSize.height / sourceSizePts.height)
            let drawSize = CGSize(width: sourceSizePts.width * fitScale, height: sourceSizePts.height * fitScale)
            let drawOrigin = CGPoint(x: (pointSize.width - drawSize.width) / 2, y: (pointSize.height - drawSize.height) / 2)
            let drawRect = CGRect(origin: drawOrigin, size: drawSize)
            UIImage(cgImage: cgThumb, scale: scale, orientation: .up).draw(in: drawRect)
        }
        return image
    }
}

#Preview {
    @Previewable @State var scanning: Bool = false
    @Previewable @State var scanningSucceded: Bool = false
    @Previewable @State var scanningFailed: Bool = false

    BeanImageView(color: .blue, large:true, scanning: $scanning, scanningSucceded: $scanningSucceded, scanningFailed: $scanningFailed)
    
    Button("toggle scanning") {
        scanning.toggle()
    }
    Button("toggle success") {
        scanningSucceded.toggle()
    }
    Button("toggle fail") {
        scanningFailed.toggle()
    }
    
}
