//
//  SlideView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/15/25.
//

import SwiftUI

struct SlideView: View {
    //MARK: - PROPERTIES
    @Bindable var homeViewModel: HomeViewModel
    
    //MARK: - BODY
    var body: some View {
        VStack {
            Image(uiImage: imageProcessing(keynote: homeViewModel.currentKeynote ?? .init(title: "오류", keynote: [])))
                .resizable()
                .scaledToFit()
        }
    }
    
    func imageProcessing(keynote: HomeModel) -> UIImage {
        return keynote.keynote.count == 0 ? .gridNewButton : keynote.keynote[homeViewModel.currentIndex].slideImage ?? .gridNewButton
    }
}

#Preview {
    SlideView(homeViewModel: .init())
}
