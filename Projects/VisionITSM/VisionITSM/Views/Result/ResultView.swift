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
    @Bindable var settingViewModel: SettingViewModel
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    resultItemView(title: "Audience Size", result: settingViewModel.settingModel.audienceSize)
                    resultItemView(title: "Dustraction Level", result: settingViewModel.settingModel.distractionLevel)
                    
                    resultTimeItemView(title: "Time Spent", result: "\(settingViewModel.counter.asTimeHMS)")
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 44)
        .padding(.vertical, 20)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Result")
                    .font(.largeTitle)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Finish!")
                    router.reset()
                }) {
                    Image(systemName: "checkmark")
                }
                .buttonBorderShape(.circle)
            }
        }
    }
    
    func resultTimeItemView(title: String, result: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(.largeTitle)
            Text(result)
                .font(.title2)
        }
    }
    
    func resultItemView(title: String, result: Float) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(.largeTitle)
            Text(checkLevel(result: result))
                .font(.title2)
        }
    }
    
    func checkLevel(result: Float) -> String {
        if result == 0 {
            return "Easy"
        } else if result == 1.0 {
             return "Medium"
        } else {
            return "Hard"
        }
    }
}

#Preview {
    ResultView(router: .init(), settingViewModel: .init())
}
