//
//  AudienceSpawnViewModel.swift
//  VisionITSM
//
//  Created by coulson on 7/16/25.
//

import SwiftUI
import Foundation
import simd

class AudienceSpawnViewModel: ObservableObject {
    @Published var spawnPoints: [SIMD3<Float>] = []
    
    /// 관객 자리 10개 생성 (계단식 반원 구조)
    func generateSpawnPositions(count: Int = 10) {
        var result: [SIMD3<Float>] = []
        let rows = 2
        let seatsPerRow = 5
        let baseRadius: Float = 5.0
        let radiusStep: Float = 3.0
        let heightStep: Float = 0.7
        let angleRange: Float = .pi
        let angleStep = angleRange / Float(seatsPerRow - 1)
        
        for row in 0..<rows {
            let radius = baseRadius + Float(row) * radiusStep
            let y = Float(row) * heightStep
            
            for seat in 0..<seatsPerRow {
                let angle = -angleRange / 2 + Float(seat) * angleStep
                let x = radius * sin(angle)
                let z = -radius * cos(angle)
                result.append(SIMD3(x: x, y: y, z: z))
            }
        }
        spawnPoints = result
    }
}
