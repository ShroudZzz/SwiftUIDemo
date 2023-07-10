import Foundation
import Combine

protocol AppCommand {
    func execute(in store: Store)
}

struct LoginAppCommand: AppCommand {
    let email: String
    let password: String
    
    func execute(in store: Store) {
        let token = SubscriptionToken()
        LoginRequest(email: email, password: password)
            .publisher
            .sink { complete in
                if case .failure(let error) = complete {
                    store.dispatch(.accountBehaviorDone(result: .failure(error)))
                }
                token.unseal()
            } receiveValue: { user in
                store.dispatch(.accountBehaviorDone(result: .success(user)))
            }.seal(in: token)
    }
}
