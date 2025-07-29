//
//  BeansView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import SwiftData

struct BrewsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Brew.creationDate, order: .reverse) private var brews: [Brew]
    @State private var showingAddBrew = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(brews) { brew in
                    BrewRowView(brew: brew)
                }
                .onDelete(perform: deleteBrews)
            }
            .background(Color(.secondarySystemBackground))
            .overlay {
                if(brews.isEmpty){
                    ContentUnavailableView(
                        label: {
                            Label("No brews", systemImage: "cup.and.saucer.fill")
                        },
                        description: {
                            Text("Add your first brew to get started")
                        },
                        actions: {
                            Button("Add brew") {
                                showingAddBrew.toggle()
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
                        showingAddBrew.toggle()
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }
            }
            .navigationTitle("Brews")
        }
        .sheet(isPresented: $showingAddBrew) {
            // TODO: Add AddBrewView here
            Text("Add Brew View")
        }
    }
    
    private func deleteBrews(offsets: IndexSet) {
        for index in offsets {
            context.delete(brews[index])
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
