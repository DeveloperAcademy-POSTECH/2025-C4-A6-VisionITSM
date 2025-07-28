//
//  SpatialAudioPlayer.swift
//  VisionITSM
//
//  Created by coulson on 7/28/25.
//

import RealityKit
import RealityKitContent
import Foundation

enum SpatialAudioPlayer {
    static func playSound(
        entity: Entity,
        audioFileName: String,
        fromUSDAScene usdaName: String,
        duration: TimeInterval
    ) async {
        do {
            let audioResource = try await AudioFileResource.load(
                named: "/Root/SpatialAudio/\(audioFileName)",
                from: usdaName,
                in: realityKitContentBundle
            )
            
            let audioController = entity.prepareAudio(audioResource)
            audioController.play()
            
            // 일정 시간이 지나면 오디오 재생 중단
            Task {
                try? await Task.sleep(for: .seconds(duration))
                audioController.stop()
            }
        } catch {
            print("❌ \(audioFileName) 로드 실패: \(error.localizedDescription)")
        }
    }
    
    static func playSound(
        audioFileName: String,
        fromUSDAScene usdaName: String,
        duration: TimeInterval
    ) async {
        let dummyEntity = Entity()
        await playSound(entity: dummyEntity, audioFileName: audioFileName, fromUSDAScene: usdaName, duration: duration)
    }
}
