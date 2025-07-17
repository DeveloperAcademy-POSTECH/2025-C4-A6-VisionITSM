//
//  HomeView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI
import RealityKitContent
import SwiftData

struct HomeView: View {
    //MARK: - PROPERTIES
    let columns = Array(repeating: GridItem(.adaptive(minimum: 256), spacing: 48), count: 1)
    
    @State private var router = NavigationRouter()
    @State private var settingViewModel: SettingViewModel = .init()
    @State private var parser = HybridPPTXParser()
    
    @State private var homeViewModel: HomeViewModel = .init()
    
    @Environment(\.modelContext) private var context
    @Query(sort: \HomeModel.createAt, order: .reverse) private var keynotes: [HomeModel]
    
    //MARK: - BODY
    var body: some View {
        NavigationStack(path: $router.path) {
            
            VStack {
                recentKeynoteView
                
                if parser.isLoading {
                    loadingView
                } else if homeViewModel.currentKeynote == nil {
                    SelectView
                } else {
                    PresentButtonView
                }
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 48) {
                    ForEach(keynotes, id: \.self) { keynote in
                        Button {
                            print(keynote.title)
                            settingViewModel.isShowSetting.toggle()
                        } label: {
                            GridItemView(title: keynote.title, date: "\(keynote.keynote.count)", image: keynote.keynote.first?.slideImage)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $homeViewModel.showingFilePicker) {
                MultipleDocumentPicker(selectedPPTXURL: $homeViewModel.selectedPPTXURL, selectedPDFURL: $homeViewModel.selectedPDFURL, isPresented: $homeViewModel.showingFilePicker)
            }
            .navigationTitle("Recents")
            .padding(.horizontal, 40)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        settingViewModel.isShowSetting.toggle()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .sheet(isPresented: $settingViewModel.isShowSetting) {
                SettingView(settingViewModel: settingViewModel, router: router)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .home:
                    HomeView()
                case .script:
                    ScriptView(router: router, settingViewModel: settingViewModel)
                case .result:
                    ResultView(router: router, settingViewModel: settingViewModel)
                }
            }
            .task {
                homeViewModel.resetSelect()
            }
            .onChange(of: parser.slides.last) {
                selectKeynote()
            }
            
        }
      
    }
    
    //MARK: - VIEW
    private var recentKeynoteView: some View {
        HStack {
            VStack {
                Text("저장된 목록")
                Button(action: {
                    homeViewModel.resetSelect()
                }, label: {
                    Text("RESET")
                })
            }
            Spacer()
            List {
                ForEach(keynotes, id: \.self) { item in
                    Button {
                        parser.isLoading = false
                        homeViewModel.currentKeynote = item
                    } label: {
                        HStack {
                            Text("제목: \(item.title)")
                            Text("슬라이드: \(item.keynote.count)장")
                        }
                    }
                }
                .onDelete(perform: deleteKeynote)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("파일 처리 중 ...")
                .font(.headline)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var SelectView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .foregroundStyle(Color.gray)
            
            Text("PPTX와 PDF 파일을 업로드하세요")
                .font(.headline)
                .foregroundStyle(Color.gray)
            
            VStack(spacing: 12) {
                if let pptxURL = homeViewModel.selectedPPTXURL {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                        
                        Text("PPTX: \(pptxURL.lastPathComponent)")
                            .font(.caption)
                    }
                }
                
                if let pdfURL = homeViewModel.selectedPDFURL {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                        
                        Text("PDF: \(pdfURL.lastPathComponent)")
                            .font(.caption)
                    }
                }
            }
            
            Button {
                homeViewModel.openPicker()
                print("오픈 피커")
            } label: {
                Text("파일 선택")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            if let pptx = homeViewModel.selectedPPTXURL, let pdf = homeViewModel.selectedPDFURL {
                VStack(spacing: 10) {
                    TextField(text: $homeViewModel.keynoteTitle, label: {
                        Circle()
                            .foregroundStyle(Color.blue)
                    })
                    
                    Button {
                        parser.parseFiles(pptxURL: pptx, pdfURL: pdf)
                    } label: {
                        Text("처리 시작")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    private var PresentButtonView: some View {
        VStack(spacing: 20) {
            Text(homeViewModel.currentKeynote?.title ?? "제목없음")
            
            Button {
                router.push(.script)
            } label: {
                Text("발표로 넘어가기")
            }
        }
        .padding(.vertical, 36)
    }
    
    
    
    //MARK: - FUNCTION
    private func addKeynote(keynote: [SlideData]) {
        let keynoteData = HomeModel(title: homeViewModel.keynoteTitle, keynote: keynote)
        context.insert(keynoteData)
        try? context.save()
        homeViewModel.keynoteTitle = ""
    }
    
    private func deleteKeynote(at offsets: IndexSet) {
        for index in offsets {
            context.delete(keynotes[index])
        }
        try? context.save()
    }
    
    private func selectKeynote() {
        homeViewModel.currentKeynote = HomeModel(title: homeViewModel.keynoteTitle, keynote: parser.slides)
        if let currentKeynoteSlider = homeViewModel.currentKeynote?.keynote {
            addKeynote(keynote: currentKeynoteSlider)
            parser.isLoading = false
        }
    }
}

#Preview {
    HomeView()
}
