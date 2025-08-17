//
//  CreateMockBrews.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29.
//

import Foundation
 
 // Helper function to create mock brews for preview (mix of with and without bean relationships)
 func createMockBrews() -> [Brew] {
     let mockBeans = createMockBeansWithoutBrews()
     let calendar = Calendar.current
     
     // Helper function to create a date with specific components
     func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
         var components = DateComponents()
         components.year = year
         components.month = month
         components.day = day
         components.hour = hour
         components.minute = minute
         return calendar.date(from: components) ?? Date()
     }
     
     return [
        // Recent brews with varying times - some with beans, some without
        Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.sweet, .balanced, .creamy], tips: [true, false, nil], notes: "This is a note", bean: mockBeans[0], creationDate: createDate(year: 2025, month: 7, day: 31, hour: 8, minute: 30), pinned: false),
        Brew(dose: 18, grind: 55, yield: 55, time: 38, rating: .neutral, tastes: [.thin, .balanced], tips: [true, nil, nil], notes: "This is a second note", bean: mockBeans[0], creationDate: createDate(year: 2025, month: 7, day: 29, hour: 14, minute: 15), pinned: false),
        
        // Last week with different times - some with beans, some without
        Brew(dose: 7, grind: 40, yield: 50, time: 45, rating: .bad, tastes: [.watery], tips: [false, nil, false], notes: "This is a note", bean: mockBeans[2], creationDate: createDate(year: 2025, month: 1, day: 10, hour: 7, minute: 45), pinned: false),
        Brew(dose: 15, grind: 45, yield: 45, time: 28, rating: .good, tastes: [.sweet], tips: [true, true, nil], notes: "Perfect morning brew", creationDate: createDate(year: 2025, month: 1, day: 8, hour: 16, minute: 20), pinned: false),
        
        // Last month with evening times - some with beans, some without
        Brew(dose: 20, grind: 65, yield: 40, time: 35, rating: .bad, tastes: [.bitter, .muddled], tips: [false, false, true], notes: "Too coarse grind, over-extracted", creationDate: createDate(year: 2024, month: 12, day: 20, hour: 19, minute: 30), pinned: false),
        Brew(dose: 16, grind: 50, yield: 20, time: 30, rating: .neutral, tastes: [.balanced, .thick, .creamy], tips: [nil, true, nil], notes: "Decent but could be better", bean: mockBeans[5], creationDate: createDate(year: 2024, month: 12, day: 15, hour: 9, minute: 0), pinned: false),
        
        // Last year with various times - some with beans, some without
        Brew(dose: 18, grind: 58, yield: 54, time: 33, rating: .good, tastes: [.balanced, .sweet], tips: [true, true, true], notes: "Great balance of flavors", bean: mockBeans[6], creationDate: createDate(year: 2024, month: 7, day: 22, hour: 11, minute: 45), pinned: false),
        Brew(dose: 14, grind: 42, yield: 42, time: 25, rating: .bad, tastes: [.sour, .salty], tips: [false, nil, false], notes: "Under-extracted, too fine grind", bean: mockBeans[7], creationDate: createDate(year: 2024, month: 3, day: 5, hour: 6, minute: 15), pinned: false)
     ]
 }
