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
    
    func parseFiles(pptxURL: URL?, pdfURL: URL?) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdfURL = pdfURL else {
                print("❌ PDF는 필수입니다.")
                DispatchQueue.main.async {
                    self.errorMessage = "PDF 파일이 필요합니다."
                    self.isLoading = false
                }
                return
            }

            let pdfAccessing = pdfURL.startAccessingSecurityScopedResource()
            var pptxAccessing = false
            var slideNoteMappings: [SlideNoteMapping] = []
            
            // ✅ PDF에서 이미지 추출
            let slideImages = self.extractImagesFromPDF(pdfURL: pdfURL)

            // ✅ PPTX가 있는 경우에만 발표자 메모 추출 시도
            if let pptxURL = pptxURL {
                pptxAccessing = pptxURL.startAccessingSecurityScopedResource()
                do {
                    slideNoteMappings = try self.extractNotes(from: pptxURL)
                } catch {
                    print("⚠️ PPTX 파싱 실패: \(error.localizedDescription)")
                }
            } else {
                print("⚠️ PPTX 파일 없음 → 발표자 메모 없이 진행")
            }
            
            defer {
                if pptxAccessing { pptxURL?.stopAccessingSecurityScopedResource() }
                if pdfAccessing { pdfURL.stopAccessingSecurityScopedResource() }
            }
            
            // ✅ PDF + (option) 발표자 메모 → SlideData
            let slides = self.combineSlide(images: slideImages, mappings: slideNoteMappings)
            
            DispatchQueue.main.async {
                self.slides = slides
                self.isLoading = false
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
