//
//  ContentView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 10..
//

import SwiftUI

enum Screen: Hashable {
    case beans
    case brews
    case beanDetail(bean: Bean)
    case brewDetail(brew: Brew)
    case addBeans
    case changeImage
    case logBrew
    case rateBrew
}

struct ContentView: View {
    
    var body: some View {
        TabView {
            BeansView()
                .tabItem {
                    Image("beanbag")
                    Text("Beans")
                }
            BrewsView()
                .tabItem {
                    Image(systemName: "cup.and.saucer")
                    Text("Brews")
                }
        }
    }
}

#Preview {
    ContentView()
}
