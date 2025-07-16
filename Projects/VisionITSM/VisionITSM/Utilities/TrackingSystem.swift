//
//  TrackingSystem.swift
//  VisionITSM
//
//  Created by coulson on 7/16/25.
//

import RealityKit
import SwiftUI
import ARKit

public struct TrackingSystem: System {
    
    static let query = EntityQuery(where: .has(TrackingComponent.self))
    
    private let arkitSession = ARKitSession()
    
    private let worldTrackingProvider = WorldTrackingProvider()
    
    public init(scene: RealityKit.Scene) {
        runSession()
    }
    
    func runSession() {
        Task {
            do {
                try await arkitSession.run([worldTrackingProvider])
            } catch {
                print("Error: \(error). Head-position mode will still work.")
            }
        }
    }
    
    
    
    public func update(context: SceneUpdateContext) {
        guard worldTrackingProvider.state == .running else { return }
        guard let deviceAnchor = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            // 사용자의 transform 전체 (위치 + 회전)
            let deviceTransform = Transform(matrix: deviceAnchor.originFromAnchorTransform)

            // 사용자 시선 벡터 (정면 방향)
            let lookDirection = deviceTransform.matrix.columns.2.xyz * -1

            // 시선의 목표 지점 (예: 사용자보다 1m 앞)
            let targetPosition = deviceTransform.translation + lookDirection * 1.0

            // 해당 방향을 향해 회전
            entity.look(
                at: targetPosition,
                from: entity.position(relativeTo: entity.parent),
                relativeTo: entity.parent,
                forward: .positiveZ
            )
        }
    }
    
}
private extension simd_float4 {
    var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}
