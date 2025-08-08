//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import SwiftData

struct SectionHeader: View {
    let title: String
    let systemImage: String?
    
    init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }
    
    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
            Spacer()
        }
        .font(.system(size: 13))
        .foregroundColor(.secondary)
        .textCase(.uppercase)
        .padding(.horizontal, 32)
        .padding(.bottom, 7)
    }
}

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

    private func handleBrewTap(_ brew: Brew) {
        if let previousScreen = path.dropLast().last, case .brewDetail(let previousBrew) = previousScreen, previousBrew.id == brew.id {
            path.removeLast()
        } else {
            path.append(.brewDetail(brew: brew))
        }
    }
    
    var body: some View {
        let detailRoaster = (bean.roaster?.isEmpty == true) ? nil : bean.roaster
        let detailOrigin = bean.origin == .notSet ? nil : bean.origin?.rawValue
        let detailProcessing = bean.processing == .notSet ? nil : bean.processing?.rawValue
        let details = [detailRoaster, detailOrigin, detailProcessing].compactMap { $0 }
        
        ScrollView {
            LazyVStack(spacing: 32) {
                VStack {
                    BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData)
                    VStack(spacing: 4) {
                        Text(bean.name)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .truncationMode(.tail)

                        if !details.isEmpty {
                            Text(details.joined(separator: ", "))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        }
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 16)
                
                if let featuredBrew = bean.pinnedBrew ?? beanBrews.first {
                    let isPinned = bean.pinnedBrew != nil
                    VStack(spacing: 0) {
                        SectionHeader(isPinned ? "Pinned brew" : "Last brew", systemImage: isPinned ? "pin.fill" : nil)
                        VStack(spacing: 0) {
                            BrewCardView(brew: featuredBrew, showPills: !isPinned)
                                .padding(16)
                        }
                        .background(Color(.secondarySystemGroupedBackground)) // ensure white on light mode to match design
                        .cornerRadius(9)
                        .padding(.horizontal, 16)
                    }
                }
                
                if !beanBrews.isEmpty {
                    VStack(spacing: 0) {
                        SectionHeader("Brews")
                        VStack(spacing: 0) {
                            ForEach(beanBrews) { brew in
                                BrewRowView(brew: brew, showBean: false, onDelete: {
                                    context.delete(brew)
                                }, onEdit: {
                                    editingBrew = brew
                                })
                                .onTapGesture { handleBrewTap(brew) }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.clear)
                                
                                if brew != beanBrews.last {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground)) // grouped list card background
                        .cornerRadius(9)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
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
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    let path = [Screen]()
    if let firstBean = createMockBeans().dropFirst().first {
        BeanDetailView(bean: firstBean, path: .constant(path))
    }
}
