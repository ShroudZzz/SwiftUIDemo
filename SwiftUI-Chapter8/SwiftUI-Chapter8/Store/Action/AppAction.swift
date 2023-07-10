import Foundation

enum AppAction {
    case login(email: String, passwd: String)
    case accountBehaviorDone(result: Result<User, AppError>)
    case logout
}
