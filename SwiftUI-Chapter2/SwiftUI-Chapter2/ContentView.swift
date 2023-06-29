import SwiftUI

struct ContentView: View {
    
    @State private var editingHistory = false
    
    /*
     @State属性值仅只能在属性本身被设置时会触发UI刷新，这个特性让它非常适合用来声明一个值类型的值，因为对值类型的属性的变更，也会触发整个值的重新设置，进而刷新UI。不过，在把这样的值在不同对象间传递时，状态值将会遵守值语义发生复制，所以即便将@State层层传递，每一层都是不同的值
     @Binding 就是用来解决这个问题，和 @State 类似，@Binding 也是对属性的修 饰，它做的事情是将值语义的属性 “转换” 为引用语义
     */
    //@State private var brain: CalculatorBrain = .left("0")
    
    //@ObservedObject var model = CalculatorModel()
    /**
     View 提供了 environmentObject(_:) 方法，来 把某个 ObservableObject 的值注入到当前 View 层级及其子层级中去。在这个 View 的子层级中，可以使用 @EnvironmentObject 来直接获取这个绑定的环境值
     */
    @EnvironmentObject var model: CalculatorModel
    
    /**
     @State 和 @Binding 提供 View 内部 的状态存储，它们应该是被标记为 private 的简单值类型，仅在内部使用
     
     
     ObservableObject 和 @ObservedObject 则针对跨越 View 层级的状态共享，它可以 处理更复杂的数据类型，其引用类型的特点，也让我们需要在数据变化时通过某种手 段向外发送通知 (比如手动调用 objectWillChange.send() 或者使用 @Published)， 来触发界面刷新
     
     对于多个层级的 View 层级的状态，@EnvironmentObject 能让我们更方便地使用 ObservableObject，以达到简化代码的目的
     */
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Button("Op: \(model.history.count)") {
                editingHistory = true
            }.sheet(isPresented: $editingHistory) {
                HistoryView(model: model)
            }
            
            Text(model.brain.output) //Text(brain.output)
                .font(.system(size: 76))
                .minimumScaleFactor(0.5)
                .padding(.trailing, 24)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            CalculatorButtonPad()
            //CalculatorButtonPad(model: model) //CalculatorButtonPad(brain: $brain)
                .padding(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environmentObject(CalculatorModel())
            ContentView().environmentObject(CalculatorModel()).previewDevice("iPhone SE (3rd generation)")
        }
    }
}
