//
//  BrewRowView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29..
//

import SwiftUI

struct BrewRowView: View {
    let brew: Brew
    
    var body: some View {
        Label {
            VStack(alignment: .leading){
                Text(formatRelativeDate(brew.creationDate))
                if(brew.bean != nil) {
                    Text(brew.bean?.name ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        } icon: {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 44, height: 44)
                Text(brew.rating.rawValue)
                    .font(.system(size: 24))
            }
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
 
