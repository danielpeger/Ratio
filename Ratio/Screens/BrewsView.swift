//
//  BrewsView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI
import SwiftData
import AudioToolbox

struct BrewsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Brew.creationDate, order: .reverse) private var brews: [Brew]
    @State private var path = [Screen]()
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    @State var pullProgress: Double = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                PullActionScrollView(threshold: 100, onTrigger: {
                    showingLogBrew = true
                }, onProgress: { progress in
                    pullProgress = progress
                }, isEnabled: !showingLogBrew, rebuildKey: brews.isEmpty ? "empty" : "list") {
                    if brews.isEmpty {
                        VStack {
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
                                        showingLogBrew = true
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    .primaryActionStyle()
                                    .fontWeight(.medium)
                                }
                            )
                        }
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height - 60)
                        .background(Color(.systemGroupedBackground))
                    } else {
                        List{
                            ForEach(brews) { brew in
                                BrewRowView(brew: brew, onDelete: {
                                    context.delete(brew)
                                    AudioServicesPlaySystemSound(SystemSoundID(1018))
                                }, onEdit: {
                                    editingBrew = brew
                                })
                                .onTapGesture {
                                    path.append(.brewDetail(brew: brew))
                                }
                            }
                        }
                        .contentMargins(.top, 8)
                        .contentMargins(.bottom, 32)
                        .scrollDisabled(true)
                        .frame(height: CGFloat(brews.count * 66 + 40), alignment: .top)
                        .animation(.default, value:  brews.count)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
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
            .navigationTitle("Brews")
            .navigationBarTitleDisplayMode(.large)
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
