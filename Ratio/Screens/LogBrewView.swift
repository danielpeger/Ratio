//
//  LogBrewView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI
import SwiftData
import AudioToolbox

struct TipsPills: View {
    var brew: Brew
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                Spacer(minLength: 16)
                if let doseMore = brew.tips[0] {
                    PillView(text: "dose \(doseMore ? "more" : "less") than \(brew.dose)g", large: true, selected: true)
                }
                if let grindFiner = brew.tips[1] {
                    PillView(text: "grind \(grindFiner ? "finer" : "coarser") than \(brew.grind)", large: true, selected: true)
                }
                if let yieldMore = brew.tips[2] {
                    PillView(text: "yield \(yieldMore ? "more" : "less") than \(brew.yield)g", large: true, selected: true)
                }
                Spacer(minLength: 16)
            }
        }
    }
}

struct LogBrewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Bean.name) private var beans: [Bean]
    
    var brew: Brew?
    var initialBean: Bean?
    var onDelete: (() -> Void)? = nil
    
    @State private var brewBean: Bean?
    @State private var brewDose: Int = 18
    @State private var brewGrind: Int = 15
    @State private var brewYield: Int = 36
    @State private var brewTime: Int = 28
    @State private var brewRating: Rating = .neutral
    @State private var brewTastes: Set<Taste> = []
    @State private var brewTips: [Bool?] = [nil, nil, nil]
    @State private var brewNotes: String
    @State private var brewPinned: Bool = false
    @State private var createdBrew: Brew? = nil

    @State private var navigateToRateBrew = false
    @State private var saved = false
    @State private var yayHasBeenShown = false

    // Precomputed ranges to simplify type-checking
    private let doseValues = Array(1...50)
    private let grindValues = Array(1...100)
    private let yieldValues = Array(1...100)
    private let timeValues = Array(1...120)
    private var inStockBeans: [Bean] { beans.filter { $0.inStock } }
    
    @State var config: WheelPicker.Config = .init(
        count: 10,
        steps: 10,
        spacing: 10,
        multiplier: 10
    )
    
    // Initialize the view with the following logic:
    // - if you're editing a brew, then the edited brew's settings
    // - otherwise if the selected bean has a pinned brew, then the pinned brew's settings
    // - otherwise if the selected bean has any brews, then the latest brew's settings
    // - otherwise the default settings (18,15,36,28)
    init(brew: Brew? = nil, initialBean: Bean? = nil, onDelete: (() -> Void)? = nil) {
        self.brew = brew
        self.initialBean = initialBean
        self.onDelete = onDelete

        if let editingBrew = brew {
            // Editing: pre-fill with the existing brew completely
            self._brewBean = State(initialValue: editingBrew.bean)
            self._brewDose = State(initialValue: editingBrew.dose)
            self._brewGrind = State(initialValue: editingBrew.grind)
            self._brewYield = State(initialValue: editingBrew.yield)
            self._brewTime = State(initialValue: editingBrew.time)
            self._brewRating = State(initialValue: editingBrew.rating)
            self._brewTastes = State(initialValue: editingBrew.tastes)
            self._brewTips = State(initialValue: editingBrew.tips)
            self._brewNotes = State(initialValue: editingBrew.notes ?? "")
            self._brewPinned = State(initialValue: editingBrew.pinned)
        } else {
            // Creating: prefer template from initial bean (pinned > latest) else defaults
            let source: Brew? = initialBean.flatMap { Self.mostRecentBrew(for: $0) }
            
            self._brewBean = State(initialValue: initialBean)
            self._brewDose = State(initialValue: source?.dose ?? 18)
            self._brewGrind = State(initialValue: source?.grind ?? 15)
            self._brewYield = State(initialValue: source?.yield ?? 36)
            self._brewTime = State(initialValue: source?.time ?? 28)
            // Keep subjective fields at defaults for a new brew
            self._brewRating = State(initialValue: .neutral)
            self._brewTastes = State(initialValue: [])
            self._brewTips = State(initialValue: [nil, nil, nil])
            self._brewNotes = State(initialValue: "")
            self._brewPinned = State(initialValue: false)
        }
    }
    
    // MARK: - Helpers (templates and defaults)
    private static func mostRecentBrew(for bean: Bean) -> Brew? {
        return bean.brews?.sorted(by: { $0.creationDate > $1.creationDate }).first
    }
    
    private func applyTemplate(from source: Brew) {
        brewDose = source.dose
        brewGrind = source.grind
        brewYield = source.yield
        brewTime = source.time
    }
    
    private func resetToDefaults() {
        brewDose = 18
        brewGrind = 15
        brewYield = 36
        brewTime = 28
    }
    
    private func applyTemplateForSelectedBeanIfNeeded() {
        // Do not override values while editing an existing brew
        guard brew == nil else { return }
        guard let selectedBean = brewBean else {
            resetToDefaults()
            return
        }
        if let source = Self.mostRecentBrew(for: selectedBean) {
            applyTemplate(from: source)
        } else {
            resetToDefaults()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    let isCreating = (brew == nil)
                    let mostRecentBrewForSelectedBean: Brew? = brewBean.flatMap { Self.mostRecentBrew(for: $0) }
                    let pinnedBrewForSelectedBean: Brew? = brewBean?.brews?.first(where: { $0.pinned })
                    let shouldShowPinned = isCreating && pinnedBrewForSelectedBean != nil
                    let shouldShowTips = isCreating && (mostRecentBrewForSelectedBean.map { !$0.tipArray.isEmpty } ?? false)
                    
                    if shouldShowPinned, let pinned = pinnedBrewForSelectedBean {
                        VStack(spacing: 0) {
                            SectionHeader(
                                title: "Pinned brew",
                                systemImage: "pin.fill",
                            )
                            LazyVStack(spacing: 0) {
                                BrewCardView(brew: pinned, showPills: false)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    if shouldShowTips, let mostRecent = mostRecentBrewForSelectedBean {
                        VStack(spacing: 0) {
                            SectionHeader(title: "Tips from last brew")
                            TipsPills(brew: mostRecent)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }
                    VStack(spacing: 16) {
                        beanPickerRow
                        dosePickerRow
                        grindPickerRow
                        yieldPickerRow
                        timePickerRow
                        deleteRow
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(brew == nil ? "Log brew" : "Edit brew")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: brewBean) { _, newValue in
                applyTemplateForSelectedBeanIfNeeded()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        navigateToRateBrew = true
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRateBrew) {
                RateBrewView(
                    rating: $brewRating,
                    tastes: $brewTastes,
                    tips: $brewTips,
                    notes: $brewNotes,
                    pinned: $brewPinned,
                    yayHasBeenShown: $yayHasBeenShown,
                    isPinnable: (brewBean != nil),
                    isEditing: brew != nil,
                    originalRating: brew?.rating,
                    onSave: {
                        if let editingBrew = brew {
                            // Update existing brew
                            editingBrew.bean = brewBean
                            editingBrew.dose = brewDose
                            editingBrew.grind = brewGrind
                            editingBrew.yield = brewYield
                            editingBrew.time = brewTime
                            editingBrew.rating = brewRating
                            editingBrew.tastes = brewTastes
                            editingBrew.tips = brewTips
                            editingBrew.notes = brewNotes
                            editingBrew.pinned = brewPinned
                            try? context.save()
                            createdBrew = editingBrew
                        } else {
                            // Create new brew
                            let newBrew = Brew(
                                dose: brewDose,
                                grind: brewGrind,
                                yield: brewYield,
                                time: brewTime,
                                rating: brewRating,
                                tastes: brewTastes,
                                tips: brewTips,
                                notes: brewNotes,
                                bean: brewBean,
                                pinned: brewPinned
                            )
                            context.insert(newBrew)
                            try? context.save()
                            createdBrew = newBrew
                        }
                        saved = true
                    },
                    onDismiss: {
                        dismiss()
                        if saved && !yayHasBeenShown {
                            AudioServicesPlaySystemSound(SystemSoundID(1570))
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    },
                    onYayPinToggle: {
                        if let bean = brewBean, let brew = createdBrew {
                            if brew.pinned {
                                bean.unpinAllBrews()
                            } else {
                                bean.pinBrew(brew)
                            }
                            try? context.save()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Extracted Rows
extension LogBrewView {
    @ViewBuilder
    private var beanPickerRow: some View {
        VStack {
            HStack {
                Text("Beans")
                Spacer()
                Picker("Beans", selection: $brewBean) {
                    Text("Not set").tag(nil as Bean?)
                    ForEach(inStockBeans) { bean in
                        Text(bean.name).tag(bean as Bean?)
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 4)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var dosePickerRow: some View {
        VStack {
            VStack(spacing: 4){
                HStack {
                    Text("Dose")
                    Spacer()
                    NumericText(text: "\(brewDose)g", numericValue: Double(brewDose))
                        .foregroundColor(.secondary)
                        .animation(.snappy, value: brewDose)
                }
                WheelPicker(config: config, value: .init(
                    get: { CGFloat(brewDose) },
                    set: { brewDose = Int($0.rounded()) }
                ))
                    .frame(height: 100)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var grindPickerRow: some View {
        VStack {
            VStack(spacing: 4){
                HStack {
                    Text("Grind")
                    Spacer()
                    NumericText(text: "\(brewGrind)", numericValue: Double(brewGrind))
                        .animation(.snappy, value: brewGrind)
                        .foregroundColor(.secondary)
                }
                WheelPicker(config: config, value: .init(
                    get: { CGFloat(brewGrind) },
                    set: { brewGrind = Int($0.rounded()) }
                ))
                    .frame(height: 100)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var yieldPickerRow: some View {
        VStack {
            VStack(spacing: 4){
                HStack {
                    Text("Yield")
                    Spacer()
                    NumericText(text: "\(brewYield)g", numericValue: Double(brewYield))
                        .foregroundColor(.secondary)
                        .animation(.snappy, value: brewYield)
                }
                WheelPicker(config: config, value: .init(
                    get: { CGFloat(brewYield) },
                    set: { brewYield = Int($0.rounded()) }
                ))
                    .frame(height: 100)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var timePickerRow: some View {
        VStack {
            VStack(spacing: 4){
                HStack {
                    Text("Time")
                    Spacer()
                    NumericText(text: "\(brewTime)s", numericValue: Double(brewTime))
                        .foregroundColor(.secondary)
                        .animation(.snappy, value: brewTime)
                }
                WheelPicker(config: config, value: .init(
                    get: { CGFloat(brewTime) },
                    set: { brewTime = Int($0.rounded()) }
                ))
                    .frame(height: 100)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var deleteRow: some View {
        if let brew = brew {
            Button(role: .destructive) {
                context.delete(brew)
                onDelete?()
                AudioServicesPlaySystemSound(SystemSoundID(1018))
                dismiss()
            } label: {
                Label("Delete brew", systemImage: "trash")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Bean.self, Brew.self, configurations: config)
    }()
    let beans = createMockBeans()
    beans.forEach { container.mainContext.insert($0) }
    return LogBrewView()
        .modelContainer(container)
}
