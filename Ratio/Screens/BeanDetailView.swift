//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

struct BeanDetailView: View {
    @Environment(\.modelContext) private var context
    
    var bean: Bean
    
    @Binding var path: [Screen]
    
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    @State private var editingBean: Bean? = nil
    
    var body: some View {
        List {
            Section {
                VStack {
                    BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData)
                    VStack(spacing: 4) {
                        Text(bean.name)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        if let roaster = bean.roaster {
                            Text(roaster)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section {
                if let origin = bean.origin {
                    HStack {
                        Text("Origin")
                        Spacer()
                        Text(origin.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
                if let processing = bean.processing {
                    HStack {
                        Text("Processing")
                        Spacer()
                        Text(processing.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let brews = bean.brews, !brews.isEmpty {
                Section(header: Text("Brews")) {
                    ForEach(brews) { brew in
                        BrewRowView(brew: brew, showBean: false, onDelete: {
                            context.delete(brew)
                        }, onEdit: {
                            editingBrew = brew
                        })
                        .onTapGesture {
                            if let secondLast = path.dropLast().last, case .brewDetail = secondLast {
                                path.removeLast()
                            } else {
                                path.append(.beanDetail(bean: bean))
                            }
                            path.append(.brewDetail(brew: brew))
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    label: {
                        Label("No brews", systemImage: "cup.and.saucer.fill")
                    },
                    description: {
                        Text("Log a brew to get started")
                    },
                    actions: {
                        Button("Log brew") {
                            showingLogBrew.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                    }
                )
                .listRowBackground(Color.clear)
            }
        }
        .sheet(isPresented: $showingLogBrew) {
            LogBrewView(initialBean: bean)
        }
        .sheet(item: $editingBrew) { brew in
            Text("Edit Brew View")
        }
        .sheet(item: $editingBean) { bean in
            AddBeansView(bean: bean)
        }
        .navigationTitle("Bean details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit bean", systemImage: "pencil", action: {
                    editingBean = bean
                    
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .labelStyle(.iconOnly)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Log brew", systemImage: "plus", action: {
                    showingLogBrew = true
                    
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview {
    let path = [Screen]()
    if let firstBean = createMockBeans().dropFirst(2).first {
        BeanDetailView(bean: firstBean, path: .constant(path))
    }
}
