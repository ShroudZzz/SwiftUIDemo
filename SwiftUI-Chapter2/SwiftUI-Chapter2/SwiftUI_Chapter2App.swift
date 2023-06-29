import SwiftUI

@main
struct SwiftUI_Chapter2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(CalculatorModel())
        }
    }
}
