//
//  NewFileModalInfo.swift
//  VisionITSM
//
//  Created by 진아현 on 7/24/25.
//

import Foundation

struct NewFileModalInfo: Identifiable {
    var id = UUID()
    var title: String
    var action: () -> Void
    var selectedFileName: String
    var buttonDescription: String
    var description: String
}
