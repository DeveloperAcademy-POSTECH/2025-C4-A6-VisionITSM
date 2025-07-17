//
//  SlideView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/15/25.
//

import SwiftUI

struct SlideView: View {
    //MARK: - PROPERTIES
    
    //MARK: - BODY
    var body: some View {
        VStack {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SlideView()
}
