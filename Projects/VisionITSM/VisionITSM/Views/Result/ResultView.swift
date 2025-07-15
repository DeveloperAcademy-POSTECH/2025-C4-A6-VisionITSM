//
//  ResultView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/15/25.
//

import SwiftUI

struct ResultView: View {
    //MARK: - PROPERTIES
    @Bindable var router: NavigationRouter
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    resultItemView(title: "Audience Size", result: "Medium")
                    resultItemView(title: "Dustraction Level", result: "Easy")
                    resultItemView(title: "Time Spent", result: "13: 02")
                }
                
                Spacer()
            }
        }
        .navigationTitle("Result")
        .padding(.horizontal, 44)
        .padding(.vertical, 20)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Finish!")
                    router.reset()
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    func resultItemView(title: String, result: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(.largeTitle)
            Text(result)
                .font(.title2)
        }
    }
}

#Preview {
    ResultView(router: .init())
}
