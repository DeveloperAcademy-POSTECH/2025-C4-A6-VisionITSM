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
    @StateObject private var viewModel = AudienceSpawnViewModel()
    
//    let trackRoot: Entity = Entity()
    
//    let headAnchorRoot: Entity = Entity()
    
//    let headPositionedEntitiesRoot: Entity = Entity()
    
//    let potato: Entity = Entity()
    
    var body: some View {
        RealityView { content in
            do {
                let immersiveBackground = try await Entity(named: "Immersive", in: realityKitContentBundle)
                content.add(immersiveBackground)

//                let headAnchor = AnchorEntity(.head)
//                headAnchor.name = "headAnchor"
//                headAnchorRoot.addChild(headAnchor)

//                guard let potatoContent = immersiveBackground.findEntity(named: "potato") else {
//                    fatalError("⚠️ potato not found in immersiveBackground")
//                }
//                potato.addChild(potatoContent)
//                guard let potatoContent = try? await Entity(named: "potato", in: realityKitContentBundle) else {
//                    fatalError("⚠️ Failed to load potato from realityKitContentBundle")
//                }

//                trackRoot.components.set(TrackingComponent())
//                content.add(trackRoot)

//                for position in viewModel.spawnPoints {
//                    let potatoClone = potato.clone(recursive: true)
//                    potatoClone.setPosition(position, relativeTo: nil)


                    // Only add TrackingComponent to left and right eye:
//                    ["Sphere_001", "Sphere_002"].forEach { name in
//                        if let eye = potatoClone.findEntity(named: name) {
////                            eye.components.set(TrackingComponent())
//                        } else {
//                            print("⚠️ Entity named \(name) not found in clone")
//                        }
//                    }
//                    potatoClone.setPosition(position, relativeTo: nil)
//                    potatoClone.transform.rotation = originalTransform.rotation
//                    potatoClone.components.set(TrackingComponent())
//                    content.add(potatoClone)


//                    playPotatoAnimation(on: potatoClone)
//                }

                
                let potatoAnchors = ["potato_1", "potato_2", "potato_3", "potato_4", "potato_5", "potato_6", "potato_7"]
                let potatoVariants = ["potato", "potato2", "potato3", "potato4"]
                
                let spawnCount = 3
                let selectedAnchors = Set(potatoAnchors.shuffled().prefix(spawnCount))
                
                for anchorName in potatoAnchors {
                    if let anchorEntity = immersiveBackground.findEntity(named: anchorName) {
                        anchorEntity.isEnabled = false
                    }
                }
                
                for anchorName in selectedAnchors {
                    if let anchorEntity = immersiveBackground.findEntity(named: anchorName) {
                        print("🔎 anchorEntity 추가 중: \(anchorName)")
                        
                        // ✅ 자식 엔티티 비활성화
                            deactivateAllChildren(of: anchorEntity)
                        
                        // TODO :: 감자 눈이 안 지워지는 이슈가 있으며, anchorEntity를 다 지워버리면
                        //                        print("⚠️ 삭제: \(anchorEntity.children)")
                        //                        removeAllChildrenRecursively(from: anchorEntity)
                        
                        anchorEntity.isEnabled = true
                        
                        if selectedAnchors.contains(anchorName) {
                            // 기존 자식 제거
//                            removeAllChildrenRecursively(from: anchorEntity)
                            
                            
                            
                            let randomName = potatoVariants.randomElement()!
                            let randomModel = try await Entity(named: randomName, in: realityKitContentBundle)
                            
                            //                        print(anchorEntity.transform)
                            //                        randomModel.transform = anchorEntity.transform
                            
                            anchorEntity.addChild(randomModel)
                            //                        print(anchorEntity)
                            
                            playPotatoAnimation(on: randomModel)
                        }
                    }else {
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
    /*
    func removeAllChildrenRecursively(from entity: Entity) {
        for child in entity.children {
//            print("⚠️ 삭제 중: \(child)")
            removeAllChildrenRecursively(from: child)
            child.removeFromParent()
        }
    }*/
    
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
