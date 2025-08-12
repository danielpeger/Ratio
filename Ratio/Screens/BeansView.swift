//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import SwiftData

struct BeansView: View {
    @State private var path = [Screen]()
    @State private var showingAddBeans = false
    @State private var editingBean: Bean? = nil
    @State private var searchText = ""
    @State private var selectedFilter: StockFilter = .inStock
    @State var pullProgress: Double = 0
    // Detect if user is searching (keyboard is visible) to disable pull to add
    @State private var isKeyboardVisible: Bool = false
    @Environment(\.modelContext) private var context
    @Query(sort: \Bean.creationDate, order: .reverse) private var beans: [Bean]
    
    var filteredBeans: [Bean] {
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
                }, isEnabled: { !isKeyboardVisible && searchText.isEmpty }) {
                    VStack {
                        Picker("Stock Filter", selection: $selectedFilter) {
                            ForEach(StockFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        if(!filteredBeans.isEmpty){
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredBeans) { bean in
                                    BeanCardView(bean: bean, onToggleStock: {
                                        bean.inStock.toggle()
                                    }, onDelete: {
                                        context.delete(bean)
                                    }, onEdit: {
                                        editingBean = bean
                                    })
                                    .animation(.default, value: filteredBeans.count)
                                    .onTapGesture {
                                        path.append(.beanDetail(bean: bean))
                                    }
                                }
                            }
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
                                            showingAddBeans.toggle()
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .bold()
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity, minHeight: proxy.size.height - 160)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddBeans.toggle()
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
        }
        .sheet(isPresented: $showingAddBeans, content: {
            AddBeansView()
        })
        .sheet(item: $editingBean) { bean in
            AddBeansView(bean: bean)
        }
        .onChange(of: showingAddBeans) { _, newValue in
            if newValue == false {
                pullProgress = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
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
