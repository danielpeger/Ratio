//
//  RateBrewView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 02..
//

import SwiftUI
import Flow

struct RateBrewView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var rating: Rating
    @Binding var tastes: Set<Taste>
    @Binding var tips: [Bool?]
    @Binding var notes: String?

    var onSave: (() -> Void)?
    
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
            Section {
                VStack {
                    HStack{
                        Text("Rating")
                        Spacer()
                        Text(rating == .bad ? "Bad" : rating == .neutral ? "Neutral" : "Good")
                            .foregroundColor(.secondary)
                            .contentTransition(.numericText(value: ratingDouble))
                    }
                    HStack{
                        ForEach(Rating.allCases, id: \.self) { ratingOption in
                            BrewImageView(rating: ratingOption, size: .medium, selected: rating == ratingOption)
                                .onTapGesture(perform: {
                                    withAnimation{
                                        rating = ratingOption
                                    }
                                })
                            if ratingOption != Rating.allCases.last {
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
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
                        ForEach(Taste.allCases, id: \.self) { tasteOption in
                            PillView(text: tasteOption.rawValue, large: true, selected: tastes.contains(tasteOption))
                                .onTapGesture {
                                    withAnimation {
                                        if tastes.contains(tasteOption) {
                                            tastes.remove(tasteOption)
                                        } else {
                                            tastes.insert(tasteOption)
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
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
            
            Section {
                VStack(alignment: .leading) {
                    Text("Notes")
                    TextEditor(text: Binding(
                        get: { notes ?? "" },
                        set: { notes = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
        }
        .listSectionSpacing(16)
        .navigationTitle("Rate brew")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave?()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var previewRating: Rating = .neutral
    @Previewable @State var previewTastes: Set<Taste> = []
    @Previewable @State var previewTips: [Bool?] = [nil, nil, nil]
    @Previewable @State var previewNotes: String? = "Test note"
    
    return RateBrewView(
        rating: $previewRating,
        tastes: $previewTastes,
        tips: $previewTips,
        notes: $previewNotes
    )
}
