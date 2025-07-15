//
//  SettingView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI

struct SettingView: View {
    //MARK: - PROPERTIES
    @State private var environment: String = "NURL"
    @State private var audienceSize: Float = 0.0
    @State private var distractionLevel: Float = 0.0
    
    @Bindable var router: NavigationRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    
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
                        Text("Main 3")
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
                            value: $audienceSize,
                            in: 0...4,
                            step: 1
                        ) {
                            Text("\(audienceSize)")
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
                            value: $distractionLevel,
                            in: 0...4,
                            step: 1
                        ) {
                            Text("\(distractionLevel)")
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
    SettingView(router: .init())
}
