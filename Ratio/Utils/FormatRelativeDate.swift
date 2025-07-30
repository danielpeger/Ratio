//
//  FormatRelativeDate.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30.
//

import Foundation

func formatRelativeDate(_ date: Date) -> String {
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

func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
