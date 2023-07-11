import SwiftUI
import ComposableArchitecture

let resultListStateTag = UUID()

struct GameResult: Equatable, Identifiable {
    let counter: Counter
    let timeSpent: TimeInterval
    
    var correct: Bool { counter.secret == counter.count }
    var id: UUID { counter.id }
}

struct GameState: Equatable {
    var counter: Counter = .init()
    var timer: TimerState = .init()
    
    var resultListState: Identified<UUID, GameResultListState>?
    
    var results = IdentifiedArrayOf<GameResult>()
    var lastTimestamp = 0.0
}

enum GameAction {
    case counter(CounterAction)
    case timer(TimerAction)
    case listResult(GameResultListAction)
    case setNavigation(UUID?)
}

struct GameEnvironment {
    var generateRandom: (ClosedRange<Int>) -> Int
    var uuid: () -> UUID
    var date: () -> Date
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    static let live = GameEnvironment(
        generateRandom: Int.random,
        uuid: UUID.init,
        date: Date.init,
        mainQueue: .main)
}

let gameReducer = AnyReducer<GameState, GameAction, GameEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        case .counter(.playNext):
            let result = GameResult(counter: state.counter, timeSpent: state.timer.duration - state.lastTimestamp)
            state.results.append(result)
            state.lastTimestamp = state.timer.duration
            return .none
        case .setNavigation(.some(let id)):
            state.resultListState = .init(state.results, id: id)
            return .none
        case .setNavigation(.none):
            state.results = state.resultListState?.value ?? []
            return .none
        default: return .none
        }
    },
    counterReducer.pullback(
        state: \.counter,
        action: /GameAction.counter,
        environment: { .init(generateRandom: $0.generateRandom, uuid: $0.uuid) }
    ),
    timerReducer.pullback(
        state: \.timer,
        action: /GameAction.timer,
        environment: { .init(date: $0.date, mainQueue: $0.mainQueue) }
    ),
    gameResultListReducer
        .pullback(state: \Identified.value,action: .self, environment: { $0 } )
        .optional()
        .pullback(state: \.resultListState, action: /GameAction.listResult, environment: { _ in .init() }
    )
)

struct GameView: View {
    let store: Store<GameState, GameAction>
    var body: some View {
        VStack {
            WithViewStore(store.scope(state: \.results)) { viewStore in
                VStack {
                    resultLabel(viewStore.state.elements)
                    Divider()
                    TimerLabelView(store: store.scope(state: \.timer, action: GameAction.timer))
                    CounterView(store: store.scope(state: \.counter, action: GameAction.counter))
                }.onAppear {
                    viewStore.send(.timer(.start))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    WithViewStore(store) { viewStore in
                        NavigationLink("Detail", tag: resultListStateTag, selection: viewStore.binding(get: \.resultListState?.id, send: GameAction.setNavigation), destination: {
                            IfLetStore(store.scope(state: \.resultListState?.value, action: GameAction.listResult)) {
                                GameResultListView(store: $0)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func resultLabel(_ results: [GameResult]) -> some View {
        Text("Result: \(results.filter(\.correct).count)/\(results.count) correct")
    }
}


struct Game_Previews: PreviewProvider {
    static var previews: some View {
        GameView(store: Store(initialState: GameState(), reducer: gameReducer, environment: GameEnvironment.live ))
    }
}
