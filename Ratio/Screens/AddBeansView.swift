//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI

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
    
    @State private var navigateToChangeImage = false
    
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
                        
                        VStack(spacing: 12) {
                            BeanImageView(color: beanImageColor, large: true, imageData: beanImageData)
                            Button("Change image") {
                                navigateToChangeImage = true
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.primary)
                            .bold()
                        }
                        .contentShape(Rectangle()) // Expand tappable area
                        .onTapGesture {
                            navigateToChangeImage = true
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
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
            .navigationDestination(isPresented: $navigateToChangeImage) {
                ChangeImageView(pickedColor: $beanImageColor, imageData: $beanImageData)
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
}

#Preview {
    AddBeansView()
}
