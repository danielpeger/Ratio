//
//  CreateMockBrews.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29.
//
 
 // Helper function to create mock brews for preview
 func createMockBrews() -> [Brew] {
     let mockBeans = createMockBeans()
     
     return [
        Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.sweet, .balanced, .creamy], tips: [true, false, nil], notes: "This is a note", bean: mockBeans[0]),
        Brew(dose: 18, grind: 55, yield: 55, time: 38, rating: .neutral, tastes: [.thin, .balanced], tips: [true, nil, nil], notes: "This is a second note", bean: mockBeans[1]),
        Brew(dose: 7, grind: 40, yield: 50, time: 45, rating: .bad, tastes: [.tasteless], tips: [false, nil, false], notes: "This is a note", bean: mockBeans[2]),
        Brew(dose: 15, grind: 45, yield: 45, time: 28, rating: .good, tastes: [.sweet, .harsh], tips: [true, true, nil], notes: "Perfect morning brew"),
        Brew(dose: 20, grind: 65, yield: 60, time: 35, rating: .bad, tastes: [.bitter, .burnt], tips: [false, false, true], notes: "Too coarse grind, over-extracted"),
        Brew(dose: 16, grind: 50, yield: 48, time: 30, rating: .neutral, tastes: [.balanced, .thick, .creamy], tips: [nil, true, nil], notes: "Decent but could be better", bean: mockBeans[5]),
        Brew(dose: 18, grind: 58, yield: 54, time: 33, rating: .good, tastes: [.balanced, .sweet], tips: [true, true, true], notes: "Great balance of flavors", bean: mockBeans[6]),
        Brew(dose: 14, grind: 42, yield: 42, time: 25, rating: .bad, tastes: [.sour, .salty], tips: [false, nil, false], notes: "Under-extracted, too fine grind", bean: mockBeans[7])
     ]
 }
