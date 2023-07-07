import Combine
import Foundation

struct BasePublisher {
    @discardableResult
    public func check<P: Publisher>(_ title: String, publisher: () -> P) -> AnyCancellable {
        print("----- \(title) -----")
        defer { print("") }
        return publisher()
            .print()
            .sink(
                receiveCompletion: { _ in},
                receiveValue: { _ in }
            )
    }
    
    public func Base_Just() {
        check("Just") {
            Just(1)
        }
    }
    
    public func Base_Map() {
        check("map") {
            [1,2,3].publisher.map{ $0 * 2 }
        }
        
        check("Map Just") {
            Just(5).map{ $0 * 2 }
        }
    }
    
    public func Base_Reduce() {
        check("Reduce") {
            [1,2,3,4,5].publisher.reduce(0,+)
        }
        
        check("Scan") {
            [1,2,3,4,5].publisher.scan(0, +)
        }
    }
    
    //compactMap 比较简单，它的作用是将 map 结果中那些 nil 的元素去除掉
    public func Base_CompactMap() {
        check("Compact Map") {
            ["1", "2", "3", "cat", "5"]
                .publisher
                .compactMap { Int($0) }
        }
    }
    
    public func Base_FlatMap() {
        //res: 1 2 3 a b c
        check("FlatMap 1") {
            [[1,2,3] as [Any], ["a","b","c"]].publisher
                .flatMap{ $0.publisher }
        }
        
        //res: A1 A2 A3 B1 B2 B3 C1 C2 C3
        check("Flat Map 2") {
            ["A", "B", "C"].publisher.flatMap { letter in
                [1,2,3].publisher.map{"\(letter)\($0)"}
            }
        }
        
    }
    
    public func Base_RemoveDuplicates() {
        check("Remove Duplicates") {
            ["S", "Sw", "Sw", "Sw", "Swi",
             "Swif", "Swift", "Swift", "Swif"]
                .publisher
                .removeDuplicates()
        }
    }
    
    //https://developer.apple.com/documentation/combine/publisher
    
    public enum SampleError: Error {
        case sampleError
    }
    
    public enum MyError: Error {
        case None
    }
    
    public func Base_Fail() {
        check("Fail") {
            Fail<Int, SampleError>(error: .sampleError)
        }
        
        check("Map Error") {
            Fail<Int, SampleError>(error: .sampleError).map { rawValue in
                MyError.None
            }
        }
    }
    
    public func Base_TryMap() {
        check("Throw") {
            ["1","2","Swift","4"].publisher
                .tryMap { s in
                    guard let value = Int(s) else {
                        throw MyError.None
                    }
                    return value
                }
        }
    }
    
    //当错误发生后，原本的 Publisher 事件流将被中断
    //res 1 2 -1 finished
    public func Base_ReplaceError() {
        check("Replace Error") {
            ["1", "2", "Swift", "4"].publisher
                .tryMap { s in
                    guard let value = Int(s) else {
                        throw MyError.None
                    }
                    return value
                }
                .replaceError(with: -1)
        }
    }
    
    //res 1 2 -1 finished
    public func Base_Catch() {
        check("Catch") {
            ["1", "2", "Swift", "4"].publisher
                .tryMap { s in
                    guard let value = Int(s) else {
                        throw MyError.None
                    }
                    return value
                }
                .catch { _ in
                    Just(-1)
                }
        }
    }
    
    //res: 1 2 -1 4
    public func Base_CatchContine() {
        check("Catch and Continue") {
            ["1", "2", "Swift", "4"].publisher
                .flatMap { s in
                    return Just(s).tryMap { s in
                        guard let value = Int(s) else {
                            throw MyError.None
                        }
                        return value
                    }
                    .catch{_ in Just(-1)}
                }
        }
    }
    
    /**
     Combine 提 供了 eraseToAnyPublisher 来帮助我们对复杂类型的 Publisher 进行类型抹消，这 个方法返回一个 AnyPublisher:
     let p3 = p2.eraseToAnyPublisher()
     */
}
// Chapter7
//使用 Subject 将指令式的 操作转换到响应式的世界中
extension BasePublisher {
    //Subject 提供了自由控制 Publisher 行为的机会
    public func Subject_1() {
        check("Sublect") { () -> PassthroughSubject<Int, Never> in
            let subject = PassthroughSubject<Int,Never>()
            subject.send(1)
            subject.send(completion: .finished)
            return subject
        }
    }
    
    public func SubjectMerge() {
        let subject_example1 = PassthroughSubject<Int, Never>()
        let subject_example2 = PassthroughSubject<Int, Never>()
        
        check("Subject Order") {
            subject_example1.merge(with: subject_example2)
        }
        
        subject_example1.send(20)
        subject_example2.send(1)
        subject_example1.send(40)
        subject_example1.send(60)
        subject_example2.send(1)
        subject_example1.send(80)
        subject_example1.send(100)
        subject_example1.send(completion: .finished)
        subject_example2.send(completion: .finished)
        
        //res: 20 1 40 60 1 80 100
    }
    
    //Publisher 中的 zip 和 Sequence 的 zip 相类似:它会把两个 (或多个) Publisher 事 件序列中在同一 index 位置上的值进行合并，也就是说，Publisher1 中的第一个事 件和 Publisher2 中的第一个事件结对合并，Publisher1 中的第二个事件和 Publisher2 中的第二个事件合并
    
    public func SubjectZip() {
        let subject1 = PassthroughSubject<Int, Never>()
        let subject2 = PassthroughSubject<String, Never>()
        
        check("Zip") {
            subject1.zip(subject2)
        }
        
        subject1.send(1)
        subject2.send("A")
        subject1.send(2)
        subject2.send("B")
        subject2.send("C")
        subject2.send("D")
        subject1.send(3)
        subject1.send(4)
        subject1.send(5)
        //res: 1,A : 2,b : 3,C : 4,D
    }
    
    public func SubjectCombineLatest() {
        let subject3 = PassthroughSubject<String, Never>()
        let subject4 = PassthroughSubject<String, Never>()
        check("Combine Latest") {
            subject3.combineLatest(subject4)
        }
        
        subject3.send("1")
        subject4.send("A")
        subject3.send("2")
        subject4.send("B")
        subject4.send("C")
        subject4.send("D")
        subject3.send("3")
        subject3.send("4")
        subject3.send("5")
        
        //res: 1A : 2A : 2B : 2C : 2D : 3D : 4D: 5D
    }
    
    struct Response:Decodable {
        let args: String?
    }
    
    // dataTaskPublisher(for:) 方法可以直接返回一个 Publisher，它会在 网络请求成功时发布一个值为 (Response, Data) 的事件，请求过程失败时，发送类 型为 URLError 的错误
    public func URLSession() {
        check("URL Session") {
            Foundation.URLSession.shared
                .dataTaskPublisher(for: URL(string: "")!)
                .map { data, _  in
                    data
                }
                .decode(type: Response.self, decoder: JSONDecoder())
                .compactMap{ $0.args }
        }
    }
    
    /**
     对 于 普 通 的Publisher， 当Failure是Never时， 就 可 以 使 用 makeConnectable() 将它包装为一个 ConnectablePublisher。这会使得该 Publisher 在等到连接 (调用 connect()) 后才开始执行和发布事件。在某些
     情况下，如果我们希望延迟及控制 Publisher 的开始时间，可以使用这个方 法。
     对 ConnectablePublisher 的 对 象 施 加 autoconnect() 的 话， 可 以 让 这 个 ConnectablePublisher “恢复” 为被订阅时自动连接。
     */
    public func Timer() {
        check("Timer") {
            Foundation.Timer.publish(every: 1, on: .main, in: .default)
        }
        
        let timer = Foundation.Timer.publish(every: 1, on: .main, in: .default)
        check("Timer Connected") {
            timer
        }
        ///Timer.TimerPublisher 是一个满足 ConnectablePublisher 的类型。ConnectablePublisher 不同于普通的 Publisher， 你需要明确地调用 connect() 方法，它才会开始发送事件
        timer.connect()
        //NotificationCenter.default.publisher(for: <#T##Notification.Name#>)
    }
    
    /**
     @State 和 @ObservedObject 这样的 Property Wrapper，它们对属性值的 getter 和 setter 进行包装，来实现一些常见功能。类似 地，Combine 中存在 @Published 封装，用来把一个 class 的属性值转变为 Publisher。它同时提供了值的存储和对外的 Publisher (通过投影符号 $ 获取)。在被 订阅时，当前值也会被发送给订阅者，它的底层其实就是一个 CurrentValueSubject
     
     在 ObservableObject 的场景中，@Published 被用来自动生成对应的 Publisher 并 处理 objectWillChange 的调用
     */
    
    /**
     Combine 框架中的数据流动是由 Subscriber 主动请求的。当一个 Subscriber 订阅了一个 Publisher，Publisher 会创建一个 Subscription 并将其发送给 Subscriber。然后，Subscriber 可以调用 Subscription 的 request(_:) 方法来请求数据。

     这是一种被称为“反压”（backpressure）的机制。反压机制允许 Subscriber 控制它从 Publisher 接收数据的速度，而不是被 Publisher 的数据生成速度所驱动。这对于处理大量数据或异步操作时特别有用，因为它可以防止 Subscriber 被过多的数据淹没。

     也就是说，尽管 Subscriber 是从 Publisher 接收数据，但它实际上是通过主动请求来控制数据的流动的。

     以下是这个过程的基本步骤：

     1.Subscriber 订阅 Publisher。
     2.Publisher 创建一个 Subscription 并将其发送给 Subscriber。
     3.Subscriber 调用 Subscription.request(_:) 来请求数据。
     4.Publisher 开始通过 Subscription 向 Subscriber 发送数据。
     在整个过程中，数据的流动是由 Subscriber 的请求驱动的，而不是由 Publisher 推送的。这就是所说的主动请求，而不是被动接收。
     */
    class Wrapper {
        @Published var text: String = ""
    }
    
    public func Base_Wrapper() {
        var w = Wrapper()
        check("Published") {
            w.$text
        }
        
        w.text = "123"
        w.text = "abc"
    }
    
    /**
     通过 assign 绑定 Publisher 值
     
     Subscribers.Assign，它可以用来将 Publisher 的输出值通过 key path 绑定到一个 对象的属性上去。在 SwiftUI 中，这种值通常会是 ObservableObject 中的属性值， 它进一步会被用来驱动 View 的更新
     
     
     assign 的另一个 “限制” 是，上游 Publisher 的 Failure 的类型必须是 Never。如果 上游 Publisher 可能会发生错误，我们则必须先对它进行处理，比如使用 replaceError 或者 catch 来把错误在绑定之前就 “消化” 掉。
     */
    
    
    /**
     !!!  .share()
     多个 Subscriber 对应一个 Publisher 的情况, 共享这个 Publisher，使用 share() 将它转变为引用类型的 class
     
     */
    
    /**
     1.Cancellable，我们需要在合适的时候主动调用 cancel() 方法来完结
     2.AnyCancellable 则在自己的 deinit 中帮我们做了这件事
     
     Combine 中常见的内存资源相关的操作，可以总结几条常见的规则和实践:
    1. 对于需要 connect 的 Publisher，在 connect 后需要保存返回的 Cancellable，
    并在合适的时候调用 cancel() 以结束事件的持续发布。
    2. 对于 sink 或 assign 的返回值，一般将其存储在实例的变量中，等待属性持有 者被释放时一同自动取消。不过，你也完全可以在不需要时提前释放这个变量 或者明确地调用 cancel() 以取消绑定。
    3. 对于 1 的情况，也完全可以将 Cancellable 作为参数传递给 AnyCancellable 的初始化方法，将它包装成为一个可以自动取消的对象。这样一来，1 将被转 换为 2 的情况
     
     */
    
    class Clock {
        var timeString: String = "--:--:--" {
            didSet {
                print("\(timeString)")
            }
        }
    }
    
    public func Base_Assign() {
        let clock = Clock()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        
        let timer = Foundation.Timer.publish(every: 1, on: .main, in: .default)
        var token = timer.map { formatter.string(from: $0) }
            .assign(to: \.timeString, on: clock)
        let cancelalbel = timer.connect()
        
        //cancelalbel.cancel()
    }
    
    class LoadingUI {
        var isSuccess: Bool = false
        var text: String = ""
    }
    
    struct Responses: Decodable {
        struct Foo: Decodable {
            let foo: String
        }
        
        let args: Foo?
    }
    
    public func Base_Network() {
        let dataTaskPublisher = Foundation.URLSession.shared.dataTaskPublisher(for: URL(string: "")!).share()
        let isSuccess = dataTaskPublisher.map { data, response in
            guard let httpRes = response as? HTTPURLResponse else {
                return false
            }
            
            return httpRes.statusCode == 200
        }.replaceError(with: false)
        
        let latestText = dataTaskPublisher
            .map { data, _ in data }
            .decode(type: Responses.self, decoder: JSONDecoder())
            .compactMap{ $0.args?.foo }
            .replaceError(with: "")
        
        let ui = LoadingUI()
        var token1 = isSuccess.assign(to: \.isSuccess, on: ui)
        var token2 = latestText.assign(to: \.text, on: ui)
    }
    
    public func Base_Debounce() {
        let searchText = PassthroughSubject<String, Never>()
        
        check("Debounce") {
          searchText
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
        }
//        delay(0) { searchText.send("S") }
//        delay(0.1) { searchText.send("Sw") }
//        delay(0.2) { searchText.send("Swi") }
//        delay(1.3) { searchText.send("Swif") }
//        delay(1.4) { searchText.send("Swift") }
        
        //debounce 又叫做 “防抖”:Publisher 在接收到第一个值后，并不是立即将它发布出 去，而是会开启一个内部计时器，当一定时间内没有新的事件来到，再将这个值进行 发布
        
        //throttle 它在收到一个事件后开始计时，并忽略计时 周期内的后续输入
    }
}



