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
    
    var body: some View {
        
        var potatoPositions: [SIMD3<Float>] = []    // 랜덤 배치되는 감자 청중의 위치를 저장하여 조명 등의 기능에 사용될 위치정보
        
        RealityView { content, attachments in
            do {
                let audienceSizeLevel = settingViewModel.settingModel.audienceSize
                let spawnCount: Int
                let backgroundName: String
                
                let sleepPotato: [String]
                
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
                            
                            Task {
                                await cyclePotatoAnimation(on: randomModel)
                            }
                            
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
    // 감자 애니메이션 전반에 사용되는 설정 (전환 시간, 속도, 대기 시간 등)
    private struct PotatoAnimationConfig {
        static let transitionDuration: TimeInterval = 0.3
        static let basicAnimationSpeed: Float = 0.4
        static let sleepAnimationSpeed: Float = 0.5
        static let sleepDelay: TimeInterval = 5.0
        static let sleepAnimationDuration: TimeInterval = 10.0    // 수면 애니메이션 재생 시간 (10초)
    }
    
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
        
        let delay = Double.random(in: 0..<1.0)
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            let repeated = animation.repeat(count: .max)
            entity.playAnimation(repeated, transitionDuration: 1, startsPaused: false)
        }
    }
    
    /// 기본 애니메이션과 수면 애니메이션을 순차적으로 재생하는 메서드
    func cyclePotatoAnimation(on entity: Entity) async {
        // 지정된 속도로 애니메이션을 반복 재생하는 헬퍼
        func playLooping(_ clip: AnimationResource) {
            let resource = clip.repeat(count: .max)
            let controller = entity.playAnimation(
                resource,
                transitionDuration: PotatoAnimationConfig.transitionDuration,
                startsPaused: false
            )
            controller.speed = PotatoAnimationConfig.basicAnimationSpeed
        }

        // 1. 기본 애니메이션 재생
        guard let basicClip = entity.availableAnimations.first else { return }
        playLooping(basicClip)

        // 2. 수면 전 대기
        try? await Task.sleep(for: .seconds(PotatoAnimationConfig.sleepDelay))
        // entity.stopAllAnimations()  // 기본 애니메이션을 계속 유지

        // 3. 수면 애니메이션 로드 및 재생
        if let sleepEntity = try? await Entity(named: "potatoZZZ", in: realityKitContentBundle),
           let sleepClip = sleepEntity.availableAnimations.first {
            // sleep 전용 속도로 반복 재생
            let sleepResource = sleepClip.repeat(count: .max)
            let sleepController = entity.playAnimation(
                sleepResource,
                transitionDuration: PotatoAnimationConfig.transitionDuration,
                startsPaused: false
            )
            sleepController.speed = PotatoAnimationConfig.sleepAnimationSpeed
        }

        // 4. 수면 애니메이션 재생 후 기본 애니메이션으로 복귀
        try? await Task.sleep(for: .seconds(PotatoAnimationConfig.sleepAnimationDuration))
        // entity.stopAllAnimations()  // 중단 없이 바로 기본 재생 유지
        playLooping(basicClip)
    }
}
