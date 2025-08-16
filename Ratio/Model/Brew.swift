//
//  Brew.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 28..
//

import Foundation
import SwiftData

enum Taste: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case watery = "watery"
    case thin = "thin"
    case sour = "sour"
    case salty = "salty"
    case balanced = "balanced"
    case sweet = "sweet"
    case creamy = "creamy"
    case bitter = "bitter"
    case thick = "thick"
    case muddled = "muddled"
}

enum Rating: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case bad = "👎"
    case neutral = "😐"
    case good = "❤️"
}

enum Tip: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case doseMore = "dose more"
    case doseLess = "dose less"
    case grindFiner = "grind finer"
    case grindCoarser = "grind coarser"
    case yieldMore = "yield more"
    case yieldLess = "yield less"
}

@Model
final class Brew {
    var creationDate: Date
    @Relationship(deleteRule: .nullify) var bean: Bean?
    var dose: Int
    var grind: Int
    var yield: Int
    var time: Int
    var rating: Rating
    var tastes: Set<Taste>
    var tips: [Bool?]  // Array of 3 optional booleans: [doseMore, grindFiner, yieldMore]
    var notes: String?
    var pinned: Bool = false
    
    init(dose: Int, grind: Int, yield: Int, time: Int, rating: Rating = .neutral, tastes: Set<Taste> = [], tips: [Bool?] = [nil, nil, nil], notes: String? = nil, bean: Bean? = nil, creationDate: Date = Date(), pinned: Bool) {
        self.creationDate = creationDate
        self.dose = dose
        self.grind = grind
        self.yield = yield
        self.time = time
        self.rating = rating
        self.tastes = tastes
        self.tips = tips
        self.notes = notes
        self.bean = bean
        self.pinned = pinned
    }
    
    // Computed property that returns tastes in enum order
    var tasteArray: [Taste] {
        return Taste.allCases.filter { tastes.contains($0) }
    }
    
    // Computed property that returns tips in dose-grind-yield order
    var tipArray: [Tip] {
        var result: [Tip] = []
        
        // Dose tips (first)
        if let doseMore = tips[0] {
            if doseMore {
                result.append(.doseMore)
            } else {
                result.append(.doseLess)
            }
        }
        
        // Grind tips (second)
        if let grindFiner = tips[1] {
            if grindFiner {
                result.append(.grindFiner)
            } else {
                result.append(.grindCoarser)
            }
        }
        
        // Yield tips (third)
        if let yieldMore = tips[2] {
            if yieldMore {
                result.append(.yieldMore)
            } else {
                result.append(.yieldLess)
            }
        }
        
        return result
    }
}
