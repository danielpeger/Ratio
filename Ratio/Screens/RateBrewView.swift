//
//  RateBrewView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI
import Flow

struct RateBrewView: View {
    @Binding var rating: Rating
    @Binding var tastes: Set<Taste>
    @Binding var tips: [Bool?]
    @Binding var notes: String?
    @Binding var pinned: Bool

    var onSave: (() -> Void)?
    var onYayDone: (() -> Void)?
    
    @State private var navigateToYay = false
    
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
            TipsSection(tips: $tips, tipsCount: tipsCount)
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
                    if(rating == .good) {
                        navigateToYay = true
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToYay) {
            YayView(
                pinned : $pinned,
                onPinToggle: {
                    pinned.toggle()
                },
                onDone: {
                    onYayDone?()
                }
            )
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
                    TipPickerView(tip: $tips[0], trueOption: .doseMore, falseOption: .doseLess)
                    TipPickerView(tip: $tips[1], trueOption: .grindFiner, falseOption: .grindCoarser)
                    TipPickerView(tip: $tips[2], trueOption: .yieldMore, falseOption: .yieldLess)
                }
                .padding(.vertical, 8)
            }
        }
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
    
    return RateBrewView(
        rating: $previewRating,
        tastes: $previewTastes,
        tips: $previewTips,
        notes: $previewNotes,
        pinned: $previewPinned
    )
}
