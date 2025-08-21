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
    
    private var ratioValue: Double { Double(brew.yield) / Double(brew.dose) }
    private var ratioRounded1: Double { (ratioValue * 10).rounded() / 10 }
    private var ratioText: String {
        let isWhole = ratioRounded1.truncatingRemainder(dividingBy: 1) == 0
        if isWhole {
            return "1:\(Int(ratioRounded1))"
        } else {
            return String(format: "1:%.1f", ratioRounded1)
        }
    }
    private var ratioProgress: Double { min(max(ratioValue, 1) - 1, 4) / 3 }

    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 20) {
                BrewImageView(rating: brew.rating, size: .large, brightBackground: true)
                VStack(alignment: .leading, spacing: 8) {
                    Text(formatRelativeDate(brew.creationDate))
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let bean = brew.bean {
                        Text(bean.name)
                            .font(.title3)
                            .foregroundStyle(.accent)
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
            .padding(.top, 40)
            .padding(.horizontal, 32)
            
            LazyVStack(spacing: 32){
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Dose")
                            Spacer()
                            NumericText(text: "\(brew.dose)g", numericValue: Double(brew.dose))
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 16)
                        }
                        Divider()
                        HStack {
                            Text("Grind")
                            Spacer()
                            NumericText(text: "\(brew.grind)", numericValue: Double(brew.grind))
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 16)
                        }
                        Divider()
                        HStack {
                            Text("Yield")
                            Spacer()
                            NumericText(text: "\(brew.yield)g", numericValue: Double(brew.yield))
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 16)
                        }
                        Divider()
                        HStack {
                            Text("Time")
                            Spacer()
                            NumericText(text: "\(brew.time)s", numericValue: Double(brew.time))
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 16)
                        }
                        Divider()
                        HStack {
                            Text("Ratio")
                            Spacer()
                            HStack (spacing: 4) {
                                NumericText(text: ratioText, numericValue: ratioValue)
                                    .foregroundStyle(.secondary)
                                ZStack {
                                    Image("ratio.progress.background")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.secondary)
                                        .offset(x: 0.25, y: -0.25)
                                    Circle()
                                        .trim(from: 0, to: ratioProgress)
                                        .rotation(Angle(degrees: 270))
                                        .stroke(Color("SecondaryOpaque"), lineWidth: 5.5)
                                        .frame(width: 15.5, height: 15.5)
                                        .scaleEffect(x: -1, y: 1)
                                }
                                .padding(.trailing, -4)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .padding(.top, 32)
                .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
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
                        Divider()
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
                        Divider()
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
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            if let bean = brew.bean {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Pin brew", systemImage: brew.pinned ? "pin.fill" : "pin", action: {
                        if brew.pinned {
                            bean.unpinAllBrews()
                            AudioServicesPlaySystemSound(SystemSoundID(1374))
                        } else {
                            bean.pinBrew(brew)
                            AudioServicesPlaySystemSound(SystemSoundID(1373))
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
            LogBrewView(brew: brew, onDelete: {
                path.removeLast()
            })
        }
    }
}

#Preview {
    let path = [Screen]()
    if let fifthBrew = createMockBrews().dropFirst(1).first {
        BrewDetailView(brew: fifthBrew, path: .constant(path))
    }
}
