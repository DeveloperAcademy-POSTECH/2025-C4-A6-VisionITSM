//
//  PDFParser.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI
import PDFKit

class SimplePDFParser {
    func extractImagesContents(pdfURL: URL) -> [UIImage] {
        var images: [UIImage] = []
        
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("PDF 로드 실패")
            return images
        }
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                let pageRect = page.bounds(for: .mediaBox)
                let image = page.thumbnail(of: pageRect.size, for: .mediaBox)
                images.append(image)
            } else {
                print("슬라이드 추출 실패")
                let image = createPlaceholderImage(slideNumber: pageIndex)
                images.append(image)
            }
        }
        
        print("PDF에서 \(images.count)개 슬라이드 이미지 추출 완료")
        return images
    }
    
    private func createPlaceholderImage(slideNumber: Int) -> UIImage {
        let size = CGSize(width: 800, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = "슬라이드 \(slideNumber)\n(이미지 없음)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
