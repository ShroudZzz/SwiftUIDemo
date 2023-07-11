//
//  ContentView.swift
//  TCADemo
//
//  Created by LBX-CL on 2023/4/10.
//

import SwiftUI
import ComposableArchitecture

struct Counter: Equatable, Identifiable {
    var count: Int = 0
    var secret = Int.random(in: -100...100)
    
    var id: UUID = UUID()
}

extension Counter {
    var countString: String {
        get {
            String(count)
        }
        
        set {
            count = Int(newValue) ?? count
        }
    }
    
    enum CheckResult {
        case lower, equal, higher
    }
    
    var checkResult: CheckResult {
        if count < secret { return .lower }
        if count > secret { return .higher }
        return .equal
    }
}

enum CounterAction {
    case increment
    case decrement
    case setCount(String)
    case playNext
}

//CounterEnvironment 让我们有机会为 reducer 提供自定义的运行环境，用来注入一些依赖
struct CounterEnvironment {
    var generateRandom: (ClosedRange<Int>) -> Int
    var uuid: () -> UUID
    
    static let live = CounterEnvironment(
        generateRandom: Int.random,
        uuid: UUID.init
    )
}

//Reducer 是函数式编程中的常见概念，顾名思意，它将多项内容进行合并，最后返回单个结果
let counterReducer = AnyReducer<Counter, CounterAction, CounterEnvironment> { state, action, environment in
    switch action {
    case .increment:
        state.count += 1
        return .none
    case .decrement:
        state.count -= 1
        return .none
    case .setCount(let text):
        state.countString = text
        return .none
    case .playNext:
        state.count = 0
        state.secret = environment.generateRandom(-100...100)
        return .none
    }
}

struct CounterView: View {
    //这个 Store 负责把 Counter (State) 和 Action 连接起来。
    let store: Store<Counter, CounterAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                checkLabel(with: viewStore.checkResult)
                HStack {
                    Button("_") { viewStore.send(.decrement) }
                    //Text("\(viewStore.count)")
                    TextField(String(viewStore.count),text: viewStore.binding(get: \.countString, send: CounterAction.setCount))
                        .frame(width: 40)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                    Button("+") { viewStore.send(.increment) }
                }
                Button("Next") { viewStore.send(.playNext) }
            }
        }
    }
    
    func checkLabel(with checkResult: Counter.CheckResult) -> some View {
        switch checkResult {
        case .lower:
            return Label("Lower", systemImage: "lessthan.circle").foregroundColor(.red)
        case .higher:
            return Label("Higher", systemImage: "greaterthan.circle").foregroundColor(.red)
        case .equal:
            return Label("Correct", systemImage: "checkmark.circle").foregroundColor(.green)
        }
    }
}


struct Counter_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: Store(initialState: Counter(), reducer: counterReducer, environment: .live))
    }
}
