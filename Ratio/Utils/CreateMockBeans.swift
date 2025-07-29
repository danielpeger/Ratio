//
//  CreateMockBeans.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 13.
//

 import UIKit
 
 func imageDataFromPreviewAsset(named name: String) -> Data? {
     guard let image = UIImage(named: name, in: .main, compatibleWith: nil) else { return nil }
     return image.jpegData(compressionQuality: 0.9)
 }
 
 // Helper function to create mock beans for preview
 func createMockBeans() -> [Bean] {
     return [
         Bean(name: "Ethiopian Yirgacheffe", roaster: "Blue Bottle Coffee", origin: .ethiopia, processing: .washed, inStock: true, imageColor: .yellow),
         Bean(name: "Colombian Supremo", roaster: "Stumptown Coffee", origin: .colombia, processing: .natural, inStock: true, imageColor: .green),
         Bean(name: "Brazilian Santos", roaster: "Intelligentsia", origin: .brazil, processing: .natural, inStock: false, imageColor: .brown, imageData: imageDataFromPreviewAsset(named: "beanImage1")),
         Bean(name: "Guatemalan Antigua", roaster: "Long roaster name Counter Culture", origin: .guatemala, processing: .washed, inStock: true, imageColor: .orange),
         Bean(name: "Kenyan AA", roaster: "Blue Bottle Coffee", origin: .kenya, processing: .washed, inStock: true, imageColor: .red, imageData: imageDataFromPreviewAsset(named: "beanImage2")),
         Bean(name: "Costa Rican Tarrazu", roaster: "Stumptown Coffee", origin: .costarica, processing: .honey, inStock: true, imageColor: .purple, imageData: imageDataFromPreviewAsset(named: "beanImage3")),
         Bean(name: "Peruvian Organic", origin: .peru, processing: .washed, inStock: false, imageColor: .teal),
         Bean(name: "Sumatra Mandheling", roaster: "Counter Culture", origin: .indonesia, processing: .wetHulled, inStock: true, imageColor: .indigo)
     ]
 }
