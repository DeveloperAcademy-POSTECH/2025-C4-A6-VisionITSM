//
//  Timer.swift
//  VisionITSM
//
//  Created by 진아현 on 7/16/25.
//

import SwiftUI

struct TimerView: View {
    //MARK: - PROPERTIES
    @Bindable var settingViewModel: SettingViewModel
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //MARK: - BODY
    var body: some View {
        VStack {
            Button {
                if settingViewModel.isTimerPlaying {
                    settingViewModel.isTimerPlaying = false
                    dismissWindow(id: "Script")
                    Task {
                        await dismissImmersiveSpace()
                    }
                } else {
                    settingViewModel.isTimerPlaying = true
                }
            } label: {
                ZStack {
                    HStack(spacing: 6) {
                        Image(systemName: settingViewModel.isTimerPlaying ? "stop.fill" : "play.fill")
                        Text(settingViewModel.isTimerPlaying ? "\(settingViewModel.counter.asTimeHMS)" : "Start")
                            .onReceive(timer) { _ in
                                if settingViewModel.isTimerPlaying {
                                    self.settingViewModel.counter += 1
                                }
                            }
                    }
                    .foregroundStyle(settingViewModel.isTimerPlaying ? Color.red : Color.white)
                }
            }
            .tint(settingViewModel.isTimerPlaying ? nil : Color.green)
        }
    }
}
