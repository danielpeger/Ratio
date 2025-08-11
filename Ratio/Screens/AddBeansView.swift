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
    @State private var scanning = false
    @State private var scanningError = false
    
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
                            BeanImageView(color: beanImageColor, large: true, imageData: beanImageData, scanning: scanning)
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
                            } icon: {
                                Image("scan.beanbag")
                            }
                        }
                        .foregroundColor(.primary)
                        .buttonStyle(.bordered)
                        .fullScreenCover(isPresented: $showCamera) {
                            ZStack {
                                Color.black.edgesIgnoringSafeArea(.all)
                                CameraPicker { image in
                                    if let data = image.jpegData(compressionQuality: 0.9) {
                                        beanImageData = data
                                        scanBagImage(imageData: data)
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
                                    scanBagImage(imageData: data)
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
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
            .alert(isPresented: $scanningError) {
                Alert(title: Text("Error scanning image"), message: Text("Ratio couldn't scan your image for some reason."), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func scanBagImage(imageData: Data) {
        self.scanning = true
        sendGptImageRequest(imageData: imageData) { response in
            if let parsed = response {
                if let name = parsed.name, !name.isEmpty { self.beanName = name }
                if let roaster = parsed.roaster { self.beanRoaster = roaster }
                if let origin = parsed.origin { self.beanOrigin = origin }
                if let processing = parsed.processing { self.beanProcessing = processing }
                self.scanning = false
            } else {
                self.scanningError = true
                self.scanning = false
            }
        }
    }
}

#Preview {
    AddBeansView()
}
