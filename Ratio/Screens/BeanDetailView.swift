//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import SwiftData

struct BeanDetailView: View {
    @Environment(\.modelContext) private var context
    
    var bean: Bean
    
    @Binding var path: [Screen]
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    @State private var editingBean: Bean? = nil
    
    // Query brews for this specific bean to ensure automatic updates
    @Query(sort: \Brew.creationDate, order: .reverse) private var brews: [Brew]
    var beanBrews: [Brew] {
        return brews.filter { brew in
            brew.bean == bean
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Section {
                    VStack {
                        BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData)
                        VStack(spacing: 4) {
                            Text(bean.name)
                                .font(.title)
                                .bold()
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .truncationMode(.tail)
                            let detailRoaster = (bean.roaster?.isEmpty == true) ? nil : bean.roaster
                            let detailOrigin = bean.origin == .notSet ? nil : bean.origin?.rawValue
                            let detailProcessing = bean.processing == .notSet ? nil : bean.processing?.rawValue
                            let details = [detailRoaster, detailOrigin, detailProcessing].compactMap { $0 }
                            if !details.isEmpty {
                                Text(details.joined(separator: ", "))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                
                if let featuredBrew = bean.pinnedBrew ?? beanBrews.first {
                    let isPinned = bean.pinnedBrew != nil
                    
                    Section(header: isPinned ? AnyView(Label("Pinned brew", systemImage: "pin.fill")) : AnyView(Text("Last brew"))) {
                        BrewCardView(brew: featuredBrew, showPills: !isPinned)
                    }
                }
                
                if !beanBrews.isEmpty {
                    Section(header: Text("Brews")) {
                        ForEach(beanBrews) { brew in
                            BrewRowView(brew: brew, showBean: false, onDelete: {
                                context.delete(brew)
                            }, onEdit: {
                                editingBrew = brew
                            })
                            .onTapGesture {
                                if let previousScreen = path.dropLast().last, case .brewDetail(let previousBrew) = previousScreen, previousBrew.id == brew.id {
                                    path.removeLast()
                                } else {
                                    path.append(.brewDetail(brew: brew))
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        label: {
                            Text("No brews")
                                .bold()
                                .foregroundColor(Color(.secondaryLabel))
                        },
                        description: {
                            Text("Log a brew to get started")
                                .foregroundColor(Color(.tertiaryLabel))
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
            .animation(.default, value: beanBrews.count)
            .sheet(isPresented: $showingLogBrew) {
                LogBrewView(initialBean: bean)
            }
            .sheet(item: $editingBrew) { brew in
                Text("Edit Brew View")
            }
            .sheet(item: $editingBean) { bean in
                AddBeansView(bean: bean)
            }
            .navigationTitle(bean.name)
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
}

#Preview {
    let path = [Screen]()
    if let firstBean = createMockBeans().dropFirst().first {
        BeanDetailView(bean: firstBean, path: .constant(path))
    }
}
