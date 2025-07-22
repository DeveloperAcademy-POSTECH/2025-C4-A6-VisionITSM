//
//  SlideView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/15/25.
//

import SwiftUI
import RealityKit

struct SlideView: View {
    //MARK: - PROPERTIES
    @Bindable var homeViewModel: HomeViewModel
    
    //MARK: - BODY
    var body: some View {
        RealityView { content in
            if let slideImage = imageProcessing(keynote: homeViewModel.currentKeynote ?? .init(title: "오류", keynote: [])) as UIImage?,
               let cgImage = slideImage.cgImage,
               let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color)) {

                var material = UnlitMaterial()
                material.color = .init(texture: .init(texture))
                

                let aspectRatio = slideImage.size.width / slideImage.size.height
                let height: Float = 1.0
                let width: Float = height * Float(aspectRatio)

                let planeMesh = MeshResource.generatePlane(width: width, height: height)
                let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
                planeEntity.name = "SlidePlane"

                // Optional: Add BillboardComponent if available (uncomment if desired)
                // planeEntity.components.set(BillboardComponent())

                // ✅ 월드 공간에 슬라이드 고정 (사용자 뒤에 위치, chalkboard처럼 고정)
                let anchor = AnchorEntity(world: [0, 1.5, 2]) // 2 meters behind the user
                anchor.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0]) // rotate to face user
                planeEntity.position = [0, 0, 0.2]
                planeEntity.transform.rotation =  simd_quatf(angle: .pi, axis: [0, 1, 0])
                // 슬라이드가 항상 사용자를 바라보게 하려면 아래 코드 활성화:
                // planeEntity.look(at: [0, 1.5, 0], from: planeEntity.position, relativeTo: nil)
                anchor.addChild(planeEntity)
                content.add(anchor)

                content.add(planeEntity)
            }
        }
    }
    
    func imageProcessing(keynote: HomeModel) -> UIImage {
        return keynote.keynote.count == 0 ? .gridNewButton : keynote.keynote[homeViewModel.currentIndex].slideImage ?? .gridNewButton
    }
}

#Preview {
    SlideView(homeViewModel: .init())
}
