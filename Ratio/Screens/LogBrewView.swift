//
//  LogBrewView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI
import SwiftData

struct LogBrewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Bean.name) private var beans: [Bean]
    
    var brew: Brew?
    var initialBean: Bean?
    
    @State private var brewBean: Bean?
    @State private var brewDose: Int = 18
    @State private var brewGrind: Int = 15
    @State private var brewYield: Int = 36
    @State private var brewTime: Int = 28
    @State private var brewRating: Rating = .neutral
    @State private var brewTastes: Set<Taste> = []
    @State private var brewTips: [Bool?] = [nil, nil, nil]
    @State private var brewNotes: String?
    @State private var brewPinned: Bool = false
    @State private var createdBrew: Brew? = nil

    @State private var navigateToRateBrew = false

    // Initialize the view with the following logic:
    // - if you're editing a brew, then the edited brew's settings
    // - otherwise if the selected bean has a pinned brew, then the pinned brew's settings
    // - otherwise if the selected bean has any brews, then the latest brew's settings
    // - otherwise the default settings (18,15,36,28)
    init(brew: Brew? = nil, initialBean: Bean? = nil) {
        self.brew = brew
        self.initialBean = initialBean

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
            self._brewNotes = State(initialValue: editingBrew.notes)
            self._brewPinned = State(initialValue: editingBrew.pinned)
        } else {
            // Creating: prefer template from initial bean (pinned > latest) else defaults
            let source: Brew? = initialBean.flatMap { Self.templateBrew(for: $0) }

            self._brewBean = State(initialValue: initialBean)
            self._brewDose = State(initialValue: source?.dose ?? 18)
            self._brewGrind = State(initialValue: source?.grind ?? 15)
            self._brewYield = State(initialValue: source?.yield ?? 36)
            self._brewTime = State(initialValue: source?.time ?? 28)
            // Keep subjective fields at defaults for a new brew
            self._brewRating = State(initialValue: .neutral)
            self._brewTastes = State(initialValue: [])
            self._brewTips = State(initialValue: [nil, nil, nil])
            self._brewNotes = State(initialValue: nil)
            self._brewPinned = State(initialValue: false)
        }
    }

    // MARK: - Helpers (templates and defaults)
    private static func templateBrew(for bean: Bean) -> Brew? {
        if let pinned = bean.pinnedBrew { return pinned }
        // fallback to latest brew by creationDate
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
        if let source = Self.templateBrew(for: selectedBean) {
            applyTemplate(from: source)
        } else {
            resetToDefaults()
        }
    }

    var body: some View {
        NavigationStack {
            if let pinnedBrew = brewBean?.pinnedBrew {
                BrewCardView(brew: pinnedBrew, showPills: false)
            }
            Form {
                Section {
                    Picker("Beans", selection: $brewBean) {
                        Text("Not set").tag(nil as Bean?)
                        ForEach(beans.filter { $0.inStock }) { bean in
                            Text(bean.name).tag(bean as Bean?)
                        }
                    }
                }
                Section {
                    Stepper(
                        value: $brewDose,
                        in: 1...50,
                    ) {
                        HStack{
                            Text("Dose")
                            Spacer()
                            NumericText(text: "\(brewDose)g", numericValue: Double(brewDose))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    Stepper(
                        value: $brewGrind,
                        in: 1...100,
                    ) {
                        HStack{
                            Text("Grind")
                            Spacer()
                            NumericText(text: "\(brewGrind)", numericValue: Double(brewGrind))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    Stepper(
                        value: $brewYield,
                        in: 1...100,
                    ) {
                        HStack{
                            Text("Yield")
                            Spacer()
                            NumericText(text: "\(brewYield)g", numericValue: Double(brewYield))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    Stepper(
                        value: $brewTime,
                        in: 1...120,
                    ) {
                        HStack{
                            Text("Time")
                            Spacer()
                            NumericText(text: "\(brewTime)s", numericValue: Double(brewTime))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .contentMargins(.top, 16)
            .listSectionSpacing(16)
            .navigationTitle(brew == nil ? "Log brew" : "Edit brew")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: brewBean) { _ in
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
                            createdBrew = newBrew
                        }
                    },
                    onDismiss: {
                        dismiss()
                        
                        // Add haptic feedback
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                    },
                    onYayPinToggle: {
                        if let brew = createdBrew {
                            brew.pinned.toggle()
                            try? context.save()
                        }
                    }
                )
            }
        }
    }
}

#Preview {
   LogBrewView()
}
