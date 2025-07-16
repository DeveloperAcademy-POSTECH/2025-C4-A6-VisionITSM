//
//  HybridParser.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI
import ZIPFoundation
import PDFKit

@Observable
class HybridPPTXParser: ObservableObject {
    var slides: [SlideData] = []
    var isLoading = false
    var errorMessage: String?
    
    func parseFiles(pptxURL: URL, pdfURL: URL) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 보안 스코프 리소스 접근 시작
            let pptxAccessing = pptxURL.startAccessingSecurityScopedResource()
            let pdfAccessing = pdfURL.startAccessingSecurityScopedResource()
            
            defer {
                // 작업 완료 후 리소스 접근 중지
                if pptxAccessing {
                    pptxURL.stopAccessingSecurityScopedResource()
                }
                if pdfAccessing {
                    pdfURL.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                // 1. PDF에서 슬라이드 이미지 추출
                let slideImages = self.extractImagesFromPDF(pdfURL: pdfURL)
                
                // 2. 정확한 발표자 메모 매핑 생성
                let slideNoteMappings = try self.extractNotes(from: pptxURL)
                
                // 3. 최종 SlideData 생성
                let slides = self.combineSlide(images: slideImages, mappings: slideNoteMappings)
                
                DispatchQueue.main.async {
                    self.slides = slides
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    //MARK: PDF에서 슬라이드 이미지 추출
    private func extractImagesFromPDF(pdfURL: URL) -> [UIImage] {
        let parser = SimplePDFParser()
        return parser.extractImagesContents(pdfURL: pdfURL)
    }
    
    
    // MARK: - 발표자 메모를 실제 슬라이드에 맞게 매핑
    
    private func extractNotes(from pptxURL: URL) throws -> [SlideNoteMapping] {
        let parser = notesMappingParser()
        do {
            return try parser.extractNotesWithPreciseMapping(from: pptxURL)
        } catch {
            throw error
        }
    }
    
    //MARK: PDF와 PPTX 매핑하여 최종 SlideData 생성
    
    private func combineSlide(images: [UIImage], mappings: [SlideNoteMapping]) -> [SlideData] {
        let parser = MappingParser()
        return parser.combineSlideDataWithMapping(images: images, mappings: mappings)
    }
}
