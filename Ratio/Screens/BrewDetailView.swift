//
//  BrewDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

struct BrewDetailView: View {
    var brew: Brew
    
    var body: some View {
        NavigationStack{
            VStack {
                BrewImageView(rating: brew.rating, size: .large, tertiary: true)
                VStack(spacing: 4) {
                    Text(formatRelativeDate(brew.creationDate))
                        .font(.largeTitle)
                        .bold()
                    if(brew.bean != nil) {
                        NavigationLink(destination: {
                            BeanDetailView()
                        }, label: {
                            Text(brew.bean?.name ?? "")
                                .font(.title3)
                        })
                    }
                }
            }
            List{
                HStack {
                    Text("Dose")
                    Spacer()
                    Text("/brew.dose")
                        .foregroundColor(.secondary)
                }
            }
            .background(Color(.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Pin brew", systemImage: "pin", action: {
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit brew", systemImage: "pencil", action: {
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                    .labelStyle(.iconOnly)
                }

            }
            .navigationTitle("Brew")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    if let firstBrew = createMockBrews().first {
        BrewDetailView(brew: firstBrew)
    }
}
