//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI
import SwiftData
import AudioToolbox

struct CustomLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

struct SectionHeader: View {
    let title: String
    var systemImage: String? = nil
    
    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Label(title, systemImage: systemImage)
                    .labelStyle(CustomLabel(spacing: 4))
                    .foregroundColor(.accent)
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
    
        GeometryReader { proxy in
            PullActionScrollView(threshold: 100, onTrigger: {
                showingLogBrew = true
            }, onProgress: { progress in
                pullProgress = progress
            }, isEnabled: bean.inStock && !showingLogBrew) {
                LazyVStack(spacing: 16) {
                    VStack(spacing: 32) {
                        VStack {
                            BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData)
                            VStack(spacing: 4) {
                                Text(bean.name)
                                    .font(.largeTitle)
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
                        
                        if !beanBrews.isEmpty && !bean.inStock {
                            ContentUnavailableView(
                                label: {
                                    Text("Bean currently out of stock. Mark as in stock to log brews.")
                                        .foregroundColor(Color(.secondaryLabel))
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .padding(.bottom, 8)
                                },
                                actions: {
                                    Button("Mark as in stock") {
                                        bean.inStock = true
                                        AudioServicesPlaySystemSound(SystemSoundID(1570))
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .fontWeight(.medium)
                                }
                            )
                        }
                        
                        if let featuredBrew = bean.pinnedBrew ?? beanBrews.first {
                            let isPinned = bean.pinnedBrew != nil
                            VStack(spacing: 0) {
                                SectionHeader(title: isPinned ? "Pinned brew" : "Last brew", systemImage: isPinned ? "pin.fill" : nil)
                                VStack(spacing: 0) {
                                    BrewCardView(brew: featuredBrew, showPills: !isPinned)
                                        .padding(16)
                                }
                                .background(Color(.secondarySystemGroupedBackground)) // ensure white on light mode to match design
                                .cornerRadius(9)
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
                                        AudioServicesPlaySystemSound(SystemSoundID(1018))
                                    }, onEdit: {
                                        editingBrew = brew
                                    })
                                    .onTapGesture { handleBrewTap(brew) }
                                }
                            }
                        }
                        .scrollDisabled(true)
                        .frame(height: CGFloat((40 + beanBrews.count * 66)), alignment: .top)
                        .animation(.default, value:  beanBrews.count)
                    } else {
                        ContentUnavailableView(
                            label: {
                                Text("No brews")
                                    .bold()
                                    .foregroundColor(Color(.secondaryLabel))
                            },
                            description: {
                                Text(bean.inStock ? "Log a brew to get started" : "Mark as in stock to log brews")
                                    .foregroundColor(Color(.tertiaryLabel))
                            },
                            actions: {
                                if bean.inStock {
                                    Button("Log brew") {
                                        showingLogBrew = true
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .fontWeight(.medium)
                                } else {
                                    Button("Mark as in stock") {
                                        bean.inStock = true
                                        AudioServicesPlaySystemSound(SystemSoundID(1570))
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .fontWeight(.medium)
                                }
                            }
                        )
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 280)
                    }
                }
                .padding(.bottom, 32)
                .sheet(isPresented: $showingLogBrew) {
                    LogBrewView(initialBean: bean)
                }
                .sheet(item: $editingBrew) { brew in
                    LogBrewView(brew: brew)
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        })
                        .labelStyle(.iconOnly)
                    }
                    if bean.inStock {
                        ToolbarItem(placement: .topBarTrailing) {
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
            .background(Color(.systemGroupedBackground))
        }
        
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
        
        let brew1 = Brew(dose: 17, grind: 58, yield: 48, time: 30, rating: .neutral, tastes: [.balanced], tips: [nil, true, nil], notes: nil, bean: beans[2], pinned: false)
        let brew2 = Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.thin, .thick, .bitter, .creamy, .harsh, .burnt, .tasteless, .sweet, .balanced], tips: [true, true, true], notes: "Great shot", bean: beans[2], pinned: false)
        container.mainContext.insert(brew1)
        container.mainContext.insert(brew2)
    }
    
    var body: some View {
        NavigationStack {
            BeanDetailView(bean: beans[2], path: .constant(path))
                .modelContainer(container)
        }
    }
}

#Preview {
    BeanDetailPreviewWrapper()
}
