import Combine

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

