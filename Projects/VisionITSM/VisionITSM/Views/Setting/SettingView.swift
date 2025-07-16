//
//  SettingView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI

struct SettingView: View {
    //MARK: - PROPERTIES
//    @State private var environment: String = "NURL"
//    @State private var audienceSize: Float = 0.0
//    @State private var distractionLevel: Float = 0.0
    @Bindable var settingViewModel: SettingViewModel
    
    @Bindable var router: NavigationRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    //MARK: - 이머시브존1
//    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    //MARK: - BODY
    var body: some View {
        VStack {
            ZStack {
                Text("Title")
                    .font(.largeTitle)
                HStack {
                    Button(action: {
                        print("뒤로가기")
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    Spacer()
                    
                }
                .padding(.leading, 24)
            }
            .frame(height: 92)
            
            
            VStack(alignment: .center, spacing: 24) {
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 36, height: 36)
                    VStack(alignment: .leading) {
                        Text("Environments")
                        Text(settingViewModel.settingModel.background.title)
                    }
                    
                    Spacer()
                    
                    Button {
                        print("배경선택")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 8)
                }
                
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Audience Size")
                    
                    ZStack(alignment: .center) {
                        Slider(
                            value: $settingViewModel.settingModel.audienceSize,
                            in: 0...2,
                            step: 1
                        ) {
                            Text("\(settingViewModel.settingModel.audienceSize)")
                        }
                        .frame(width: 288, height: 64)
                        
                        HStack {
                            Image(systemName: "person.fill")
                            Spacer()
                            Image(systemName: "person.3.fill")
                                .offset(x: 10)
                        }
                        .padding(.horizontal, 66)
                    }
                    
                    
                    Text("Audience SizeAudience SizeAudience SizeAudience SizeAudience SizeAudience SizeAudience Size")
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Audience Size")
                    
                    ZStack(alignment: .center) {
                        Slider(
                            value: $settingViewModel.settingModel.distractionLevel,
                            in: 0...2,
                            step: 1
                        ) {
                            Text("\(settingViewModel.settingModel.distractionLevel)")
                        }
                        .frame(width: 288, height: 64)
                        
                        HStack {
                            Image(systemName: "leaf.fill")
                            Spacer()
                            Image(systemName: "flame.fill")
                            
                        }
                        .padding(.horizontal, 66)
                    }
                    
                    Text("Audience SizeAudience SizeAudience SizeAudience SizeAudience SizeAudience SizeAudience Size")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 13))
                }
                
                Button {
                    dismiss()
                    router.push(.script)
                    openWindow(id: "slideWindow")
                    
                    //MARK: - 이머시브존2
                    /*
                    Task {
                        let result = await openImmersiveSpace(id: "ImmersiveSpace")
                        switch result {
                        case .opened:
                            print("Immersive space opened")
                        case .userCancelled, .error:
                            print("Failed to open immersive space")
                        @unknown default:
                            break
                        }
                    }*/
                } label: {
                    Label {
                        Text("Enter Session")
                    } icon: {
                        Image(systemName: "door.right.hand.open")
                    }
                    
                }
            }
            .padding(.horizontal, 44)
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    SettingView(settingViewModel: .init(), router: .init())
}
