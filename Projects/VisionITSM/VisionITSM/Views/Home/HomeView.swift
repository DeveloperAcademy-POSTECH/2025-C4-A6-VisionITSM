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
    
    @Bindable var homeViewModel: HomeViewModel
    
    @State private var router = NavigationRouter()
    @State private var parser = HybridPPTXParser()
    
    @State var settingViewModel: SettingViewModel = .init()
    
    @State private var parsingSheet: Bool = false
    @State private var isModal: Bool = false
    
    @Environment(\.modelContext) private var context
    @Query(sort: \HomeModel.createAt, order: .reverse) private var keynotes: [HomeModel]
    
    //MARK: - BODY
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                GridListView
            }
            .sheet(isPresented: $homeViewModel.showingFilePicker) {
                MultipleDocumentPicker(selectedPPTXURL: $homeViewModel.selectedPPTXURL, selectedPDFURL: $homeViewModel.selectedPDFURL, isPresented: $homeViewModel.showingFilePicker, isNext: $homeViewModel.showingParsing)
            }
            .sheet(isPresented: $homeViewModel.showingParsing) {
                parsingModalView
            }
            .sheet(isPresented: $settingViewModel.isShowSetting) {
                SettingView(settingViewModel: settingViewModel, router: router)
            }
            .sheet(isPresented: $isModal, content: {
                ModalView
            })
            .navigationTitle("Recents")
            .padding(.horizontal, 40)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isModal.toggle()
                        print("더 보기")
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonBorderShape(.circle)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .home:
                    HomeView(homeViewModel: homeViewModel)
                case .script:
                    ScriptView(router: router, homeViewModel: homeViewModel, settingViewModel: settingViewModel, keynote: homeViewModel.currentKeynote ?? HomeModel(title: "오류", keynote: []))
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
    private var GridListView: some View {
        LazyVGrid(columns: columns, spacing: 48) {
            Button(action: {
                print("추가 버튼 클릭")
                homeViewModel.openPicker()
                
            }, label: {
                GridItemView(title: "Add New File", date: "Supports .pptx, .pdf", image: .gridNewButton)
            })
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .buttonStyle(.plain)
            
            ForEach(keynotes, id: \.self) { keynote in
                Button {
                    print(keynote.title)
                    settingViewModel.isShowSetting.toggle()
                    homeViewModel.currentKeynote = keynote
                } label: {
                    GridItemView(title: keynote.title, date: keynote.createAt.toStringFormat(), image: keynote.keynote.first?.slideImage)
                }
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .buttonStyle(.plain)
            }
        }
    }
    
    private var parsingModalView: some View {
        VStack {
            if parser.isLoading {
                loadingView
            } else if homeViewModel.currentKeynote == nil {
                SelectView
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
                    TextField("Title: ", text: $homeViewModel.keynoteTitle)
                        .font(.title)
                        .padding(.horizontal, 36)
                    
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
        .padding(.vertical, 12)
    }
    
    private var ModalView: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    isModal = false
                }, label: {
                    Image(systemName: "xmark")
                })
                Spacer()
                Text("삭제할 키노트를 슬라이드 해주세요.")
                    .font(.title)
                Spacer()
            }
            .padding(.horizontal, 16)
            List  {
                ForEach(keynotes, id: \.self) { item in
                    HStack {
                        Text("제목: \(item.title)")
                    }
                }
                .onDelete(perform: deleteKeynote)
            }
        }
        .padding(.vertical, 16)
    }
    
    
    //MARK: - FUNCTION
    private func addKeynote(keynote: [SlideData]) {
        let keynoteData = HomeModel(title: homeViewModel.keynoteTitle, keynote: keynote)
        context.insert(keynoteData)
        try? context.save()
        homeViewModel.showingParsing = false
        homeViewModel.keynoteTitle = ""
        homeViewModel.resetSelect()
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
    HomeView(homeViewModel: .init())
}
