//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import PhotosUI

struct AddBeansView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    var bean: Bean?
    
    @State private var beanName: String = ""
    @State private var beanRoaster: String = ""
    @State private var beanOrigin: Origin = .notSet
    @State private var beanProcessing: Processing = .notSet
    @State private var beanInStock: Bool = true
    @State private var beanImageColor: ImageColor = .red
    @State private var beanImageData: Data?
    
    @State private var showCamera = false
    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var showPhotoPicker = false
    @State private var scannedText = "Not scanned anything"
    
    init(bean: Bean? = nil) {
        self.bean = bean
        _beanName = State(initialValue: bean?.name ?? "")
        _beanRoaster = State(initialValue: bean?.roaster ?? "")
        _beanOrigin = State(initialValue: bean?.origin ?? .notSet)
        _beanProcessing = State(initialValue: bean?.processing ?? .notSet)
        _beanInStock = State(initialValue: bean?.inStock ?? true)
        _beanImageColor = State(initialValue: bean?.imageColor ?? .red)
        _beanImageData = State(initialValue: bean?.imageData)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 24) {
                            BeanImageView(color: beanImageColor, large: true, imageData: beanImageData)
                            if beanImageData == nil {
                                HStack(spacing: 16) {
                                    ForEach(ImageColor.allCases, id: \.self) { color in
                                        ColorSwatchView(
                                            color: color.color,
                                            isSelected: beanImageColor == color
                                        )
                                        .onTapGesture {
                                            beanImageColor = color
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button {
                                showCamera = true
                            } label: {
                                Label("Take photo", systemImage: "camera")
                            }
                            Button {
                                showPhotoPicker = true
                            } label: {
                                Label("Pick photo", systemImage: "photo.on.rectangle")
                            }
                        } label: {
                            Label {
                                Text("Scan bag")
                                    .fontWeight(.semibold)
                                    .font(.title3)
                            } icon: {
                                Image("scan.beanbag")
                                    .font(.title3)
                            }
                            .labelStyle(CustomLabel(spacing: 8))
                        }
                        .foregroundColor(.primary)
                        .buttonStyle(.bordered)
                        .fullScreenCover(isPresented: $showCamera) {
                            ZStack {
                                Color.black.edgesIgnoringSafeArea(.all)
                                CameraPicker { image in
                                    if let data = image.jpegData(compressionQuality: 0.9) {
                                        beanImageData = data
                                        // recognizeTextFromImageData(data) { updated in
                                        //     scannedText = updated
                                        // }
                                        jsonFromBagImage(imageData: data)
                                    }
                                }
                            }
                        }
                        .photosPicker(isPresented: $showPhotoPicker,
                                       selection: $pickedPhoto,
                                       matching: .images,
                                       photoLibrary: .shared())
                        .onChange(of: pickedPhoto) {
                            Task {
                                if let data = try? await pickedPhoto?.loadTransferable(type: Data.self) {
                                    beanImageData = data
                                    // recognizeTextFromImageData(data) { updated in
                                    //     scannedText = updated
                                    // }
                                    jsonFromBagImage(imageData: data)
                                }
                            }
                        }

                        if beanImageData != nil {
                            Button(role: .destructive ,action: {
                                beanImageData = nil
                                pickedPhoto = nil
                            }) {
                                Label("Remove photo", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)
                            .bold()
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    Text(scannedText)
                }
                
                Section {
                    TextField("Name", text: $beanName)
                    TextField("Roaster", text: $beanRoaster)
                    Picker("Origin", selection: $beanOrigin) {
                        ForEach(Origin.allCases) { origin in
                            Text(origin.rawValue)
                        }
                    }
                    Picker("Processing", selection: $beanProcessing) {
                        ForEach(Processing.allCases) { processing in
                            Text(processing.rawValue)
                        }
                    }
                  }

                  Section {
                      Toggle("In stock", isOn: $beanInStock)
                  }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(bean == nil ? "Add" : "Save") {
                        if let bean = bean {
                            bean.name = beanName
                            bean.roaster = beanRoaster
                            bean.origin = beanOrigin
                            bean.processing = beanProcessing
                            bean.inStock = beanInStock
                            bean.imageColor = beanImageColor
                            bean.imageData = beanImageData

                            // Add haptic feedback
                            let notificationFeedback = UINotificationFeedbackGenerator()
                            notificationFeedback.notificationOccurred(.success)
                        } else {
                            let newBean = Bean(name: beanName, roaster: beanRoaster, origin: beanOrigin, processing: beanProcessing, inStock: beanInStock, imageColor: beanImageColor, imageData: beanImageData)
                            context.insert(newBean)
                            
                            // Add haptic feedback
                            let notificationFeedback = UINotificationFeedbackGenerator()
                            notificationFeedback.notificationOccurred(.success)
                        }
                        dismiss()
                    }
                    .disabled(beanName.isEmpty)
                }
            }
            .navigationTitle(bean == nil ? "Add beans" : "Edit beans")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func jsonFromBagImage(imageData: Data) {
        self.scannedText = "Parsing..."
        sendGptImageRequest(imageData: imageData) { jsonResponse in
            if let jsonResponse = jsonResponse {
                self.scannedText = "\(jsonResponse)"
            } else {
                self.scannedText = "Failed to get a gpt response"
            }
        }
    }
}

#Preview {
    AddBeansView()
}
