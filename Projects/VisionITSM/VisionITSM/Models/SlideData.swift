//
//  SlideData.swift
//  VisionITSM
//
//  Created by 선애 on 7/12/25.
//

import SwiftUI
import ZIPFoundation
import PDFKit

struct SlideData: Identifiable, Codable, Hashable {
    let id: UUID
    let slideNumber: Int
    let slideImageData: Data
    let presenterNotes: String?
    
    var slideImage: UIImage? {
        return UIImage(data: slideImageData)
    }
    
    init(slideNumber: Int, slideImageData: Data, presenterNotes: String?) {
        self.id = UUID()
        self.slideNumber = slideNumber
        self.slideImageData = slideImageData
        self.presenterNotes = presenterNotes
    }
}
