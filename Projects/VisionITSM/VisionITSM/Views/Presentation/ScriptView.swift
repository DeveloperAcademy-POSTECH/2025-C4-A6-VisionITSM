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
    
    @State private var isCounting: Bool = false
    @State private var isPop: Bool = false
    
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var settingViewModel: SettingViewModel
    @Bindable var keynote: HomeModel
    
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    
    //MARK: - BODY
    var body: some View {
        VStack {
            slideButtonView
            
            Spacer()
            
            PresentNoteView
        }
        .popover(isPresented: $isPop, attachmentAnchor: .point(.topTrailing), arrowEdge: .bottom , content: {
            HStack(content: {
                Button(action: {
                    isPop = false
                }, label: {
                    Image(systemName: "xmark")
                })
                Button(action: {
                    isPop = false
                    isCounting = false
                    settingViewModel.counter = 0
                    homeViewModel.currentIndex = 0
                    dismissWindow(id: "slideWindow")
                    openWindow(id: "slideWindow")
                    
                }, label: {
                    Image(systemName: "return")
                })
            })
            .frame(width: 180, height: 80)
        })
        .task {
            settingViewModel.counter = 0
            homeViewModel.currentIndex = 0
        }
        .ornament(attachmentAnchor: .scene(UnitPoint(x: 0.5, y: -0.08)), contentAlignment: .top) {
            TimerView(isPlaying: $isCounting, settingViewModel: settingViewModel, router: router)
        }
        .safeAreaPadding([.top, .horizontal], 24)
        .safeAreaInset(edge: .top, content: {
            topStatus
        })
        .navigationBarBackButtonHidden(true)
    }
    
    //MARK: - TOP
    private var topStatus: some View {
        ZStack {
            topTitle
            topButton
        }
    }
    
    private var topTitle: some View {
        Text("Presenter Mode")
            .font(.largeTitle)
            .frame(maxWidth: .infinity)
            .frame(height: 92)
    }
    
    private var topButton: some View {
        HStack {
            Button(action: {
                router.pop()
            }, label: {
                Image(systemName: "chevron.left")
            })
            Spacer()
            Button(action: {
                print("더 보기")
                isPop.toggle()
            }, label: {
                Image(systemName: "ellipsis")
            })
        }
        .safeAreaPadding(.horizontal, 24)
        .buttonBorderShape(.circle)
        .foregroundStyle(Color.secondary)
    }
    
    //MARK: - MIDDLE
    private var slideButtonView: some View {
        HStack(spacing: 36) {
            Button(action: {
                homeViewModel.currentIndex -= (homeViewModel.currentIndex == 0) ? 0 : 1
            }, label: {
                VStack(alignment: .center, spacing: 8) {
                    Text("Current Page")
                    Image(uiImage: imageProcessing(keynote: homeViewModel.currentKeynote ?? .init(title: "오류", keynote: []), isLeft: true))
                        .resizable()
                        .frame(width: 256, height: 138)
                    Text(getIndex(currentIndex: homeViewModel.currentIndex, maxIndex: keynote.keynote.count - 1, isLeft: true))
                }
            })
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: {
                homeViewModel.currentIndex += (homeViewModel.currentIndex == keynote.keynote.count - 1) ? 0 : 1
            }, label: {
                VStack(alignment: .center, spacing: 8) {
                    Text("Next Page")
                    Image(uiImage: imageProcessing(keynote: homeViewModel.currentKeynote ?? .init(title: "오류", keynote: []), isLeft: false))
                        .resizable()
                        .frame(width: 256, height: 138)
                    Text(getIndex(currentIndex: homeViewModel.currentIndex, maxIndex: keynote.keynote.count - 1, isLeft: false))
                }
            })
            .buttonBorderShape(.roundedRectangle(radius: 12))
            .buttonStyle(.plain)
        }
        .frame(width: 920)
        .safeAreaPadding(.horizontal, 58)
    }
    
    private var PresentNoteView: some View {
        ScrollView() {
            if !(homeViewModel.currentKeynote?.keynote.isEmpty ?? .init()) {
                Text(homeViewModel.currentKeynote?.keynote[homeViewModel.currentIndex].presenterNotes ?? "No Memo")
            }
        }
    }
    
    func getIndex(currentIndex: Int, maxIndex: Int, isLeft: Bool) -> String {
        if isLeft {
            return "Slide \(currentIndex + 1)"
        } else if currentIndex == maxIndex {
            return "Slide End"
        } else {
            return "Slide \(currentIndex + 2)"
        }
    }
    
    func imageProcessing(keynote: HomeModel, isLeft: Bool) -> UIImage {
        if isLeft {
            return keynote.keynote.count == 0 ? .gridNewButton : keynote.keynote[homeViewModel.currentIndex].slideImage ?? .gridNewButton
        } else {
            if homeViewModel.currentIndex == keynote.keynote.count - 1 {
                return .gridNewButton
            } else {
                return keynote.keynote.count == 0 ? .gridNewButton : keynote.keynote[homeViewModel.currentIndex + 1].slideImage ?? .gridNewButton
            }
        }
    }
}

#Preview {
    ScriptView(router: .init(), homeViewModel: .init(), settingViewModel: .init(), keynote: .init(title: "QQQ", keynote: []))
}
