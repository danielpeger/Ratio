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
 
 // Helper function to create mock beans without brews (to avoid circular dependency)
 func createMockBeansWithoutBrews() -> [Bean] {
     return [
         Bean(name: "Ethiopian Yirgacheffe", roaster: "Blue Bottle Coffee", origin: .ethiopia, processing: .washed, inStock: true, imageColor: .yellow),
         Bean(name: "Colombian Supremo", roaster: "", origin:.dominica, processing: .notSet, inStock: true, imageColor: .green),
         Bean(name: "Brazilian Santos", processing: .natural, inStock: false, imageColor: .brown, imageData: imageDataFromPreviewAsset(named: "beanImage1")),
         Bean(name: "Guatemalan Antigua", roaster: "Long roaster name Counter Culture", origin: .guatemala, processing: .washed, inStock: true, imageColor: .orange),
         Bean(name: "Kenyan AA", inStock: true, imageColor: .red, imageData: imageDataFromPreviewAsset(named: "beanImage2")),
         Bean(name: "Costa Rican Tarrazu", roaster: "Stumptown Coffee", origin: .costarica, processing: .honey, inStock: true, imageColor: .purple, imageData: imageDataFromPreviewAsset(named: "beanImage3")),
         Bean(name: "Peruvian Organic", origin: .peru, processing: .washed, inStock: false, imageColor: .teal),
         Bean(name: "Sumatra Mandheling", roaster: "Counter Culture", origin: .indonesia, processing: .wetHulled, inStock: true, imageColor: .indigo)
     ]
 }
 
 // Helper function to create mock beans with brews for preview
 func createMockBeansWithBrews() -> [Bean] {
     let beans = createMockBeansWithoutBrews()
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
     
     // Create brews with direct references to the beans
     let brews = [
         // Recent brews with varying times
         Brew(dose: 18, grind: 60, yield: 50, time: 32, rating: .good, tastes: [.sweet, .balanced, .creamy], tips: [true, false, nil], notes: "This is a note", bean: beans[0], creationDate: createDate(year: 2025, month: 7, day: 31, hour: 8, minute: 30)),
         Brew(dose: 18, grind: 55, yield: 55, time: 38, rating: .neutral, tastes: [.thin, .balanced], tips: [true, nil, nil], notes: "This is a second note", bean: beans[1], creationDate: createDate(year: 2025, month: 7, day: 29, hour: 14, minute: 15)),
         
         // Last week with different times
         Brew(dose: 7, grind: 40, yield: 50, time: 45, rating: .bad, tastes: [.tasteless], tips: [false, nil, false], notes: "This is a note", bean: beans[2], creationDate: createDate(year: 2025, month: 1, day: 10, hour: 7, minute: 45)),
         
         // Last month with evening times
         Brew(dose: 16, grind: 50, yield: 48, time: 30, rating: .neutral, tastes: [.balanced, .thick, .creamy], tips: [nil, true, nil], notes: "Decent but could be better", bean: beans[5], creationDate: createDate(year: 2024, month: 12, day: 15, hour: 9, minute: 0)),
         
         // Last year with various times
         Brew(dose: 18, grind: 58, yield: 54, time: 33, rating: .good, tastes: [.balanced, .sweet], tips: [true, true, true], notes: "Great balance of flavors", bean: beans[6], creationDate: createDate(year: 2024, month: 7, day: 22, hour: 11, minute: 45)),
         Brew(dose: 14, grind: 42, yield: 42, time: 25, rating: .bad, tastes: [.sour, .salty], tips: [false, nil, false], notes: "Under-extracted, too fine grind", bean: beans[7], creationDate: createDate(year: 2024, month: 3, day: 5, hour: 6, minute: 15))
     ]
     
     // The relationships are already established when creating brews with bean parameter
     return beans
 }
 
 // Helper function to create mock beans for preview (maintains backward compatibility)
 func createMockBeans() -> [Bean] {
     return createMockBeansWithBrews()
 }
