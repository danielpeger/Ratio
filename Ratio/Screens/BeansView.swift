//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10.
//

import SwiftUI
import SwiftData
import AudioToolbox

struct BeansView: View {
    @State private var path = [Screen]()
    @State private var showingAddBeans = false
    @State private var editingBean: Bean? = nil
    @State private var searchText = ""
    @State private var selectedFilter: StockFilter = .inStock
    @State var pullProgress: Double = 0
    @State private var filteredBeansCache: [Bean] = []
    @State private var beanPendingDeletion: Bean? = nil
    @State private var showDeleteAlert: Bool = false
    @Environment(\.modelContext) private var context
    @Query(sort: \Bean.creationDate, order: .reverse) private var beans: [Bean]
    
    private func computeFilteredBeans() -> [Bean] {
        let stockFiltered = beans.filter { bean in
            selectedFilter == .inStock ? bean.inStock : !bean.inStock
        }
        if searchText.isEmpty {
            return stockFiltered
        } else {
            return stockFiltered.filter { bean in
                bean.name.localizedCaseInsensitiveContains(searchText) ||
                (bean.roaster?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    enum StockFilter: String, CaseIterable, Identifiable {
        case inStock = "In stock"
        case outOfStock = "Out of stock"
        var id: Self { self }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                PullActionScrollView(threshold: 100, onTrigger: {
                    showingAddBeans = true
                }, onProgress: { progress in
                    pullProgress = progress
                }, isEnabled: !showingAddBeans) {
                    VStack {
                        Picker("Stock Filter", selection: $selectedFilter) {
                            ForEach(StockFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        if(!filteredBeansCache.isEmpty){
                            BeansGridView(
                                beans: filteredBeansCache,
                                onToggleStock: { bean in
                                    bean.inStock.toggle()
                                    AudioServicesPlaySystemSound(SystemSoundID(1018))
                                    filteredBeansCache = computeFilteredBeans()
                                },
                                onDelete: { bean in
                                    if let brews = bean.brews, !brews.isEmpty {
                                        beanPendingDeletion = bean
                                        showDeleteAlert = true
                                    } else {
                                        context.delete(bean)
                                        AudioServicesPlaySystemSound(SystemSoundID(1018))
                                        filteredBeansCache = computeFilteredBeans()
                                    }
                                },
                                onEdit: { bean in
                                    editingBean = bean
                                },
                                onTap: { bean in
                                    path.append(.beanDetail(bean: bean))
                                }
                            )
                            .padding([.horizontal, .bottom], 16)
                        } else {
                            ContentUnavailableView(
                                label: {
                                    if beans.isEmpty {
                                        Label("No beans", image: "beanbag")
                                            .foregroundColor(Color(.secondaryLabel))
                                    } else if (searchText.isEmpty && selectedFilter == .inStock) {
                                        Label("All beans are out of stock", systemImage: "arrow.right")
                                            .foregroundColor(Color(.secondaryLabel))
                                    } else if (searchText.isEmpty && selectedFilter == .outOfStock) {
                                        Label("All beans are in stock", systemImage: "arrow.left")
                                            .foregroundColor(Color(.secondaryLabel))
                                    } else {
                                        Label("No results", systemImage: "magnifyingglass")
                                    }
                                },
                                description: {
                                    if beans.isEmpty {
                                        Text("Add beans to get started")
                                            .foregroundColor(Color(.tertiaryLabel))
                                    } else if !searchText.isEmpty {
                                        Text("No beans found matching \"\(searchText)\"")
                                    }
                                },
                                actions: {
                                    if beans.isEmpty {
                                        Button("Add beans") {
                                            showingAddBeans = true
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .fontWeight(.medium)
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity, minHeight: proxy.size.height - 160)
                        }
                    }
                }
                .onAppear { filteredBeansCache = computeFilteredBeans() }
                .onChange(of: beans.count) { _, _ in filteredBeansCache = computeFilteredBeans() }
                .onChange(of: beans.map(\.inStock)) { _, _ in filteredBeansCache = computeFilteredBeans() }
                .onChange(of: selectedFilter) { _, _ in filteredBeansCache = computeFilteredBeans() }
                .onChange(of: searchText) { _, _ in filteredBeansCache = computeFilteredBeans() }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddBeans = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        AddCircle(progress: $pullProgress)
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .navigationTitle("Beans")
            .navigationDestination(for: Screen.self) { screen in
                if case let .beanDetail(bean) = screen {
                    BeanDetailView(bean: bean, path: $path)
                }
                if case let .brewDetail(brew) = screen {
                    BrewDetailView(brew: brew, path: $path)
                }
            }
            .searchable(text: $searchText)
            .alert("Delete bean?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let beanToDelete = beanPendingDeletion {
                        context.delete(beanToDelete)
                        AudioServicesPlaySystemSound(SystemSoundID(1018))
                        filteredBeansCache = computeFilteredBeans()
                    }
                    beanPendingDeletion = nil
                }
            } message: {
                Text("Deleting this bean will also delete all of its brews.")
            }
        }
        .sheet(isPresented: $showingAddBeans, content: {
            AddBeansView()
        })
        .sheet(item: $editingBean) { bean in
            AddBeansView(bean: bean)
        }
    }
}

private struct BeansGridView: View, Equatable {
    var beans: [Bean]
    var onToggleStock: (Bean) -> Void
    var onDelete: (Bean) -> Void
    var onEdit: (Bean) -> Void
    var onTap: (Bean) -> Void

    static func == (lhs: BeansGridView, rhs: BeansGridView) -> Bool {
        let lhsIds = lhs.beans.map { $0.id }
        let rhsIds = rhs.beans.map { $0.id }
        return lhsIds == rhsIds
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(beans) { bean in
                BeanCardView(
                    bean: bean,
                    onToggleStock: { onToggleStock(bean) },
                    onDelete: { onDelete(bean) },
                    onEdit: { onEdit(bean) }
                )
                .animation(.default, value: beans.count)
                .onTapGesture { onTap(bean) }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Bean.self, configurations: config)
    
    // Add mock data to the container
    let mockBeans = createMockBeans()
    for bean in mockBeans {
        container.mainContext.insert(bean)
    }
    
    return BeansView()
        .modelContainer(container)
}
