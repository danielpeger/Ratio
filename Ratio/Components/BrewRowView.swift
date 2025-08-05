//
//  BrewRowView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29..
//

import SwiftUI

struct BrewRowView: View {
    let brew: Brew
    var showBean: Bool = true
    var onDelete: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading){
                    Text(formatRelativeDate(brew.creationDate))
                    if(showBean && brew.bean != nil) {
                        Text(brew.bean?.name ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            } icon: {
                BrewImageView(rating: brew.rating)
            }
            
            Spacer()
            
            // NavigationLink-style chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .contentShape(Rectangle()) // Makes the entire row tappable
        .contextMenu {
            Button("Edit") {
                onEdit?()
            }
            
            Button("Delete", role: .destructive) {
                onDelete?()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            
            Button("Edit") {
                onEdit?()
            }
            .tint(.blue)
        }
    }
}

#Preview {
    List{
        ForEach(createMockBrews(), id: \.creationDate) { brew in
            BrewRowView(brew: brew)
        }
    }
}
 
