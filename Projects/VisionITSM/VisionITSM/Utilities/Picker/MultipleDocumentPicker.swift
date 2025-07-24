//
//  MultipleDocumentPicker.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct MultipleDocumentPicker: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    @Binding var selectedPDFURL: [URL]
    @Binding var selectedPPTXURL: [URL]
//    @Binding var isPresented: Bool
    @Binding var isNext: Bool
    
    @Bindable var viewModel: HomeViewModel
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: MultipleDocumentPicker
        
        init(_ parent: MultipleDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            var pdfURLs: [URL] = []
//            var pptxURLs: [URL] = []
            
            for url in urls {
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                let fileExtension = url.pathExtension.lowercased()

                if fileExtension == "pdf" {
                    parent.viewModel.selectedPDFURL = [url]
//                    parent.viewModel.keynoteTitle = getPDFTitle(from: url) ?? ""
                    print(parent.selectedPDFURL)
                } else if fileExtension == "pptx" {
                    parent.viewModel.selectedPPTXURL = [url]
//                    parent.viewModel.keynoteTitle = getPDFTitle(from: url) ?? ""
                    print(parent.selectedPPTXURL)
                }
            }
            
            parent.isNext = true
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            parent.isPresented = false
        }
        
        
        func getPDFTitle(from url: URL) -> String? {
            guard let pdfDocument = PDFDocument(url: url) else {
                print("❌ PDFDocument를 열 수 없음")
                return nil
            }
            
            // PDF 메타데이터에서 제목 가져오기
            if let title = pdfDocument.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
                return title
            } else {
                print("ℹ️ 제목 정보 없음")
                return nil
            }
        }
    }
}

