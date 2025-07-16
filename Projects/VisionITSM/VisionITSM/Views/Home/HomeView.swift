//
//  HomeView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI
import RealityKitContent
import _RealityKit_SwiftUI

struct HomeView: View {
    //MARK: - PROPERTIES
    let columns = Array(repeating: GridItem(.adaptive(minimum: 256), spacing: 48), count: 1)
    let texts: [String] = ["AAA", "BBB", "CCC", "DDD", "EEE", "FFF"]
    
    @State private var router = NavigationRouter()
    @State private var settingViewModel: SettingViewModel = .init()
    @State private var parser = HybridPPTXParser()
 
    @State private var isShowing: Bool = false
    @State private var pptxURL: URL?
    @State private var pdfURL: URL?
    
    //MARK: - BODY
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 48) {
                    ForEach(texts, id: \.self) { text in
                        GridItemView()
                    }
                }

            }
            .sheet(isPresented: $isShowing) {
                MultipleDocumentPicker(selectedPPTXURL: $pptxURL, selectedPDFURL: $pdfURL, isPresented: $isShowing)
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
            
        }
        
    }
}

#Preview {
    HomeView()
}
