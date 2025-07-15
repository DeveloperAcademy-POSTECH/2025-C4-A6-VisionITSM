//
//  GridItemView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI

struct GridItemView: View {
    //MARK: - PROPERTIES
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "xmark")
                .resizable()
                .frame(height: 138)
            Text("C4 Apple Review")
                .font(.title)
            Text("Last viewed 2025.05.05")
        }
        .border(.red)
    }
}

#Preview {
    GridItemView()
}
