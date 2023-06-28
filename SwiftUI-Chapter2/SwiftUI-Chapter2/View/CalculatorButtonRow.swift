import SwiftUI
struct CalculatorButtonRow: View {
    let row: [CalculatorButtonItem]
    //@Binding var brain: CalculatorBrain
    //var model: CalculatorModel
    @EnvironmentObject var model: CalculatorModel
    var body: some View {
        HStack {
            ForEach(row, id: \.self) { item in
                CalculatorButton(title: item.title, size: item.size) {
                    model.apply(item)
                }
            }
        }
    }
}
