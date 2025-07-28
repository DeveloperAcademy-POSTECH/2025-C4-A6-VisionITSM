//
//  HomeViewModel.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI

@Observable
class HomeViewModel {
    var selectedPPTXURL: URL?
    var selectedPDFURL: URL?
    var showingFilePicker = false
    var showingParsing = false
    var keynoteTitle = ""
    var showPDFPicker = false
    var showPPTXPicker = false
    var currentKeynote: HomeModel?
    
    var parser = HybridPPTXParser()
    
    var currentIndex: Int = 0
    
    init() {
        fetchList()
    }
    
    func resetSelect() {
        currentKeynote = nil
        selectedPDFURL = nil
        selectedPPTXURL = nil
    }
    
    func openPicker() {
        showingFilePicker = true
        selectedPDFURL = nil
        selectedPPTXURL = nil
    }
    
    func openPDFPicker() {
        self.showingFilePicker = false
        self.showPDFPicker = true
    }
    
    func openPPTXPicker() {
        self.showingFilePicker = false
        self.showPPTXPicker = true
    }
    
    var newFileInfos: [NewFileModalInfo] = []
    
    func fetchList() {
        self.newFileInfos = [
            .init(title: "Upload Slide Deck (Required)", action: {self.openPDFPicker()}, selectedFileName: "\(selectedPDFURL?.lastPathComponent ?? "")", buttonDescription: "Upload from File (.PDF)", description: "A PDF file is required to render slide images."),
            .init(title: "Upload Slide Notes (Optional)", action: {self.openPPTXPicker()}, selectedFileName: "fdsfdbv", buttonDescription: "Upload from file (.PPTX)", description: "A PPTX file is only needed if you want to import slide notes.")
        ]
    }
    
}
