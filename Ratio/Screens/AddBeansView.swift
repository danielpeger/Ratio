//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import PhotosUI
import SwiftData
import AudioToolbox

struct AddBeansView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    var bean: Bean?
    var onDelete: (() -> Void)? = nil
    
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
    @State private var scanningSucceded = false
    @State private var scanningFailed = false
    @State private var scanSoundTimer: DispatchSourceTimer? = nil
    
    @State private var showDeleteAlert: Bool = false
    @State private var beanPendingDeletion: Bean? = nil
    @State private var showDiscardAlert: Bool = false
    
    @Query private var beans: [Bean]

    private var uniqueRoasters: [String] {
    Array(
        Set(
            beans.compactMap { $0.roaster?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            )
    ).sorted()
    }
    
    enum Field: Hashable { case name, roaster, none }
    @FocusState private var focusedField: Field?
    
    private var filteredRoasters: [String] {
        guard !beanRoaster.isEmpty else { return uniqueRoasters }
        return uniqueRoasters.filter { $0.localizedCaseInsensitiveContains(beanRoaster) }
    }
    
    private func formIsDirty() -> Bool {
        if bean == nil {
            return !beanName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                   !beanRoaster.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                   beanOrigin != .notSet ||
                   beanProcessing != .notSet
        } else {
            return beanName != (bean?.name ?? "") ||
                   beanRoaster != (bean?.roaster ?? "") ||
                   beanOrigin != (bean?.origin ?? .notSet) ||
                   beanProcessing != (bean?.processing ?? .notSet)
        }
    }
    
    init(bean: Bean? = nil, onDelete: (() -> Void)? = nil) {
        self.bean = bean
        self.onDelete = onDelete
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
                VStack(spacing: 16) {
                    VStack(spacing: 20) {
                        BeanImageView(color: beanImageColor, large: true, imageData: beanImageData,groupedBgIcon: true, scanning: $scanning, scanningSucceded: $scanningSucceded, scanningFailed: $scanningFailed)
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
                    .padding(.top, 32)

                    VStack(spacing: 8) {
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
                            HStack{
                                if (!scanning) {
                                    Image("scan.beanbag")
                                        .font(.system(size: 18))
                                }
                                Text(scanning ? "Scanning..." : "Scan label")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                        }
                        .disabled(scanning)
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
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
                        
                        if beanImageData != nil && !scanning {
                            Button(role: .destructive ,action: {
                                beanImageData = nil
                                pickedPhoto = nil
                            }) {
                                HStack{
                                    Image(systemName: "trash")
                                        .font(.system(size: 18))
                                    Text("Remove photo")
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                            }
                            .buttonStyle(.bordered)
                            .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))    
                
                Section {
                    TextField("Name", text: $beanName)
                        .focused($focusedField, equals: .name)
                        .onSubmit { focusedField = .roaster }
                    TextField("Roaster", text: $beanRoaster)
                        .focused($focusedField, equals: .roaster)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                        .onSubmit { focusedField = nil }
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
                
                if let bean = bean {
                    Section {
                        Button(role: .destructive) {
                            if let brews = bean.brews, !brews.isEmpty {
                                beanPendingDeletion = bean
                                showDeleteAlert = true
                            } else {
                                context.delete(bean)
                                AudioServicesPlaySystemSound(SystemSoundID(1018))
                                onDelete?()
                                dismiss()
                            }
                        } label: {
                            Label("Delete bean", systemImage: "trash")
                        }
                    }
                }
            }
            .contentMargins(.top, 0)
            .listSectionSpacing(32)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if formIsDirty() {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
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
                        } else {
                            let newBean = Bean(name: beanName, roaster: beanRoaster, origin: beanOrigin, processing: beanProcessing, inStock: beanInStock, imageColor: beanImageColor, imageData: beanImageData)
                            context.insert(newBean)
                            
                            // Add haptic feedback
                            let notificationFeedback = UINotificationFeedbackGenerator()
                            notificationFeedback.notificationOccurred(.success)
                        }
                        dismiss()
                        AudioServicesPlaySystemSound(SystemSoundID(1570))
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    .disabled(beanName.isEmpty)
                }
                if focusedField == .roaster {
                    ToolbarItemGroup(placement: .keyboard) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(uniqueRoasters.filter { beanRoaster.isEmpty ? true : $0.localizedCaseInsensitiveContains(beanRoaster) }.prefix(10), id: \.self) { suggestion in
                                    Button {
                                        beanRoaster = suggestion
                                    } label: {
                                        Text(suggestion)
                                            .font(.callout)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(.ultraThinMaterial, in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle(bean == nil ? "Add bean" : "Edit bean")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $scanningError) {
                Alert(title: Text("Error scanning image"), message: Text("Ratio couldn't scan your image for some reason."), dismissButton: .default(Text("OK")))
            }
            .alert("Discard edits?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Don't discard", role: .cancel) { }
            }
            .interactiveDismissDisabled(formIsDirty())
            .onAppear {
                focusedField = .name 
            }
        }
        .alert("Delete bean?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let beanToDelete = beanPendingDeletion {
                    context.delete(beanToDelete)
                    AudioServicesPlaySystemSound(SystemSoundID(1018))
                    onDelete?()
                    dismiss()
                }
                beanPendingDeletion = nil
            }
        } message: {
            Text("Deleting this bean will also delete all of its brews.")
        }
        .onChange(of: scanning) { _, isNowScanning in
            if isNowScanning {
                startScanSoundTimer()
            } else {
                stopScanSoundTimer()
            }
        }
        .onDisappear {
            stopScanSoundTimer()
            focusedField = nil
        }
    }
    
    private func scanBagImage(imageData: Data) {
        self.scanning = true
        self.scanningSucceded = false
        self.scanningFailed = false
        sendGptImageRequest(imageData: imageData) { response in
            if let parsed = response {
                if let name = parsed.name, !name.isEmpty { self.beanName = name }
                if let roaster = parsed.roaster { self.beanRoaster = roaster }
                if let origin = parsed.origin { self.beanOrigin = origin }
                if let processing = parsed.processing { self.beanProcessing = processing }
                self.scanning = false
                let hasAny = (parsed.name != nil) || (parsed.roaster != nil) || (parsed.origin != nil) || (parsed.processing != nil)
                if hasAny {
                    self.scanningSucceded = true
                    AudioServicesPlaySystemSound(SystemSoundID(1504))
                } else {
                    self.scanningFailed = true
                    AudioServicesPlaySystemSound(SystemSoundID(1053))
                }
            } else {
                self.scanningError = true
                self.scanning = false
            }
        }
    }

    private func startScanSoundTimer() {
        stopScanSoundTimer()
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: 1.7)
        timer.setEventHandler {
            if self.scanning {
                AudioServicesPlaySystemSound(SystemSoundID(1117))
            } else {
                self.stopScanSoundTimer()
            }
        }
        timer.resume()
        scanSoundTimer = timer
    }

    private func stopScanSoundTimer() {
        scanSoundTimer?.cancel()
        scanSoundTimer = nil
    }
}

#Preview {
    AddBeansView()
}
