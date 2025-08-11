//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import PhotosUI

struct ChangeImageView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var pickedColor: ImageColor
    @Binding var imageData: Data?
    
    @State private var pickedColorState: ImageColor
    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var imageDataState: Data? = nil
    @State private var showCamera = false
    
    init(pickedColor: Binding<ImageColor>, imageData: Binding<Data?>) {
        self._pickedColor = pickedColor
        self._pickedColorState = State(initialValue: pickedColor.wrappedValue)
        self._imageData = imageData
        self._imageDataState = State(initialValue: imageData.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            BeanImageView(color: pickedColorState, large: true, imageData: imageDataState)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button(action: {
                        showCamera = true
                    }) {
                        Label("Take photo", systemImage: "camera")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.primary)
                    .bold()
                    .fullScreenCover(isPresented: $showCamera) {
                        ZStack {
                            Color.black.edgesIgnoringSafeArea(.all)
                            CameraPicker { image in
                                if let data = image.jpegData(compressionQuality: 0.9) {
                                    imageDataState = data
                                }
                            }
                        }
                    }

                    PhotosPicker(
                        selection: $pickedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Button(action: {}) {
                            Label("Pick photo", systemImage: "photo.on.rectangle")
                        }
                        .buttonStyle(.bordered)
                        .bold()
                        .foregroundColor(.primary)
                        .allowsHitTesting(false)
                    }
                }
                if imageDataState != nil {
                    Button(role: .destructive ,action: {
                        imageDataState = nil
                        pickedPhoto = nil
                    }) {
                        Label("Remove photo", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .bold()
                }
            }
            
            if imageDataState == nil {
                ColorSwatchGridView(selectedColor: $pickedColorState)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onChange(of: pickedPhoto) {
            Task {
                if let data = try? await pickedPhoto?.loadTransferable(type: Data.self) {
                    imageDataState = data
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        pickedColor = pickedColorState
                        imageData = imageDataState
                        dismiss()
                    }
                }
        }
        .navigationTitle("Change image")
    }
}

#Preview {
    ChangeImageView(pickedColor: .constant(.red), imageData: .constant(nil))
}
