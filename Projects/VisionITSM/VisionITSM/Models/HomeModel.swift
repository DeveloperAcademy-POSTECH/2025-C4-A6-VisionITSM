//
//  HomeModel.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import Foundation
import SwiftData

@Model
class HomeModel {
    @Attribute(.unique) var title: String
    var keynote: [SlideData]
    var createAt: Date
    
    init(title: String, keynote: [SlideData], createAt: Date = .now) {
        self.title = title
        self.keynote = keynote
        self.createAt = createAt
    }
}
