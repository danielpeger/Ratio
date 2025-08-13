//
//  BrewDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import Flow
import AudioToolbox

struct BrewDetailView: View {
    var brew: Brew
    @Binding var path: [Screen]
    
    @State private var navigateToBean = false
    @State private var editingBrew: Brew? = nil
    
    var body: some View {
        List{
            Section {
                VStack {
                    BrewImageView(rating: brew.rating, size: .large, brightBackground: true)
                    VStack(spacing: 4) {
                        Text(formatRelativeDate(brew.creationDate))
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        if let bean = brew.bean {
                            Text(bean.name)
                                .foregroundColor(.accent)
                                .onTapGesture {
                                    if let previousScreen = path.dropLast().last, case .beanDetail = previousScreen {
                                        path.removeLast()
                                    } else {
                                        path.append(.beanDetail(bean: bean))
                                    }
                                }
                            
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            Section {
                HStack {
                    Text("Dose")
                    Spacer()
                    Text("\(brew.dose)g")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Grind")
                    Spacer()
                    Text("\(brew.grind)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Yield")
                    Spacer()
                    Text("\(brew.yield)g")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Time")
                    Spacer()
                    Text("\(brew.time)s")
                        .foregroundColor(.secondary)
                }
            }
            Section {
                if (brew.tasteArray != []) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Taste")
                        HFlow(spacing: 8) {
                            ForEach(brew.tasteArray, id: \.self) { taste in
                                PillView(text: taste.rawValue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if (brew.tipArray != []) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tips for next brew")
                        HFlow(spacing: 8) {
                            ForEach(brew.tipArray, id: \.self) { tip in
                                PillView(text: tip.rawValue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let notes = brew.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                        if let notes = brew.notes, !notes.isEmpty {
                            Text(notes)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
        .listSectionSpacing(32)
        .toolbar {
            if let bean = brew.bean {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Pin brew", systemImage: brew.pinned ? "pin.fill" : "pin", action: {
                        if brew.pinned {
                            bean.unpinAllBrews()
                            AudioServicesPlaySystemSound(SystemSoundID(1397))
                        } else {
                            bean.pinBrew(brew)
                            AudioServicesPlaySystemSound(SystemSoundID(1396))
                        }
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit brew", systemImage: "pencil", action: {
                    editingBrew = brew
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .labelStyle(.iconOnly)
            }
        }
        .navigationTitle("Brew")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingBrew) { brew in
            LogBrewView(brew: brew)
        }
    }
}

#Preview {
    let path = [Screen]()
    if let fifthBrew = createMockBrews().dropFirst(5).first {
        BrewDetailView(brew: fifthBrew, path: .constant(path))
    }
}
