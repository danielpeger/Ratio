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
    @State var pullProgress: Double = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            PullActionScrollView(threshold: 80, onTrigger: {
                showingLogBrew.toggle()
            }, onProgress: { progress in
                pullProgress = progress
            }) {
                if brews.isEmpty {
                    VStack {
                        Spacer(minLength: 48)
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
                        Spacer(minLength: 200)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List{
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
                    .contentMargins(.top, 8)
                    .scrollDisabled(true)
                    .frame(height: CGFloat((40 + brews.count * 66)), alignment: .top)
                    .animation(.default, value:  brews.count)
                }
            }
            .animation(.default, value: brews.count)
            .background(Color(.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ZStack {
                        Button(action: {
                            showingLogBrew.toggle()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }) {
                            AddCircle(progress: $pullProgress)
                        }
                        .labelStyle(.iconOnly)
                    }
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
            LogBrewView(brew: brew)
        }
    }
}

struct AddCircle: View {
    @Binding var progress: Double
    
    var body: some View {
        let size = max(0, progress) * 32

        ZStack {
            Image(systemName: "plus")
                .foregroundStyle(.red)
                .frame(width: 32, height: 32)
            Circle()
                .fill(.red)
                .frame(width: size, height: size)
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .mask(
                    Circle()
                        .frame(width: size, height: size)
                )
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
