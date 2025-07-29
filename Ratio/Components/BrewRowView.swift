//
//  BrewRowView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29..
//

import SwiftUI

struct BrewRowView: View {
    let brew: Brew

    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today at \(formatTime(date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at \(formatTime(date))"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return "\(formatter.string(from: date)) at \(formatTime(date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: date)) at \(formatTime(date))"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Label {
            VStack{
                Text(formatRelativeDate(brew.creationDate))
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
    let brew = Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.sweet, .balanced, .creamy], tips: [true, false, nil], notes: "This is a note")
    List{
        BrewRowView(brew: brew)
        BrewRowView(brew: brew)
    }
}
 
