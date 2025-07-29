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
    @State private var settingViewModel: SettingViewModel = SettingViewModel()
    @State private var router = NavigationRouter()
    
    init() {
        TrackingSystem.registerSystem()
        TrackingComponent.registerComponent()
    }
 
    var body: some Scene {
        WindowGroup(id: "home") {
            HomeView(homeViewModel: homeViewModel, router: router)
                .environment(appModel)
                .environment(settingViewModel)
        }
        .windowStyle(.plain)
        .modelContainer(for: HomeModel.self)
        .windowResizability(.contentSize)
        
        
        WindowGroup(id: "Script") {
            ScriptView(homeViewModel: homeViewModel, settingViewModel: settingViewModel, keynote: homeViewModel.currentKeynote ?? HomeModel(title: "오류", keynote: []), router: router)
                .frame(width: 640, height: 480)
                .persistentSystemOverlays(.hidden)
            
        }
        .windowResizability(.contentSize)
        
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView(homeViewModel: homeViewModel)
                .environment(appModel)
                .environment(settingViewModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
//        .immersionStyle(selection: .constant(.progressive), in: .progressive)
        .immersionStyle(selection: .constant(.progressive), in: .full)
        //MARK: - 이머시브존3 ( 크라운 조절 믹스드)
//        .immersionStyle(selection: .constant(.full), in: .mixed)
    }
}
