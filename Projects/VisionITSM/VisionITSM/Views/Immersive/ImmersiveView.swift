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
    
    @Bindable var homeViewModel: HomeViewModel
    
//    let spawnSliderPosition: Entity = Entity()
    
    var body: some View {
        
        var potatoPositions: [SIMD3<Float>] = []    // 랜덤 배치되는 감자 청중의 위치를 저장하여 조명 등의 기능에 사용될 위치정보
        
        RealityView { content, attachments in
            do {
                let audienceSizeLevel = settingViewModel.settingModel.audienceSize
                let spawnCount: Int
                let backgroundName: String
                let potatoAnchors: [String]
                
                switch audienceSizeLevel {
                case 0.0:
                    spawnCount = 5
                    backgroundName = "Immersive_5"
                    potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5"]
                case 1.0:
                    spawnCount = 10
                    backgroundName = "Immersive_10"
                    potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5", "potato_6", "potato_7", "potato_8", "potato_9", "potato_10"]
                case 2.0:
                    spawnCount = 20
                    backgroundName = "Immersive_20"
                    potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5", "potato_6", "potato_7", "potato_8", "potato_9", "potato_10", "potato_11", "potato_12", "potato_13", "potato_14", "potato_15", "potato_16", "potato_17", "potato_18", "potato_19", "potato_20"]
                default:
                    spawnCount = 5
                    backgroundName = "Immersive_5"
                    potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5"]
                }
                
                print("발표 연습 시작: \(spawnCount), \(backgroundName)")
                
                let immersiveBackground = try await Entity(named: backgroundName, in: realityKitContentBundle)
                content.add(immersiveBackground)
                
                guard let spawnSliderPosition = immersiveBackground.findEntity(named: "SpawnSlidePosition") else {
                    fatalError("spawnSliderPosition 엔티티를 찾을 수 없습니다")
                }
                
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
                        
//                        anchorEntity.isEnabled = true
                        
                        if selectedAnchors.contains(anchorName) {
                            
                            let randomName = potatoVariants.randomElement()!
                            let randomModel = try await Entity(named: randomName, in: realityKitContentBundle)
                            
                            anchorEntity.addChild(randomModel)
                            
                            let position = anchorEntity.position(relativeTo: nil)
                            potatoPositions.append(position)
                            
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
                if !potatoPositions.isEmpty {
                    let averagePosition = potatoPositions.reduce(SIMD3<Float>(0,0,0), +) / Float(potatoPositions.count)

                    let lightEntity = Entity()
                    /*
                     let light = DirectionalLightComponent(color: .white, intensity: 5000, isRealWorldProxy: false)
                     lightEntity.components.set(light)
                     */
                    var light = DirectionalLightComponent()
                    light.intensity = 5000
                    lightEntity.components.set(light)

                    // 감자들의 중심을 비추도록 방향 설정
                    lightEntity.look(
                        at: averagePosition,
                        from: averagePosition + SIMD3<Float>(2, 3, 2),  // 위에서 비추도록 offset
                        relativeTo: nil
                    )
                    
                    content.add(lightEntity)
                    
//                     이 위치는 RC Pro에서 설정한 위치
                    spawnSliderPosition.setPosition(spawnSliderPosition.position, relativeTo: nil)
                    content.add(spawnSliderPosition)
                    
                    if let attachment = attachments.entity(for: "Slide") {
                        attachment.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
                        attachment.position = SIMD3<Float>(0.0, 0.15, 0)
                        spawnSliderPosition.addChild(attachment)
                    }
                    
                }
            } catch {
                fatalError("No entity to load")
            }
        } attachments: {
            Attachment(id: "Slide") {
                SlideView(homeViewModel: homeViewModel)
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
