//
//  NewFileModalView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/22/25.
//

import SwiftUI

struct NewFileModalView: View {
    //MARK: - PROPERTIES
    @State private var fileName = ""
    @Environment(\.dismiss) private var dismiss
    @Bindable var homeViewModel: HomeViewModel
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment: .center) {
            NewFileModelNavBar
            NewFileSelectSection
            NewFileImportButton
        }
        .padding(.horizontal, 24)

    }
    
    //MARK: - VIEW
    private var NewFileModelNavBar: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonBorderShape(.circle)
                
                Spacer()
            }
            
            Text("Add New")
                .fontWeight(.bold)
                .font(.system(size: 29))
        }
        .frame(height: 92)
    }
    
    private var NewFileImportButton: some View {
        Button {
            print("import")
        } label: {
            Label("Import", systemImage: "square.and.arrow.down")
        }
        .padding(.bottom, 23)
    }
    
    private var NewFileSelectSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("File Name", text: $fileName)
                .font(.largeTitle)
            
            ForEach(homeViewModel.newFileInfos, id: \.id) { info in
                VStack(alignment: .leading, spacing: 20) {
                    Text(info.title)
                        .font(.system(size: 19))
                        .fontWeight(.bold)
                    
                    Button {
                        info.action()
                    } label: {
                        HStack {
                            Spacer()
                            if let pdfURL = homeViewModel.selectedPDFURL?.first {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("PDF: \(pdfURL.lastPathComponent)")
                                }
                            } else {
                                Text(info.buttonDescription)
                            }
                            Spacer()
                        }
                        .frame(height: 72)
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 16))
                    
                    Text(info.description)
                        .font(.system(size: 13))
                        .fontWeight(.medium)
                }
                .padding(.bottom, 18)
            }
            
            
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Upload Slide Notes (Optional)")
//                    .font(.system(size: 19))
//                    .fontWeight(.bold)
//                
//                Button {
//                    homeViewModel.showingFilePicker = false
//                    homeViewModel.showPPTXPicker = true
//                } label: {
//                    HStack {
//                        Spacer()
//                        if let pptxURL = homeViewModel.selectedPPTXURL?.first {
//                            HStack {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundStyle(Color.green)
//                                Text("PPTX: \(pptxURL.lastPathComponent)")
//                            }
//                        } else {
//                            Text("Upload from file (.PPTX)")
//                        }
//                        Spacer()
//                    }
//                    .frame(height: 72)
//                }
//                .buttonBorderShape(.roundedRectangle(radius: 16))
//                
//                Text("A PPTX file is only needed if you want to import slide notes.")
//                    .font(.system(size: 13))
//                    .fontWeight(.medium)
//            }
//            .padding(.bottom, 18)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }
    
    //MARK: - FUNCTION
    
}

#Preview {
    NewFileModalView(homeViewModel: .init())
}
