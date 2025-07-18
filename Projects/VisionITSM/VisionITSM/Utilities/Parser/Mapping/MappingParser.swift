//
//  MappingParse.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI

class MappingParser {
    func combineSlideDataWithMapping(images: [UIImage], mappings: [SlideNoteMapping]) -> [SlideData] {
        var slides: [SlideData] = []
        
        // 매핑 정보를 딕셔너리로 변환 (빠른 검색)
        let mappingDict = Dictionary(uniqueKeysWithValues: mappings.map {
            ($0.slideNumber, $0)
        })
        
        for i in 0..<images.count {
            let slideNumber = i + 1
            let slideImage = images[i]
            
            // 매핑 정보에서 해당 슬라이드의 발표자 메모 검색
            let mapping = mappingDict[slideNumber]
            let presenterNote = mapping?.noteText ?? ""
            
            let slide = SlideData(
                slideNumber: slideNumber,
                slideImageData: slideImage.pngData()!,
                presenterNotes: presenterNote
            )
            slides.append(slide)
            
            print("최종 매핑: 슬라이드 \(slideNumber) - 메모 있음: \(mapping?.hasNotes ?? false)")
        }
        
        return slides
    }
}
