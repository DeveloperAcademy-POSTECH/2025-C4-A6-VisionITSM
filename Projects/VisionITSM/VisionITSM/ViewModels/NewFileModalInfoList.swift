//
//  NewFileModalInfoList.swift
//  VisionITSM
//
//  Created by 진아현 on 7/24/25.
//

import Foundation

@Observable
class NewFileModalInfoList {
    var homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        fetchList()
    }
    
    var newFileInfos: [NewFileModalInfo] = []
    
    func fetchList() {
        self.newFileInfos = [
            .init(title: "Upload Slide Deck (Required)", action: {self.homeViewModel.openPDFPicker()}, buttonDescription: "Upload from File (.PDF)", description: "A PDF file is required to render slide images."),
            .init(title: "Upload Slide Notes (Optional)", action: {self.homeViewModel.openPPTXPicker()}, buttonDescription: "Upload from file (.PPTX)", description: "A PPTX file is only needed if you want to import slide notes.")
        ]
    }
}
