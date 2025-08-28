//
//  BeanImageView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI

struct BeanImageView: View {
    var color: ImageColor?
    var large: Bool = false
    var imageData: Data? = nil
    var groupedBgIcon: Bool = false
    private let scanning: Binding<Bool>?
    private let scanningSucceded: Binding<Bool>?
    private let scanningFailed: Binding<Bool>?

    init(
        color: ImageColor? = nil,
        large: Bool = false,
        imageData: Data? = nil,
        groupedBgIcon: Bool = false,
        scanning: Binding<Bool>? = nil,
        scanningSucceded: Binding<Bool>? = nil,
        scanningFailed: Binding<Bool>? = nil
    ) {
        self.color = color
        self.large = large
        self.imageData = imageData
        self.groupedBgIcon = groupedBgIcon
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

    var body: some View {
        ZStack (alignment: .top){
            if let data = imageData, let uiImage = UIImage(data: data) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                        .clipShape(RoundedRectangle(cornerRadius: large ? 30 : 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: large ? 30 : 11)
                                .strokeBorder(Color(.separator).opacity(0.7), lineWidth: large ? 1.5 : 1)
                        )
                        .shadow(color: large ? .primary.opacity(0.12) : Color.clear, radius: 40, x: 0, y: 20)
                        .shadow(color: large ? .primary.opacity(0.04) : Color.clear, radius: 4, x: 0, y: 2)
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
                        .strokeBorder(Color(.separator).opacity(0.7), lineWidth: large ? 1.5 : 1)
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
                            Text("Bean info added")
                                .multilineTextAlignment(.center)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Text("Bean info added")
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
                            Text("No bean info found")
                                .multilineTextAlignment(.center)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Text("No bean info found")
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
