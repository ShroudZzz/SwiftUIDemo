import SwiftUI

/*
struct PokemonList: View {
    var body: some View {
        List(PokemonViewModel.all) { pokemon in
            PokemonInfoRow(model: pokemon, expanded: false)
        }
    }
}
*/

struct PokemonList: View {
    var body: some View {
        ScrollView {
            //LazyVStack 和 LazyHStack 以仅在需要展 示 View 的时候才创建 View
            LazyVStack {
                ForEach(PokemonViewModel.all) { pokemon in
                    PokemonInfoRow(model: pokemon, expanded: false)
                }
            }
        }
    }
}


struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PokemonList()
    }
}
