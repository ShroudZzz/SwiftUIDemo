import SwiftUI

struct HistoryView: View {
    @ObservedObject var model: CalculatorModel
    
    var body: some View {
        VStack {
            if model.totalCount == 0 {
                Text("None op")
            } else {
                HStack {
                    Text("Op").font(.headline)
                    Text("\(model.historyDetail)").lineLimit(nil)
                }
                
                HStack {
                    Text("Display").font(.headline)
                    Text("\(model.brain.output)")
                }
                
                Slider(value: $model.slidingIndex, in: 0...Float(model.totalCount),step: 1)
            }
        }.padding()
    }
}
