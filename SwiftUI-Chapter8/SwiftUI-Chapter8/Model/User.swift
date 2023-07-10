import Foundation

struct User {
    var email: String
    var favoritePokemonIds: Set<Int>
    
    func isFavoritePokemon(id: Int) -> Bool {
        return favoritePokemonIds.contains(id)
    }
}

extension User: Codable {}
