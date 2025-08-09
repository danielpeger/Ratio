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

    // Initialize the view with an optional initial bean
    init(brew: Brew? = nil, initialBean: Bean? = nil) {
        self.brew = brew
        self.initialBean = initialBean
        self._brewBean = State(initialValue: initialBean)
    }

    @State private var navigateToRateBrew = false

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Log brew")
            .navigationBarTitleDisplayMode(.inline)
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
                    onSave: {
                        let newBrew = Brew(dose: brewDose, grind: brewGrind, yield: brewYield, time: brewTime, rating: brewRating, tastes: brewTastes, tips: brewTips, notes: brewNotes, bean: brewBean, pinned: brewPinned)
                        context.insert(newBrew)
                        createdBrew = newBrew
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
