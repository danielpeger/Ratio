//
//  RateBrewView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI
import Flow
import AudioToolbox

struct RateBrewView: View {
    @Binding var rating: Rating
    @Binding var tastes: Set<Taste>
    @Binding var tips: [Bool?]
    @Binding var notes: String?
    @Binding var pinned: Bool
    @Binding var yayHasBeenShown: Bool

    var isPinnable: Bool
    // Edit flow controls
    var isEditing: Bool = false
    var originalRating: Rating? = nil
    var onSave: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onYayPinToggle: (() -> Void)?
    
    @State private var navigateToYay = false
    @State private var manualTipSet: [Bool] = [false, false, false]
    @State private var manualTipValue: [Bool?] = [nil, nil, nil]
    
    // Hack to animate rating text with numeric transition
    var ratingDouble: Double {
        return rating == .bad ? 1 : rating == .neutral ? 2 : 3
    }
    
    // Count non-nil tips
    var tipsCount: Int {
        return tips.compactMap { $0 }.count
    }
    
    var body: some View {
        Form {
            RatingSection(rating: $rating)
            TasteSection(tastes: $tastes)
            TipsSection(
                tips: $tips,
                tipsCount: tipsCount,
                onTipChanged: { index, newValue in
                    if newValue != nil {
                        manualTipSet[index] = true
                        manualTipValue[index] = newValue
                    } else {
                        // When cleared to nil manually, treat as not manually set so taste logic can apply again
                        manualTipSet[index] = false
                        // Last manual becomes nil for conflict/lock restoration
                        manualTipValue[index] = nil
                    }
                }
            )
            NotesSection(notes: $notes)
        }
        .contentMargins(.top, 16)
        .listSectionSpacing(16)
        .navigationTitle("Rate brew")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave?()
                    if isEditing {
                        if (originalRating != .good) && (rating == .good) {
                            navigateToYay = true
                            yayHasBeenShown = true
                        } else {
                            onDismiss?()
                        }
                    } else {
                        if rating == .good {
                            navigateToYay = true
                            yayHasBeenShown = true
                        } else {
                            onDismiss?()
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToYay) {
            YayView(
                pinned : $pinned,
                isPinnable: isPinnable,
                onPinToggle: { onYayPinToggle?() },
                onDone: {
                    onDismiss?()
                }
            )
        }
        .onChange(of: navigateToYay) { _, newValue in
            if newValue == true {
                AudioServicesPlaySystemSound(SystemSoundID(1428))
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .onChange(of: tastes) { _, _ in
            applyTasteBasedTips()
        }
        .onAppear {
            // Treat pre-filled tips as manually set to avoid overriding user choices
            for i in 0..<min(tips.count, manualTipSet.count) {
                if tips[i] != nil { manualTipSet[i] = true }
                manualTipValue[i] = tips.indices.contains(i) ? tips[i] : nil
            }
            applyTasteBasedTips()
        }
    }
}

private struct RatingSection: View {
    @Binding var rating: Rating
    private var ratingDouble: Double { rating == .bad ? 1 : rating == .neutral ? 2 : 3 }
    var body: some View {
        Section {
            VStack {
                HStack{
                    Text("Rating")
                    Spacer()
                    Text(rating == .bad ? "Bad" : rating == .neutral ? "Okay" : "Great")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: ratingDouble))
                }
                HStack{
                    ForEach(Rating.allCases, id: \.self) { option in
                        BrewImageView(rating: option, size: .medium, selected: rating == option)
                            .onTapGesture {
                                withAnimation { rating = option }
                            }
                        if option != Rating.allCases.last { Spacer() }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
            }
        }
    }
}

private struct TasteSection: View {
    @Binding var tastes: Set<Taste>
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack{
                    Text("Taste")
                    Spacer()
                    Text("\(tastes.count) selected")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(tastes.count)))
                }
                HFlow(spacing: 8) {
                    ForEach(Taste.allCases, id: \.self) { option in
                        PillView(text: option.rawValue, large: true, selected: tastes.contains(option))
                            .onTapGesture {
                                withAnimation {
                                    if tastes.contains(option) { tastes.remove(option) }
                                    else { tastes.insert(option) }
                                }
                            }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct TipsSection: View {
    @Binding var tips: [Bool?]
    let tipsCount: Int
    var onTipChanged: (_ index: Int, _ newValue: Bool?) -> Void
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Text("Tips for next brew")
                    Spacer()
                    Text("\(tipsCount) selected")
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText(value: Double(tipsCount)))
                }
                VStack(spacing: 12) {
                    TipPickerView(tip: $tips[0], trueOption: .doseMore, falseOption: .doseLess, onUserChange: { onTipChanged(0, $0) })
                    TipPickerView(tip: $tips[1], trueOption: .grindFiner, falseOption: .grindCoarser, onUserChange: { onTipChanged(1, $0) })
                    TipPickerView(tip: $tips[2], trueOption: .yieldMore, falseOption: .yieldLess, onUserChange: { onTipChanged(2, $0) })
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Taste-based tip derivation
private extension RateBrewView {
    func applyTasteBasedTips() {
        // Only apply to grind (index 1) and yield (index 2)
        let grindIndex = 1
        let yieldIndex = 2

        // Locks: do not set grind when .creamy, do not set yield when .sweet
        let lockGrind = tastes.contains(.creamy)
        let lockYield = tastes.contains(.sweet)

        // Conflicts on each axis
        let wateryOrThin = tastes.contains(.watery) || tastes.contains(.thin)
        let thickOrMuddled = tastes.contains(.thick) || tastes.contains(.muddled)
        let sour = tastes.contains(.sour)
        let bitter = tastes.contains(.bitter)
        let salty = tastes.contains(.salty)
        let grindConflict = (wateryOrThin && thickOrMuddled) || (salty && thickOrMuddled)
        let yieldConflict = (sour && bitter) || (salty && bitter)

        // Build suggestions per rules
        var grindSuggestion: Bool? = nil
        var yieldSuggestion: Bool? = nil
        if wateryOrThin { grindSuggestion = true }
        if thickOrMuddled { grindSuggestion = false }
        if sour { yieldSuggestion = true }
        if bitter { yieldSuggestion = false }
        if salty {
            grindSuggestion = true
            yieldSuggestion = true
        }

        func applyAxis(index: Int, suggested: Bool?, locked: Bool, conflict: Bool) {
            guard tips.indices.contains(index) else { return }
            if locked {
                let target = manualTipValue.indices.contains(index) ? manualTipValue[index] : nil
                if tips[index] != target {
                    withAnimation { tips[index] = target }
                }
                return
            }

            if conflict {
                // Reset to previous manual selection if exists, else nil
                let target = manualTipValue.indices.contains(index) ? manualTipValue[index] : nil
                if tips[index] != target {
                    withAnimation { tips[index] = target }
                }
                return
            }

            // If current value is nil, apply suggestion even if previously manual
            if tips[index] == nil {
                if tips[index] != suggested {
                    withAnimation { tips[index] = suggested }
                }
                return
            }

            // If not manually set, follow suggestion (including clearing to nil)
            if manualTipSet.indices.contains(index), !manualTipSet[index] {
                if tips[index] != suggested {
                    withAnimation { tips[index] = suggested }
                }
            }
            // Else: manually set and non-nil -> leave as is
        }

        applyAxis(index: grindIndex, suggested: grindSuggestion, locked: lockGrind, conflict: grindConflict)
        applyAxis(index: yieldIndex, suggested: yieldSuggestion, locked: lockYield, conflict: yieldConflict)
    }
}

private struct NotesSection: View {
    @Binding var notes: String?
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Notes")
                let notesBinding = Binding<String>(
                    get: { notes ?? "" },
                    set: { notes = $0.isEmpty ? nil : $0 }
                )
                TextEditor(text: notesBinding)
            }
        }
    }
}

#Preview {
    @Previewable @State var previewRating: Rating = .neutral
    @Previewable @State var previewTastes: Set<Taste> = []
    @Previewable @State var previewTips: [Bool?] = [nil, nil, nil]
    @Previewable @State var previewNotes: String? = "Test note"
    @Previewable @State var previewPinned: Bool = false
    @Previewable @State var previewYayHasBeenShown: Bool = false
    
    RateBrewView(
        rating: $previewRating,
        tastes: $previewTastes,
        tips: $previewTips,
        notes: $previewNotes,
        pinned: $previewPinned,
        yayHasBeenShown: $previewYayHasBeenShown,
        isPinnable: true
    )
}
