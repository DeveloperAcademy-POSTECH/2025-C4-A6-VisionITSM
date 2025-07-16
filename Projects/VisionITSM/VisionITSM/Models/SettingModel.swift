//
//  SettingModel.swift
//  VisionITSM
//
//  Created by 진아현 on 7/16/25.
//

import Foundation

struct SettingModel {
    var background: Background
    var audienceSize: Float
    var distractionLevel: Float
    
    enum Background: CaseIterable {
        case nuri
        
        var title: String {
            switch self {
            case .nuri:
                return "Nuri"
            }
        }
    }
}
