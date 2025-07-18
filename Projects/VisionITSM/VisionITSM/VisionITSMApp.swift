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
    @State private var homeViewModel: HomeViewModel = .init()
    
    init() {
        TrackingSystem.registerSystem()
        TrackingComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup(id: "home") {
            HomeView(homeViewModel: homeViewModel)
                .environment(appModel)
        }
        .modelContainer(for: HomeModel.self)
        .windowResizability(.contentSize)
        .defaultWindowPlacement {content,context in 
            WindowPlacement(.utilityPanel)
        }
        
        WindowGroup(id: "slideWindow") {
            SlideView(homeViewModel: homeViewModel)
        }
        .defaultWindowPlacement { content, context in
            guard let contentWindow = context.windows.first(where: { $0.id == "home" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.above(contentWindow))
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
        .immersionStyle(selection: .constant(.progressive), in: .full)
        //MARK: - 이머시브존3 ( 크라운 조절 믹스드)
        .immersionStyle(selection: .constant(.full), in: .mixed)
    }
}
