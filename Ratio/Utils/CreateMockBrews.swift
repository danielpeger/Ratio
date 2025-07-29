//
//  CreateMockBrews.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 29.
//
 
 // Helper function to create mock brews for preview
 func createMockBrews() -> [Brew] {
     return [
        Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.sweet, .balanced, .creamy], tips: [true, false, nil], notes: "This is a note"),
        Brew(dose: 18, grind: 55, yield: 55, time: 38, rating: .neutral, tastes: [.thin, .balanced], tips: [true, nil, nil], notes: "This is a second note"),
     ]
 }
