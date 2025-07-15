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
    
    @State private var isModal: Bool = false
    
    let texts: [String] = ["AAA", "BBB", "CCC", "DDD", "EEE", "FFF"]
 
    //MARK: - BODY
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 48) {
                    ForEach(texts, id: \.self) { text in
                        GridItemView()
                    }
                }

            }
            .navigationTitle("Recents")
            .padding(.horizontal, 40)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isModal.toggle()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .sheet(isPresented: $isModal) {
                SettingView()
            }
        }
    }
}

#Preview {
    HomeView()
}
