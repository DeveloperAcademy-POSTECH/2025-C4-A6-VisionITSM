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
    
//    let spawnSliderPosition: Entity = Entity()
    
    @State private var potatoEntities: [PotatoEntity] = []
    
    struct PotatoEntity {
        let entity: Entity
        let anchor: Entity
        let originalModelName: String
        var isSleeping: Bool = false
    }
    
    var body: some View {
        
        var potatoPositions: [SIMD3<Float>] = []    // 랜덤 배치되는 감자 청중의 위치를 저장하여 조명 등의 기능에 사용될 위치정보
        
        RealityView { content in
            do {
                let audienceSizeLevel = settingViewModel.settingModel.audienceSize
                
                let spawnCount: Int
                let backgroundName: String
                
                switch audienceSizeLevel {
                case 0.0:
                    spawnCount = 5
                    backgroundName = "Immersive_5"
                case 1.0:
                    spawnCount = 10
                    backgroundName = "Immersive_10"
                case 2.0:
                    spawnCount = 20
                    backgroundName = "Immersive_20"
                default:
                    spawnCount = 5
                    backgroundName = "Immersive_5"
                }
                
                print("발표 연습 시작: \(spawnCount), \(backgroundName)")
                
                let immersiveBackground = try await Entity(named: backgroundName, in: realityKitContentBundle)
                content.add(immersiveBackground)
                
                guard let spawnSliderPosition = immersiveBackground.findEntity(named: "SpawnSlidePosition") else {
                    fatalError("spawnSliderPosition 엔티티를 찾을 수 없습니다")
                }
                
                let potatoAnchors = findPotatoAnchors(in: immersiveBackground)
                print("찾은 potato 앵커들: \(potatoAnchors)")
                
                guard potatoAnchors.count >= spawnCount else {
                    fatalError("potatoAnchors 부족: 필요한 수량 \(spawnCount), 찾은 수량 \(potatoAnchors.count)")
                }
                
                let potatoVariants = ["potato", "potato2", "potato3", "potato4"]

                let selectedAnchors = Set(potatoAnchors).shuffled().prefix(spawnCount)
                
                for anchorName in potatoAnchors {
                    if let anchorEntity = immersiveBackground.findEntity(named: anchorName) {
                        anchorEntity.isEnabled = false
                        deactivateAllChildren(of: anchorEntity)
                    }
                }
                
                potatoEntities.removeAll()
                
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
                            
                            let potatoEntity = PotatoEntity(
                                entity: randomModel,
                                anchor: anchorEntity,
                                originalModelName: randomName
                            )
                            potatoEntities.append(potatoEntity)
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
    func findPotatoAnchors(in rootEntity: Entity) -> [String] {
        var potatoAnchors: [String] = []
        
        func searchRecursively(_ entity: Entity) {
            if entity.name.lowercased().contains("potato") {
                potatoAnchors.append(entity.name)
            }
            
            for child in entity.children {
                searchRecursively(child)
            }
        }
        
        searchRecursively(rootEntity)
        
        return potatoAnchors.sorted()
    }
    
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
    
    // 돌발행동: 졸기
    func checkSleepEvent(currentTime: Int) {
        let distractionLevel = settingViewModel.settingModel.distractionLevel
        
        guard distractionLevel > 0 else { return }
        
        let interval: Int
        switch distractionLevel {
        case 1:
            interval = 60
        case 2:
            interval = 30
        default:
            return
        }
        
        if currentTime > 0 && currentTime % interval == 0 {
            handleSleepEvent()
            print("졸음 이벤트 확인 시작 - 시간: \(currentTime)초, distractionLevel: \(distractionLevel)")
        }
    }
    
    func handleSleepEvent() {
        let distractionLevel = settingViewModel.settingModel.distractionLevel
        
        if Bool.random() == false {
            print("50% 확률로 졸음 이벤트 스킵됨")
            return
        }
        
        let awakePotatos = potatoEntities.filter { !$0.isSleeping }
        
    }
}
