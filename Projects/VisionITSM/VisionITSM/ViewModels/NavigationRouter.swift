//
//  NavigationRouter.swift
//  VisionITSM
//
//  Created by 진아현 on 7/15/25.
//

import SwiftUI
import Observation

@Observable
class NavigationRouter {
    var path = NavigationPath()
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func reset() {
        path = NavigationPath()
    }
}
