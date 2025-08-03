//
//  BeanDetailView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 30..
//

import SwiftUI

struct BeanDetailView: View {
    var bean: Bean
    
    var body: some View {
        Text("Hello bean detail view!")
            .navigationTitle(bean.name)
    }
}

#Preview {
    if let firstBean = createMockBeans().dropFirst(2).first {
        BeanDetailView(bean: firstBean)
    }
}
