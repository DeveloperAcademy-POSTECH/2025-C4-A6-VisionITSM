//
//  ContentView.swift
//  VisionITSM
//
//  Created by 선애 on 7/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
//        VStack {
//            Model3D(named: "Scene", bundle: realityKitContentBundle)
//                .padding(.bottom, 50)
//
//            Text("Hello, world!")
//
//            ToggleImmersiveSpaceButton()
//        }
//        .padding()
        ResultView()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
