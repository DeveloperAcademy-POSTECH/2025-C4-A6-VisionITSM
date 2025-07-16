//
//  ScriptView.swift
//  VisionITSM
//
//  Created by 진아현 on 7/14/25.
//

import SwiftUI

struct ScriptView: View {
    //MARK: - PROPERTIES
    @Bindable var router: NavigationRouter
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var isCounting: Bool = false
    
    //MARK: - BODY
    var body: some View {
        VStack(spacing: 36) {
            HStack(spacing: 36) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Current Page")
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 256, height: 138)
                    Text("Slide 7")
                }
                
                VStack(alignment: .center, spacing: 8) {
                    Text("Current Page")
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 256, height: 138)
                    Text("Slide 7")
                }
            }
            
            Text("asdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxvasdczdvczvzxvfzxv")
                .multilineTextAlignment(.leading)
        }
        .navigationTitle("Presenter Mode")
        .navigationBarTitleDisplayMode(.automatic)
        .frame(width: 415, height: 713)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("더 보기")
                    router.push(.result)
                    dismissWindow(id: "slideWindow")
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .ornament(attachmentAnchor: .scene(UnitPoint(x: 0.5, y: -0.07)), contentAlignment: .top) {
            VStack {
                Button {
                    isCounting.toggle()
                } label: {
                    ZStack {
                        HStack(spacing: 6) {
                            Image(systemName: isCounting ? "stop.fill" : "play.fill")
                            Text(isCounting ? "0:0" : "Start")
                        }
                        .foregroundStyle(isCounting ? Color.red : Color.white)
                    }
                }
                .tint(isCounting ? nil : Color.red)
            }
//            .offset(y: -30)
        }
    }
}

#Preview {
    ScriptView(router: .init())
}
