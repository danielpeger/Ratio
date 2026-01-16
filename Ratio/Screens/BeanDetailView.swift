//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import SwiftData
import AudioToolbox


struct BeanDetailView: View {
    @Environment(\.modelContext) private var context
    
    var bean: Bean
    
    @Binding var path: [Screen]
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    @State private var editingBean: Bean? = nil
    @State var pullProgress: Double = 0
    
    
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
        
        PullActionScrollView(threshold: 100, onTrigger: {
            showingLogBrew = true
        }, onProgress: { progress in
            pullProgress = progress
        }, isEnabled: bean.inStock && !showingLogBrew) {
            LazyVStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData, groupedBgIcon: true)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(bean.name)
                                .font(.largeTitle)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if !details.isEmpty {
                                Text(details.joined(separator: ", "))
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 32)
                    
                    if !beanBrews.isEmpty && !bean.inStock {
                        LeftAlignedContentUnavailableView {
                            Text("Bean currently out of stock. Mark as in stock to log brews.")
                        } actions: {
                            Button("Mark as in stock") {
                                bean.inStock = true
                                AudioServicesPlaySystemSound(SystemSoundID(1570))
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .primaryActionStyle()
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if let featuredBrew = bean.pinnedBrew ?? beanBrews.first {
                        let isPinned = bean.pinnedBrew != nil
                        VStack(spacing: 0) {
                            SectionHeader(title: isPinned ? "Pinned brew" : "Last brew", systemImage: isPinned ? "pin.fill" : nil)
                            BrewCardView(brew: featuredBrew, showPills: true)
                                .padding(.horizontal, 16)
                        }
                        .onTapGesture { handleBrewTap(featuredBrew) }
                    }
                }
                
                if !beanBrews.isEmpty {
                    List{
                        Section(header: Text("Brews")) {
                            ForEach(beanBrews) { brew in
                                BrewRowView(brew: brew, showBean: false, onDelete: {
                                    context.delete(brew)
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        path.removeAll { screen in
                                            if case let .brewDetail(previousBrew) = screen {
                                                return previousBrew.id == brew.id
                                            }
                                            return false
                                        }
                                    }
                                    AudioServicesPlaySystemSound(SystemSoundID(1018))
                                }, onEdit: {
                                    editingBrew = brew
                                })
                                .onTapGesture { handleBrewTap(brew) }
                            }
                        }
                    }
                    .scrollDisabled(true)
                    .frame(height: CGFloat(40 + beanBrews.count * 66), alignment: .top)
                    .animation(.default, value:  beanBrews.count)
                } else {
                    LeftAlignedContentUnavailableView("No brews") {
                        Text(bean.inStock ? "Log a brew to get started" : "Mark as in stock to log brews")
                    } actions: {
                        if bean.inStock {
                            Button("Log brew") {
                                showingLogBrew = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .primaryActionStyle()
                        } else {
                            Button("Mark as in stock") {
                                bean.inStock = true
                                AudioServicesPlaySystemSound(SystemSoundID(1570))
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .primaryActionStyle()
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.bottom, 32)
            .sheet(isPresented: $showingLogBrew) {
                LogBrewView(initialBean: bean)
            }
            .sheet(item: $editingBrew) { brew in
                LogBrewView(brew: brew, onDelete: {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        path.removeAll { screen in
                            if case let .brewDetail(previousBrew) = screen {
                                return previousBrew.id == brew.id
                            }
                            return false
                        }
                    }
                })
            }
            .sheet(item: $editingBean) { bean in
                AddBeansView(bean: bean, onDelete: {
                    path = []
                })
            }
            .navigationTitle(bean.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit bean", systemImage: "pencil", action: {
                        editingBean = bean
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }
                if bean.inStock {
                    ToolbarItem(placement: .topBarTrailing) {
                        if #available(iOS 26.0, *) {
                            Button("Log brew", systemImage: "plus", action: {
                                showingLogBrew = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            })
                            .primaryActionStyle()
                            .tint(.red.opacity(pullProgress))
                            .scaleEffect(1.0 + pullProgress)
                            .labelStyle(.iconOnly)
                        } else {
                            Button(action: {
                                showingLogBrew = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }) {
                                AddCircle(progress: $pullProgress)
                            }
                            .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        
    }
}

private struct BeanDetailPreviewWrapper: View {
    let container: ModelContainer
    let beans: [Bean]
    let path: [Screen] = []
    
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: Bean.self, Brew.self, configurations: config)
        self.beans = createMockBeansWithoutBrews()
        for bean in beans { container.mainContext.insert(bean) }
        
        let brew1 = Brew(dose: 17, grind: 58, yield: 48, time: 30, rating: .neutral, tastes: [.balanced], tips: [nil, true, nil], notes: nil, bean: beans[1], pinned: false)
        let brew2 = Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.thin, .thick, .bitter, .creamy, .muddled, .watery, .sweet, .balanced], tips: [true, true, true], notes: "Great shot", bean: beans[1], pinned: false)
        container.mainContext.insert(brew1)
        container.mainContext.insert(brew2)
    }
    
    var body: some View {
        NavigationStack {
            BeanDetailView(bean: beans[1], path: .constant(path))
                .modelContainer(container)
        }
    }
}

#Preview {
    BeanDetailPreviewWrapper()
}
