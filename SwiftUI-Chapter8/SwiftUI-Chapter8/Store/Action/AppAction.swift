import Foundation

enum AppAction {
    case login(email: String, passwd: String)
    case accountBehaviorDone(result: Result<User, AppError>)
    case logout
    case emailValid(valid: Bool)
    case loadPokemons
    case loadPokemonsDone(result: Result<[PokemonViewModel], AppError>)
    case togglePanelPresenting(presenting: Bool)
    case toggleListSelection(index: Int)
    case closeSafariView
}
