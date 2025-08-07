//
//  BrewsView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import SwiftData

struct BrewsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Brew.creationDate, order: .reverse) private var brews: [Brew]
    @State private var path = [Screen]()
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(brews) { brew in
                    BrewRowView(brew: brew, onDelete: {
                        context.delete(brew)
                    }, onEdit: {
                        editingBrew = brew
                    })
                    .onTapGesture {
                        path.append(.brewDetail(brew: brew))
                    }
                }
            }
            .animation(.default, value: brews.count)
            .background(Color(.secondarySystemBackground))
            .overlay {
                if(brews.isEmpty){
                    ContentUnavailableView(
                        label: {
                            Label("No brews", systemImage: "cup.and.saucer.fill")
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
                    .background(Color(.secondarySystemBackground))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add brew", systemImage: "plus", action: {
                        showingLogBrew.toggle()
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }
            }
            .navigationTitle("Brews")
            .navigationDestination(for: Screen.self) { screen in
                if case let .beanDetail(bean) = screen {
                    BeanDetailView(bean: bean, path: $path)
                }
                if case let .brewDetail(brew) = screen {
                    BrewDetailView(brew: brew, path: $path)
                }
            }
        }
        .sheet(isPresented: $showingLogBrew) {
            LogBrewView()
        }
        .sheet(item: $editingBrew) { brew in
            Text("Edit Brew View")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Bean.self, Brew.self, configurations: config)
    
    // Add mock data to the container
    let mockBrews = createMockBrews()
    for brew in mockBrews {
        container.mainContext.insert(brew)
    }
    
    return BrewsView()
        .modelContainer(container)
}
