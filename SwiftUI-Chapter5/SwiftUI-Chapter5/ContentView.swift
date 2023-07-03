import SwiftUI
import Combine

/**
 1.Combine 中，我们使用 Publisher 协议来代表事件的发布者
 2.协议本身定义了一个 Publisher 应该具备 的能力，而它们的实现则由遵守 Publisher 协议的具体类型所提供。在 Combine 框 架中，已经有一系列框架自带的发布者类型，它们大部分被定义在了 Publishers 这个 enum 之中
 
 3.Publisher 最主要的工作其实有两个:发布新的事件及其数据，以及准备好被 Subscriber 订阅。
 
 public protocol Publisher {
 associatedtype Output
 associatedtype Failure : Error
 func receive<S>(subscriber: S) where
     S : Subscriber,
     Self.Failure !" S.Failure,
     Self.Output !" S.Input
 }

 Output 定义了某个 Publisher 所发布的值的类型，Failure 则定义可能产生的错误的 类型。随着时间的推移，事件流也会逐渐向前发展。对应 Output 及 Failure， Publisher 可以发布三种事件:
 1. 类型为 Output 的新值:这代表事件流中出现了新的值。
 2. 类型为 Failure 的错误:这代表事件流中发生了问题，事件流到此终止。 3. 完成事件:表示事件流中所有的元素都已经发布结束，事件流到此终止
 
 有限事件流: 最常见的一个例子是网络请求的相关操作:发出网络请求后，可以把每 次接收到数据的事件看作一个 output。在请求的所有数据都被返回时，整个操作正 常结束，finished 事件被发布。如果在过程中遭遇到错误，比如网络连接断开或者连 接被服务器关闭等，则发布 failure 事件。不论是 finished 或者是 failure，都表明这 次请求已经完成，将来不会有更多的 output 发生
 无限事件流:
 比如用户点击某个按钮的事件流:如果将按钮看作是事件 的发布者，每次按钮点击将发布一个不带有任何数据的 output。这种按钮操作并没 有严格意义上的完结:用户可能一次都没有点击这个按钮，也可能无限次地点击这 个按钮，不论用户如何操作，你都无法断言之后不会再发生任何按钮事件
 
 4.Subscriber
 public protocol Subscriber {
 associatedtype Input
 associatedtype Failure : Error
 func receive(subscription: Subscription)
 func receive(_ input: Self.Input) -> Subscribers.Demand
 func receive(completion: Subscribers.Completion<Self.Failure>) }

 */

class Foo {
    var bar: String = ""
}

struct Operation: View {
    let buttonClick: AnyPublisher<Void, Never>
    
    func sink() {
        //sink 可以充当一座桥梁，将响应函数式的 Publisher 链式代码，终结并桥接到基于 闭包的指令式世界中来
        buttonClick
            .scan(0) { value, _ in
            value + 1
        }.map {
            String($0)
        }.sink {
            print("Button Pressed count: \($0)")
        }
    }
    
    func assign() {
        
        let foo = Foo()
        
        buttonClick
        .scan(0) { value, _ in value + 1 }
        .map { String($0) }
        .assign(to: \.bar, on: foo)

    }
    
    
    var body: some View {
        VStack{}
    }
}

/**
 5. Subject 本身也是一个 Publisher
 public protocol Subject : AnyObject, Publisher {
 func send(_ value: Self.Output)
 func send(completion: Subscribers.Completion<Self.Failure>)
 }

 Subject 暴露了两个 send 方法，外部调用者可以通过这两个方法 来主动地发布 output 值、failure 事件或 finished 事件
 
 
 Combine 内置提供了两种常用的 Subject 类型，分别是 PassthroughSubject 和 CurrentValueSubject
 */

struct Subject: View {
    
    //PassthroughSubject 简单地将 send 接收到的事件转发给 下游的其他 Publisher 或 Subscriber:
    func pt_subject() {
        let publish1 = PassthroughSubject<Int, Never>()
        print("开始订阅")
        publish1.sink { completion in
            print(completion)
        } receiveValue: { value in
            print(value)
        }

        publish1.send(1)
        publish1.send(2)
        publish1.send(completion: .finished)
        
        //开始订阅
        //1
        //2
        //finished
                
    }
    
    //CurrentValueSubject 则会包装和持有一个值，并在 设置该值时发送事件并保留新的值。在订阅发生的瞬间，CurrentValueSubject 会把 当前保存的值发送给订阅者
    
    func cv_subject() {
        let publisher3 = CurrentValueSubject<Int, Never>(0)
        print("开始订阅")
        publisher3.sink(
            receiveCompletion: { complete in print(complete)
            },
            receiveValue: { value in
                print(value)
            }
        )
        publisher3.value = 1
        publisher3.value = 2
        publisher3.send(completion: .finished)
        
        //开始订阅
        //0
        //1
        //2
        //finished
    }
    
    var body: some View {
        VStack{}
    }
}

/**
 6.Scheduler
 Scheduler 所要解决的就 是两个问题:在什么地方 (where)，以及在什么时候 (when) 来发布事件和执行代码
 
 where
 对于后台线程的网络请求返回，可以通过这样的方式在 main runloop 中进行处理:
 URLSession.shared
   .dataTaskPublisher(for: URL(string: "https:!"example.com")!)
   .compactMap { String(data: $0.data, encoding: .utf8) }
   .receive(on: RunLoop.main)
   .sink(receiveCompletion: { _ in
   }, receiveValue: {
     textView.text = $0
 })
 RunLoop 就是一个实现了 Scheduler 协议的类型，它知道要如何执行后续的订阅任务
 
 when
 Scheduler 的另一个重要工作是为事件的发布指定和规划时间
 两种操作是 delay 和 debounce。delay 简单地将所有事件按照一定事件 延后。debounce 则是设置了一个计时器，在事件第一次到来时，计时器启动。在计 时器有效期间，每次接收到新值，则将计时器时间重置。当且仅当计时窗口中没有新的值到来时，最后一次事件的值才会被当作新的事件发送出去
 */

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
