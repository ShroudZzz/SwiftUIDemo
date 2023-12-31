import SwiftUI
import ComposableArchitecture

struct TimerState: Equatable {
    var started: Date? = nil
    var duration: TimeInterval = 0
}

struct TimerEnvironment {
    var date: () -> Date
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    static var live: TimerEnvironment {
        .init(date: Date.init, mainQueue: .main)
    }
}

struct TimerId: Hashable { }

enum TimerAction {
    case start
    case stop
    case timeUpdated
}

let timerReducer = AnyReducer<TimerState, TimerAction, TimerEnvironment> { state, action, envirinment in
    switch action {
    case .start:
        if state.started == nil {
            state.started = envirinment.date()
        }
        
        return EffectTask.timer(id: TimerId(), every: .milliseconds(10), on: envirinment.mainQueue).map { time -> TimerAction in
            return TimerAction.timeUpdated
        }
    case .timeUpdated:
        state.duration += 0.01
        return .none
    case .stop:
        return .cancel(id: TimerId())
    }
}

struct TimerLabelView: View {
    let store: Store<TimerState, TimerAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Label(
                    viewStore.started == nil ? "-" : "\(viewStore.started!.formatted(date: .omitted, time: .standard))", systemImage: "clock"
                )
                
                Label(
                    "\(viewStore.duration, format: .number)s",
                    systemImage: "timer"
                )
            }
        }
    }
}


struct TimerLabelView_Previews: PreviewProvider {
  static let store = Store(initialState: .init(), reducer: timerReducer, environment: .live)
  static var previews: some View {
    VStack {
      WithViewStore(store) { viewStore in
        VStack {
          TimerLabelView(store: store)
          HStack {
            Button("Start") { viewStore.send(.start) }
            Button("Stop") { viewStore.send(.stop) }
          }.padding()
        }
      }
    }
  }
}
