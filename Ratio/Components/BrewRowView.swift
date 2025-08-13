//
//  BrewRowView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29..
//

import SwiftUI
import AudioToolbox

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
            
            HStack(spacing: 8) {
                if(brew.pinned) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accent)
                }
                // NavigationLink-style chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .contentShape(Rectangle()) // Makes the entire row tappable
        .contextMenu {
            if let bean = brew.bean {
                if(brew.pinned) {
                    Button("Unpin", systemImage: "pin.slash.fill") {
                        withAnimation {
                            bean.unpinAllBrews()
                        }
                        AudioServicesPlaySystemSound(SystemSoundID(1397))
                    }
                } else {
                    Button("Pin", systemImage: "pin") {
                        withAnimation {
                            bean.pinBrew(brew)
                        }
                        AudioServicesPlaySystemSound(SystemSoundID(1396))
                    }
                }
            }
            
            Button("Edit", systemImage: "pencil") {
                onEdit?()
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation {
                    onDelete?()
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation {
                    onDelete?()
                }
            }
            
            if let bean = brew.bean {
                if(brew.pinned) {
                    Button("Unpin", systemImage: "pin.slash.fill") {
                        withAnimation {
                            bean.unpinAllBrews()
                        }
                        AudioServicesPlaySystemSound(SystemSoundID(1397))
                    }
                    .tint(Color.red.secondary)
                } else {
                    Button("Pin", systemImage: "pin") {
                        withAnimation {
                            bean.pinBrew(brew)
                        }
                        AudioServicesPlaySystemSound(SystemSoundID(1396))
                    }
                    .tint(Color.red.secondary)
                }
            }
            
            Button("Edit", systemImage: "pencil") {
                onEdit?()
            }
            .tint(Color(.systemGray2))
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
 
