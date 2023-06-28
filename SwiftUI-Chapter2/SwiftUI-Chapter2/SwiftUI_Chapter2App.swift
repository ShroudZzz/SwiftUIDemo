//
//  SwiftUI_Chapter2App.swift
//  SwiftUI-Chapter2
//
//  Created by LBX-CL on 2023/6/25.
//

import SwiftUI

@main
struct SwiftUI_Chapter2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(CalculatorModel())
        }
    }
}
