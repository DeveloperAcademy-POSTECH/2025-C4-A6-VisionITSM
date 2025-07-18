//
//  MultipleDocumentPicker.swift
//  VisionITSM
//
//  Created by 진아현 on 7/17/25.
//

import SwiftUI

struct MultipleDocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedPPTXURL: URL?
    @Binding var selectedPDFURL: URL?
    @Binding var isPresented: Bool
    @Binding var isNext: Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
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
                // 보안 스코프 리소스 접근 시작 (확인용)
                let accessing = url.startAccessingSecurityScopedResource()
                
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                let fileExtension = url.pathExtension.lowercased()
                if fileExtension == "pptx" {
                    parent.selectedPPTXURL = url
                } else if fileExtension == "pdf" {
                    parent.selectedPDFURL = url
                }
            }
            if !(parent.selectedPDFURL == nil) && !(parent.selectedPPTXURL == nil) {
                print("선택 완료")
                parent.isNext = true
            }
            parent.isPresented = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }
}

