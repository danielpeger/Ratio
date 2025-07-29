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
    
    case tasteless = "tasteless"
    case thin = "thin"
    case harsh = "harsh"
    case sour = "sour"
    case salty = "salty"
    case balanced = "balanced"
    case sweet = "sweet"
    case creamy = "creamy"
    case thick = "thick"
    case bitter = "bitter"
    case burnt = "burnt"
}

enum Rating: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case bad = "🙁"
    case neutral = "😐"
    case good = "🙂"
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
    
    init(bean: Bean? = nil, dose: Int, grind: Int, yield: Int, time: Int, rating: Rating = .neutral, tastes: Set<Taste> = [], tips: [Bool?] = [nil, nil, nil], notes: String? = nil) {
        self.creationDate = Date()
        self.bean = bean
        self.dose = dose
        self.grind = grind
        self.yield = yield
        self.time = time
        self.rating = rating
        self.tastes = tastes
        self.tips = tips
        self.notes = notes
    }
}
