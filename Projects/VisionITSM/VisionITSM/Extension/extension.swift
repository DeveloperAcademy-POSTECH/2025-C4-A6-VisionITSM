//
//  extension.swift
//  VisionITSM
//
//  Created by 진아현 on 7/16/25.
//

import Foundation

extension Int {
    var asTimeHMS: String {
        let minutes = self / 60
        let seconds = self %  60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Date {
    func toStringFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}
