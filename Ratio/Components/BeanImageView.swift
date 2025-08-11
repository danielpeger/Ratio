//
//  BeanImageView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 07. 11..
//

import SwiftUI

struct BeanImageView: View {
    var color: ImageColor?
    var large: Bool = false
    var imageData: Data? = nil
    var scanning: Bool?
    
    var body: some View {
        ZStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                    .clipShape(RoundedRectangle(cornerRadius: large ? 30 : 11))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: large ? 30 : 11)
                        .fill((color ?? .red).color.gradient)
                        .frame(width: large ? 120 : 44, height: large ? 120 : 44)
                    Image("beanbag")
                        .foregroundColor(Color(.tertiarySystemBackground))
                        .font(.system(size: large ? 65 : 24))
                }
            }
            if scanning == true {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
               }
        }

    }
}

#Preview {
    BeanImageView()
}
