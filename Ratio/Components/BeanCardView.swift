//
//  BeanCardView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI

struct BeanCardView: View {
    var bean: Bean
    var onToggleStock: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    
    var name: String { bean.name }
    var roaster: String? { bean.roaster }
    var beanImageColor: ImageColor? { bean.imageColor }
    var beanImageData: Data? { bean.imageData }
    var inStock: Bool { bean.inStock }
    
    var brewCount: Int {
        return bean.brews?.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack(alignment: .top, spacing: 0){
                BeanImageView(color: beanImageColor, imageData: beanImageData)
                Spacer()
                HStack(spacing:4) {
                    if(brewCount > 0) {
                        Text("\(brewCount)")
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .frame(height: 22)
                }
                .padding([.top, .trailing], 4)
            }
            .padding([.top, .leading, .trailing], 12)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
                if let roaster = roaster, !roaster.isEmpty {
                    Text(roaster)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text(" ")
                        .font(.subheadline)
                        .opacity(0)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding([.leading, .trailing, .bottom], 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(9)
        .contextMenu {
            Button(inStock ? "Out of stock" : "In stock", systemImage: inStock ? "arrow.right" : "arrow.left") {
                onToggleStock?()
            }
            Button("Edit", systemImage: "pencil") {
                onEdit?()
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                onDelete?()
            }
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        let bean = Bean(name: "Test bean", roaster: "Test roaster", inStock: true, imageColor: .blue)
        BeanCardView(bean: bean)
            .padding(16)
    }
}
