//
//  ImmersiveView.swift
//  VisionITSM
//
//  Created by 선애 on 7/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(SettingViewModel.self) private var settingViewModel
    @StateObject private var viewModel = AudienceSpawnViewModel()
    
    var body: some View {
        RealityView { content in
            do {
                let audienceSizeLevel = settingViewModel.settingModel.audienceSize
                let spawnCount: Int
                let backgroundName: String
                
                switch audienceSizeLevel {
                    case 0:
                        spawnCount = 5
                        backgroundName = "Immersive5"
                    case 1:
                        spawnCount = 10
                        backgroundName = "Immersive10"
                    case 2:
                        spawnCount = 20
                        backgroundName = "Immersive20"
                    default:
                        spawnCount = 5
                        backgroundName = "Immersive5"
                }
                
                print("발표 연습 시작: \(spawnCount), \(backgroundName)")
                
                let immersiveBackground = try await Entity(named: backgroundName, in: realityKitContentBundle)
                content.add(immersiveBackground)
                
                let potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5", "potato_6", "potato_7"]
                let potatoVariants = ["potato", "potato2", "potato3", "potato4"]
                
                let selectedAnchors = Set(potatoAnchors).shuffled().prefix(spawnCount)
                
                for anchorName in potatoAnchors {
                    if let anchorEntity = immersiveBackground.findEntity(named: anchorName) {
                        anchorEntity.isEnabled = false
                        deactivateAllChildren(of: anchorEntity)
                    }
                }
                
                for anchorName in selectedAnchors {
                    if let anchorEntity = immersiveBackground.findEntity(named: anchorName) {
                        print("🔎 anchorEntity 추가 중: \(anchorName)")
                        
                        if selectedAnchors.contains(anchorName) {
                            let randomName = potatoVariants.randomElement()!
                            let randomModel = try await Entity(named: randomName, in: realityKitContentBundle)
                            
                            anchorEntity.addChild(randomModel)
                            
                            // Eye tracking component 추가
                            ["rightEye", "leftEyeball", "rightEye_001"].forEach { eyeName in
                                if let eye = randomModel.findEntity(named: eyeName) {
                                    eye.components.set(TrackingComponent())
                                } else {
                                    print("⚠️ 눈 엔티티 \(eyeName) 찾을 수 없음 in \(randomName)")
                                }
                            }

                            randomModel.setPosition(randomModel.position, relativeTo: nil)
                            content.add(randomModel)
                            
                            deactivateAllChildren(of: anchorEntity)
                            
                            playPotatoAnimation(on: randomModel)
                        }
                    } else {
                        print("⚠️ anchorEntity 추가 실패: \(anchorName)")
                    }
                }

            } catch {
                fatalError("No entity to load")
            }
        }
        .onAppear {
            viewModel.generateSpawnPositions()
        }
    }
}

extension ImmersiveView {
    func deactivateAllChildren(of entity: Entity) {
        for child in entity.children {
            child.isEnabled = false
            deactivateAllChildren(of: child)
        }
    }
    
    func playPotatoAnimation(on entity: Entity) {
        guard let animation = entity.availableAnimations.first else { return }

        let delay = Double.random(in: 0..<0.5)

        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            let repeated = animation.repeat(count: .max)
            entity.playAnimation(repeated, transitionDuration: 1, startsPaused: false)
        }
    }
}
