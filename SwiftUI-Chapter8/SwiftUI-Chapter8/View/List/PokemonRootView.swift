import SwiftUI

struct PokemonRootView: View {
    var body: some View {
        NavigationView {
            PokemonList().navigationBarTitle("宝可梦列表")
        }
    }
}

struct PokemonListRoot_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRootView()
    }
}
