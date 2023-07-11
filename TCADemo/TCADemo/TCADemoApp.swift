//
//  TCADemoApp.swift
//  TCADemo
//
//  Created by LBX-CL on 2023/4/10.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCADemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GameView(store: Store(initialState: GameState(), reducer: gameReducer, environment: GameEnvironment.live))
            }  
        }
    }
}
