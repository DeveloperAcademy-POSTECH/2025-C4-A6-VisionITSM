//
//  VisionITSMApp.swift
//  VisionITSM
//
//  Created by 선애 on 7/9/25.
//

import SwiftUI

@main
struct VisionITSMApp: App {

    @State private var appModel: AppModel = AppModel()
    
    init() {
        TrackingSystem.registerSystem()
        TrackingComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(appModel)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: "slideWindow") {
            SlideView()
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive), in: .progressive)
    }
}
