//
//  SettingViewModel.swift
//  VisionITSM
//
//  Created by 진아현 on 7/16/25.
//

import Foundation

@Observable
class SettingViewModel {
    var isShowSetting: Bool = false
    var counter: Int = 0
    var settingModel: SettingModel = .init(background: .nuri, audienceSize: 0, distractionLevel: 0)
}
