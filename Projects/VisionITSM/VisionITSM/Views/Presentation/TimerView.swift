//
//  Timer.swift
//  VisionITSM
//
//  Created by 진아현 on 7/16/25.
//

import SwiftUI

struct TimerView: View {
    //MARK: - PROPERTIES
    @Binding var isPlaying: Bool
    @Bindable var settingViewModel: SettingViewModel
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //MARK: - BODY
    var body: some View {
        VStack {
            Button {
                if isPlaying {
                    isPlaying = false
                    dismissWindow(id: "Script")
                    Task {
                        await dismissImmersiveSpace()
                    }
                } else {
                    isPlaying = true
                }
            } label: {
                ZStack {
                    HStack(spacing: 6) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        Text(isPlaying ? "\(settingViewModel.counter.asTimeHMS)" : "Start")
                            .onReceive(timer) { _ in
                                if isPlaying {
                                    self.settingViewModel.counter += 1
                                }
                            }
                    }
                    .foregroundStyle(isPlaying ? Color.red : Color.white)
                }
            }
            .tint(isPlaying ? nil : Color.green)
        }
    }
}
