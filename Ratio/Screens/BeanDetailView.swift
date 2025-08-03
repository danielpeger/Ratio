//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

struct BeanDetailView: View {
    @Environment(\.modelContext) private var context
    var bean: Bean
    
    @State private var showingLogBrew = false
    @State private var editingBrew: Brew? = nil
    
    var body: some View {
        List {
            Section {
                VStack {
                    BeanImageView(color: bean.imageColor, large: true, imageData: bean.imageData)
                    VStack(spacing: 4) {
                        Text(bean.name)
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        if let roaster = bean.roaster {
                            Text(roaster)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section {
                if let origin = bean.origin {
                    HStack {
                        Text("Origin")
                        Spacer()
                        Text(origin.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
                if let processing = bean.processing {
                    HStack {
                        Text("Processing")
                        Spacer()
                        Text(processing.rawValue)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let brews = bean.brews, !brews.isEmpty {
                Section(header: Text("Brews")) {
                    ForEach(brews) { brew in
                        BrewRowView(brew: brew, showBean: false, onDelete: {
                            context.delete(brew)
                        }, onEdit: {
                            editingBrew = brew
                        })
                    }
                }
            } else {
                ContentUnavailableView(
                    label: {
                        Label("No brews", systemImage: "cup.and.saucer.fill")
                    },
                    description: {
                        Text("Log a brew to get started")
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
        .sheet(isPresented: $showingLogBrew) {
            LogBrewView()
        }
        .sheet(item: $editingBrew) { brew in
            Text("Edit Brew View")
        }
        .navigationTitle("Bean details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    if let firstBean = createMockBeans().dropFirst(2).first {
        BeanDetailView(bean: firstBean)
    }
}
