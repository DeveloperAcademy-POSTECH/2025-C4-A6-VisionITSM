import SwiftUI
import RealityKit
import RealityKitContent
import ARKit


struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(SettingViewModel.self) private var settingViewModel
    
    @Bindable var homeViewModel: HomeViewModel
    
    @State private var potatoEntities: [PotatoEntity] = []
    @State private var presentationTimer: Timer?
    @State private var elapsedTime: Int = 0
    @State private var lastSleepEventTime: Int = -1
    
    struct PotatoEntity {
        let entity: Entity
        let anchor: Entity
        let originalModelName: String
        var isSleeping: Bool = false
    }
    
    var body: some View {
        
        var potatoPositions: [SIMD3<Float>] = []    // 랜덤 배치되는 감자 청중의 위치를 저장하여 조명 등의 기능에 사용될 위치정보
        
        RealityView { content, attachments in
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
                            print("position: \(position)")
                            potatoPositions.append(position)
                            
                            ["rightEye", "leftEyeball", "rightEye_001"].forEach { eyeName in
                                if let eye = randomModel.findEntity(named: eyeName) {
                                    eye.components.set(TrackingComponent())
                                } else {
                                    print("⚠️ 눈 엔티티 \(eyeName) 찾을 수 없음 in \(randomName)")
                                }
                            }
                            
                            randomModel.position = anchorEntity.position(relativeTo: nil)
                            print("position: \(randomModel.position)")
                            randomModel.scale = anchorEntity.scale(relativeTo: nil)
                            
                            content.add(randomModel)
                            
                            deactivateAllChildren(of: anchorEntity)
                            
                            playPotatoAnimation(on: randomModel)
                            
//                            Task {
//                                await cyclePotatoAnimation(on: randomModel)
//                            }
                            
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
                    
                    if let attachment = attachments.entity(for: "Slide") {
                        attachment.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
                        attachment.position = SIMD3<Float>(0.0, 0.54, 0)
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
        .onChange(of: settingViewModel.isTimerPlaying) { _, newValue in
            if newValue {
                startPresentationTimer()
            } else {
                stopPresentationTimer()
            }
        }
    }
}

extension ImmersiveView {
    private struct PotatoAnimationConfig {
        static let transitionDuration: TimeInterval = 0.5
        static let basicAnimationSpeed: Float = 0.4
        static let sleepAnimationSpeed: Float = 0.5
        static let sleepDelay: TimeInterval = 5.0
        static let sleepAnimationDuration: TimeInterval = 60.0
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
    
    func startPresentationTimer() {
        print("=== 발표 타이머 시작")
        elapsedTime = 0
        
        presentationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
//            print("=== 발표 경과 시간: \(elapsedTime)초")
            
            checkSleepEvent(currentTime: elapsedTime)
        }
    }

    func stopPresentationTimer() {
        print("=== 발표 타이머 정리")
        presentationTimer?.invalidate()
        presentationTimer = nil
        elapsedTime = 0
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
        
        if currentTime > 0 && currentTime % interval == 0 && lastSleepEventTime != currentTime {
            lastSleepEventTime = currentTime
            handleSleepEvent()
        }
    }
    
    func handleSleepEvent() {
        if Bool.random() == false {
            print("❌ 50% 확률로 돌발상황 스킵")
            return
        }
        
        let awakePotatos = potatoEntities.filter { !$0.isSleeping }
        
        guard let target = awakePotatos.randomElement() else {
            print("❌ 모든 감자가 자는 중이라 돌발상황 생략")
            return
        }
        
        if let index = potatoEntities.firstIndex(where: { $0.entity == target.entity }) {
            potatoEntities[index].isSleeping = true
        }
        
        print("😴 감자 졸기 시작: \(target.originalModelName)")
        playSleepAnimation(for: target)
    }
    
    private func getSleepEntityName(for originalModelName: String) -> String {
        return "\(originalModelName)_zzz"
    }
    
    func playSleepAnimation(for potato: PotatoEntity) {
        guard !potato.isSleeping else { return }
        
        if let index = potatoEntities.firstIndex(where: { $0.entity == potato.entity }) {
            potatoEntities[index].isSleeping = true
        }
        
        Task {
            do {
                let sleepEntityName = getSleepEntityName(for: potato.originalModelName)
                let sleepEntity = try await Entity(named: sleepEntityName, in: realityKitContentBundle)
                
                guard let sleepClip = sleepEntity.availableAnimations.first else {
                    print("⚠️ zzz 애니메이션 찾을 수 없음")
                    return
                }
                
                let sleepResource = sleepClip.repeat(count: .max)
                let sleepController = potato.entity.playAnimation(
                    sleepResource,
                    transitionDuration: PotatoAnimationConfig.transitionDuration,
                    startsPaused: false
                )
                sleepController.speed = PotatoAnimationConfig.sleepAnimationSpeed
                
                try await Task.sleep(for: .seconds(PotatoAnimationConfig.sleepAnimationDuration))
                
                potato.entity.stopAllAnimations()
                
                guard let basicClip = potato.entity.availableAnimations.first else {
                    print("⚠️ 기본 애니메이션 찾을 수 없음")
                    return
                }
                
                let basicResource = basicClip.repeat(count: .max)
                let basicController = potato.entity.playAnimation(
                    basicResource,
                    transitionDuration: PotatoAnimationConfig.transitionDuration,
                    startsPaused: false
                )
                basicController.speed = PotatoAnimationConfig.basicAnimationSpeed
                
                print("😊 감자 깨어남: \(potato.originalModelName)")
                
                if let index = potatoEntities.firstIndex(where: { $0.entity == potato.entity }) {
                    potatoEntities[index].isSleeping = false
                }
                
            } catch {
                print("❌ 수면 애니메이션 처리 중 오류: \(error)")
                
                if let index = potatoEntities.firstIndex(where: { $0.entity == potato.entity }) {
                    potatoEntities[index].isSleeping = false
                }
            }
        }
    }
}
