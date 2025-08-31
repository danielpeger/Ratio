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
    @Query(sort: \Bean.name) private var beans: [Bean] // keep, but avoid using in body
    @Query(sort: \Brew.creationDate, order: .reverse) private var allBrews: [Brew] // keep, but avoid using in body
    
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

    // Track initial values to detect unsaved edits
    @State private var initialBeanId: PersistentIdentifier? = nil
    @State private var initialDose: Int = 18
    @State private var initialGrind: Int = 15
    @State private var initialYield: Int = 36
    @State private var initialTime: Int = 28
    @State private var initialRating: Rating = .neutral
    @State private var initialTastes: Set<Taste> = []
    @State private var initialTips: [Bool?] = [nil, nil, nil]
    @State private var initialNotes: String = ""
    @State private var initialPinned: Bool = false

    @State private var showDiscardAlert: Bool = false

    @State private var navigateToRateBrew = false
    @State private var saved = false
    @State private var yayHasBeenShown = false

    @State private var beansList: [Bean] = []
    @State private var allBrewsList: [Brew] = []
    private var inStockBeans: [Bean] { beansList.filter { $0.inStock } }
    // Cache bean-derived sections to avoid SwiftData relationship work during wheel updates
    @State private var cachedShowPinned: Bool = false
    @State private var cachedPinnedBrewId: PersistentIdentifier? = nil
    @State private var cachedShowTips: Bool = false
    @State private var cachedTipsSourceId: PersistentIdentifier? = nil
    // Snapshot + stable selection id to avoid SwiftData work during unrelated updates
    @State private var beansSnapshot: [(id: PersistentIdentifier, name: String)] = []
    @State private var selectedBeanId: PersistentIdentifier? = nil
    
    @State var doseConfig: WheelPicker.Config = .init(
        minValue: 1,
        maxValue: 50,
        spacing: 10
    )
    @State var grindYieldConfig: WheelPicker.Config = .init(
        minValue: 1,
        maxValue: 100,
        spacing: 10
    )
    @State var timeConfig: WheelPicker.Config = .init(
        minValue: 1,
        maxValue: 120,
        spacing: 10
    )

    // Persisted expansion states for each picker row
    @AppStorage("LogBrewView.expand.dose") private var isDoseExpanded: Bool = false
    @AppStorage("LogBrewView.expand.grind") private var isGrindExpanded: Bool = true
    @AppStorage("LogBrewView.expand.yield") private var isYieldExpanded: Bool = true
    @AppStorage("LogBrewView.expand.time") private var isTimeExpanded: Bool = true
    
    // Pre-built bindings to simplify generic expressions for WheelPicker
    private var doseBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: { CGFloat(brewDose) },
            set: { brewDose = Int($0.rounded()) }
        )
    }
    private var grindBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: { CGFloat(brewGrind) },
            set: { brewGrind = Int($0.rounded()) }
        )
    }
    private var yieldBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: { CGFloat(brewYield) },
            set: { brewYield = Int($0.rounded()) }
        )
    }
    private var timeBinding: Binding<CGFloat> {
        Binding<CGFloat>(
            get: { CGFloat(brewTime) },
            set: { brewTime = Int($0.rounded()) }
        )
    }
    
    // Initialize the view with the following logic:
    // - if you're editing a brew, then the edited brew's settings
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

            // Snapshot initial values for dirty-check
            self._initialBeanId = State(initialValue: editingBrew.bean?.persistentModelID)
            self._initialDose = State(initialValue: editingBrew.dose)
            self._initialGrind = State(initialValue: editingBrew.grind)
            self._initialYield = State(initialValue: editingBrew.yield)
            self._initialTime = State(initialValue: editingBrew.time)
            self._initialRating = State(initialValue: editingBrew.rating)
            self._initialTastes = State(initialValue: editingBrew.tastes)
            self._initialTips = State(initialValue: editingBrew.tips)
            self._initialNotes = State(initialValue: editingBrew.notes ?? "")
            self._initialPinned = State(initialValue: editingBrew.pinned)
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

            // Snapshot initial values for dirty-check
            self._initialBeanId = State(initialValue: initialBean?.persistentModelID)
            self._initialDose = State(initialValue: source?.dose ?? 18)
            self._initialGrind = State(initialValue: source?.grind ?? 15)
            self._initialYield = State(initialValue: source?.yield ?? 36)
            self._initialTime = State(initialValue: source?.time ?? 28)
            self._initialRating = State(initialValue: .neutral)
            self._initialTastes = State(initialValue: [])
            self._initialTips = State(initialValue: [nil, nil, nil])
            self._initialNotes = State(initialValue: "")
            self._initialPinned = State(initialValue: false)
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

    private func formIsDirty() -> Bool {
        let currentBeanId = brewBean?.persistentModelID
        return currentBeanId != initialBeanId ||
               brewDose != initialDose ||
               brewGrind != initialGrind ||
               brewYield != initialYield ||
               brewTime != initialTime ||
               brewRating != initialRating ||
               brewTastes != initialTastes ||
               brewTips != initialTips ||
               brewNotes != initialNotes ||
               brewPinned != initialPinned
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
                    pinnedSection
                    tipsSection
                    VStack(spacing: 16) {
                        beanPickerRow
                        PickerRow(
                            title: "Dose",
                            numericText: "\(brewDose)g",
                            numericValue: Double(brewDose),
                            value: doseBinding,
                            config: doseConfig,
                            isExpanded: $isDoseExpanded
                        )
                        PickerRow(
                            title: "Grind",
                            numericText: "\(brewGrind)",
                            numericValue: Double(brewGrind),
                            value: grindBinding,
                            config: grindYieldConfig,
                            isExpanded: $isGrindExpanded
                        )
                        PickerRow(
                            title: "Yield",
                            numericText: "\(brewYield)g",
                            numericValue: Double(brewYield),
                            value: yieldBinding,
                            config: grindYieldConfig,
                            isExpanded: $isYieldExpanded
                        )
                        PickerRow(
                            title: "Time",
                            numericText: "\(brewTime)s",
                            numericValue: Double(brewTime),
                            value: timeBinding,
                            config: timeConfig,
                            isExpanded: $isTimeExpanded
                        )
                        deleteRow
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(brew == nil ? "Log brew" : "Edit brew")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: setupOnAppear)
            // Intentionally avoid observing @Query during drag; provide manual refresh triggers elsewhere if needed
            .onChange(of: selectedBeanId) { _, newId in
                handleSelectedBeanIdChange(newId)
            }
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
                    Button("Next") {
                        navigateToRateBrew = true
                    }
                }
            }
            .confirmationDialog("Discard changes?", isPresented: $showDiscardAlert, titleVisibility: .hidden) {
                Button("Discard changes", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) { }
            }
            .interactiveDismissDisabled(formIsDirty())
            .navigationDestination(isPresented: $navigateToRateBrew) {
                rateDestination
            }
        }
    }
}

// MARK: - Extracted Rows
extension LogBrewView {
    private var pinnedSection: some View {
        Group {
            if (brew == nil), cachedShowPinned, let pinnedId = cachedPinnedBrewId, let pinned = allBrewsList.first(where: { $0.persistentModelID == pinnedId }) {
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
        }
    }

    private var tipsSection: some View {
        Group {
            if (brew == nil), cachedShowTips, let tipsId = cachedTipsSourceId, let mostRecent = allBrewsList.first(where: { $0.persistentModelID == tipsId }) {
                VStack(spacing: 0) {
                    SectionHeader(title: "Tips from last brew")
                    TipsPills(brew: mostRecent)
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
    }

    private func setupOnAppear() {
        selectedBeanId = brewBean?.persistentModelID
        beansList = (try? context.fetch(FetchDescriptor<Bean>(sortBy: [SortDescriptor(\.name)]))) ?? []
        allBrewsList = (try? context.fetch(FetchDescriptor<Brew>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)]))) ?? []
        beansSnapshot = inStockBeans.map { ($0.persistentModelID, $0.name) }
        let isCreating = (brew == nil)
        if isCreating {
            if let bean = brewBean {
                let pinned = bean.brews?.first(where: { $0.pinned })
                cachedShowPinned = (pinned != nil)
                cachedPinnedBrewId = pinned?.persistentModelID
                let mostRecentForBean = Self.mostRecentBrew(for: bean)
                cachedShowTips = (mostRecentForBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentForBean?.persistentModelID
            } else {
                cachedShowPinned = false
                let mostRecentNoBean = allBrewsList.first(where: { $0.bean == nil })
                cachedShowTips = (mostRecentNoBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentNoBean?.persistentModelID
            }
        } else {
            cachedShowPinned = false
            cachedShowTips = false
            cachedPinnedBrewId = nil
            cachedTipsSourceId = nil
        }
    }

    private func handleBeanChange(_ newValue: Bean?) {
        applyTemplateForSelectedBeanIfNeeded()
        selectedBeanId = newValue?.persistentModelID
        let isCreating = (brew == nil)
        if isCreating {
            if let bean = newValue {
                let pinned = bean.brews?.first(where: { $0.pinned })
                cachedShowPinned = (pinned != nil)
                cachedPinnedBrewId = pinned?.persistentModelID
                let mostRecentForBean = Self.mostRecentBrew(for: bean)
                cachedShowTips = (mostRecentForBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentForBean?.persistentModelID
            } else {
                cachedShowPinned = false
                let mostRecentNoBean = allBrewsList.first(where: { $0.bean == nil })
                cachedShowTips = (mostRecentNoBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentNoBean?.persistentModelID
            }
        } else {
            cachedShowPinned = false
            cachedShowTips = false
            cachedPinnedBrewId = nil
            cachedTipsSourceId = nil
        }
    }

    private func handleSelectedBeanIdChange(_ newId: PersistentIdentifier?) {
        let currentId = brewBean?.persistentModelID
        if newId != currentId {
            brewBean = newId.flatMap { id in beansList.first(where: { $0.persistentModelID == id }) }
        }
        // Update cached sections when selection changes
        let isCreating = (brew == nil)
        if isCreating {
            if let bean = brewBean {
                let pinned = bean.brews?.first(where: { $0.pinned })
                cachedShowPinned = (pinned != nil)
                cachedPinnedBrewId = pinned?.persistentModelID
                let mostRecentForBean = Self.mostRecentBrew(for: bean)
                cachedShowTips = (mostRecentForBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentForBean?.persistentModelID
            } else {
                cachedShowPinned = false
                let mostRecentNoBean = allBrewsList.first(where: { $0.bean == nil })
                cachedShowTips = (mostRecentNoBean?.tipArray.isEmpty == false)
                cachedTipsSourceId = mostRecentNoBean?.persistentModelID
            }
        } else {
            cachedShowPinned = false
            cachedShowTips = false
            cachedPinnedBrewId = nil
            cachedTipsSourceId = nil
        }
    }
    
    private var rateDestination: some View {
        let isPinnable = (brewBean != nil)
        let isEditing = (brew != nil)
        let originalRating = brew?.rating
        return RateBrewView(
            rating: $brewRating,
            tastes: $brewTastes,
            tips: $brewTips,
            notes: $brewNotes,
            pinned: $brewPinned,
            yayHasBeenShown: $yayHasBeenShown,
            isPinnable: isPinnable,
            isEditing: isEditing,
            originalRating: originalRating,
            onSave: { saveBrew() },
            onDismiss: { handleRateDismiss() },
            onYayPinToggle: { toggleYayPin() }
        )
    }

    @ViewBuilder
    private var beanPickerRow: some View {
        VStack {
            HStack {
                Text("Beans")
                Spacer()
                Picker("Beans", selection: Binding<PersistentIdentifier?>(
                    get: { selectedBeanId },
                    set: { selectedBeanId = $0 }
                )) {
                    Text("Not set").tag(nil as PersistentIdentifier?)
                    ForEach(beansSnapshot, id: \.id) { item in
                        Text(item.name).tag(item.id as PersistentIdentifier?)
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 4)
            .padding(.vertical, 5)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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

    private func saveBrew() {
        if let editingBrew = brew {
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
    }

    private func handleRateDismiss() {
        dismiss()
        if saved && !yayHasBeenShown {
            AudioServicesPlaySystemSound(SystemSoundID(1570))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func toggleYayPin() {
        if let bean = brewBean, let brew = createdBrew {
            if brew.pinned {
                bean.unpinAllBrews()
            } else {
                bean.pinBrew(brew)
            }
            try? context.save()
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
