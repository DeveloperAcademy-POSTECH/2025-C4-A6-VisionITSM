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
    
    var currentKeynote: HomeModel?
    
    var currentIndex: Int = 0 
    
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
}
