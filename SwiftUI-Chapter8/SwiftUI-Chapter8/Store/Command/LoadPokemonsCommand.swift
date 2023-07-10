import Foundation
import Combine

struct LoadPokemonsCommand: AppCommand {
    func execute(in store: Store) {
        let token = SubscriptionToken()
        
        LoadPokemonRequest.all.sink { complete in
            if case .failure(let error) = complete {
                store.dispatch(.loadPokemonsDone(result: .failure(error)))
            }
            token.unseal()
        } receiveValue: { models in
            store.dispatch(.loadPokemonsDone(result: .success(models)))
        }.seal(in: token)
    }
}
