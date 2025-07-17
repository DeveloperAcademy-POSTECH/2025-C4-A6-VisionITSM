//
//  GridItemView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI

struct GridItemView: View {
    //MARK: - PROPERTIES
    var title: String
    var date: String
    var image: UIImage?
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let slideImage = image {
                Image(uiImage: slideImage)
                    .resizable()
                    .frame(height: 138)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(height: 138)
            }
            Text(title)
                .lineLimit(1)
                .font(.title)
            Text(date)
        }
    }
}

#Preview {
    GridItemView(title: "AAA", date: "VVV", image: UIImage(systemName: "xmark")!)
}
