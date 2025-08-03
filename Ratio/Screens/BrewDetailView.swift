//
//  BrewDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import Flow

struct BrewDetailView: View {
    var brew: Brew
    @Binding var path: [Screen]
    
    @State private var navigateToBean = false
    
    var body: some View {
        List{
            Section {
                VStack {
                    BrewImageView(rating: brew.rating, size: .large, brightBackground: true)
                    VStack(spacing: 4) {
                        Text(formatRelativeDate(brew.creationDate))
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        if let bean = brew.bean {
                            Text(bean.name)
                                .font(.title3)
                                .foregroundColor(.accent)
                                .onTapGesture {
                                    if let secondLast = path.dropLast().last, case .beanDetail = secondLast {
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
        .navigationDestination(for: Screen.self) { screen in
            if case let .beanDetail(bean) = screen {
                BeanDetailView(bean: bean, path: $path)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Pin brew", systemImage: "pin", action: {
                    
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit brew", systemImage: "pencil", action: {
                    
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .labelStyle(.iconOnly)
            }
        }
        .navigationTitle("Brew details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let path = [Screen]()
    if let fifthBrew = createMockBrews().dropFirst(5).first {
        BrewDetailView(brew: fifthBrew, path: .constant(path))
    }
}
