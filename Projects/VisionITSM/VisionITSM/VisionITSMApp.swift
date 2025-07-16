//
//  VisionITSMApp.swift
//  VisionITSM
//
//  Created by 선애 on 7/9/25.
//

import SwiftUI
import SwiftData

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
        .modelContainer(for: HomeModel.self)
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
        //MARK: - 이머시브존3 ( 크라운 조절 믹스드)
//        .immersionStyle(selection: .constant(.full), in: .mixed)
    }
}
