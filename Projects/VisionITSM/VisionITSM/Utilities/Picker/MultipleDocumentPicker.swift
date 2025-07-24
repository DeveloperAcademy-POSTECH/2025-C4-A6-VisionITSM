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
                    print(parent.selectedPDFURL)
                } else if fileExtension == "pptx" {
                    parent.viewModel.selectedPPTXURL = [url]
                    print(parent.selectedPPTXURL)
                }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            parent.isPresented = false
        }
        
        
        func getPDFTitle(from url: URL) -> String? {
            guard let pdfDocument = PDFDocument(url: url) else {
                print("❌ PDFDocument를 열 수 없음")
                return nil
            }

            if let title = pdfDocument.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
                return title
            } else {
                print("ℹ️ 제목 정보 없음")
                return nil
            }
        }
    }
}

