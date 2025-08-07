//
//  Bean.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import Foundation
import SwiftData
import SwiftUI

enum Origin: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case notSet = "Not set"
    case bolivia = "Bolivia"
    case brazil = "Brazil"
    case burundi = "Burundi"
    case colombia = "Colombia"
    case costarica = "Costa Rica"
    case cuba = "Cuba"
    case drc = "Democratic Republic of Congo"
    case dominica = "Dominican Republic"
    case ecuador = "Ecuador"
    case elsalvador = "El Salvador"
    case ethiopia = "Ethiopia"
    case guatemala = "Guatemala"
    case haiti = "Haiti"
    case honduras = "Honduras"
    case india = "India"
    case indonesia = "Indonesia"
    case jamaica = "Jamaica"
    case kenya = "Kenya"
    case malawi = "Malawi"
    case mexico = "Mexico"
    case myanmar = "Myanmar"
    case nepal = "Nepal"
    case nicaragua = "Nicaragua"
    case panama = "Panama"
    case png = "Papua New Guinea"
    case peru = "Peru"
    case rwanda = "Rwanda"
    case tanzania = "Tanzania"
    case thailand = "Thailand"
    case philippines = "Philippines"
    case uganda = "Uganda"
    case hawaii = "Hawaii"
    case venezuela = "Venezuela"
    case vietnam = "Vietnam"
    case yemen = "Yemen"
    case zambia = "Zambia"
}

enum Processing: String, Codable, Hashable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case notSet = "Not set"
    case anaerobic = "Anaerbic"
    case cb = "Carbonic maceration"
    case honey = "Honey"
    case natural = "Natural"
    case pulpedNatural = "Pulped natural"
    case semiWashed = "Semi washed"
    case washed = "Washed"
    case wetHulled = "Wet hulled"
}

enum ImageColor: String, Codable, Hashable, CaseIterable {
    case red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .teal: return .teal
        case .cyan: return .cyan
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        }
    }
}

@Model
final class Bean {
    var creationDate: Date
    var name: String
    var roaster: String?
    var origin: Origin?
    var processing: Processing?
    var inStock: Bool
    var imageColor: ImageColor?
    var imageData: Data?
    @Relationship(deleteRule: .cascade) var brews: [Brew]?
    
    // Computed property to get the pinned brew
    var pinnedBrew: Brew? {
        return brews?.first { $0.pinned }
    }
    
    // Method to pin a specific brew (unpins all others)
    func pinBrew(_ brew: Brew) {
        // First, unpin all existing brews
        brews?.forEach { $0.pinned = false }
        // Then pin the specified brew
        brew.pinned = true
    }
    
    // Method to unpin all brews
    func unpinAllBrews() {
        brews?.forEach { $0.pinned = false }
    }
    
    init(name: String, roaster: String? = nil, origin: Origin? = nil, processing: Processing? = nil, inStock: Bool = true, imageColor: ImageColor? = nil, imageData: Data? = nil) {
        self.creationDate = Date()
        self.name = name
        self.roaster = roaster
        self.origin = origin
        self.processing = processing
        self.inStock = inStock
        self.imageColor = imageColor
        self.imageData = imageData
    }
}
