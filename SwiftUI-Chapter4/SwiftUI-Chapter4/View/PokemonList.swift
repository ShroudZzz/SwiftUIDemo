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

    @State var expandingIndex: Int?

    var body: some View {
        ScrollView {
            //LazyVStack 和 LazyHStack 以仅在需要展 示 View 的时候才创建 View
            LazyVStack {
                ForEach(PokemonViewModel.all) { pokemon in
                    PokemonInfoRow(
                        model: pokemon,
                        expanded: expandingIndex == pokemon.id
                    )
                    .onTapGesture {
                        //显式动画
                        withAnimation(
                            .spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
                            if expandingIndex == pokemon.id {
                                expandingIndex = nil
                            } else {
                                expandingIndex = pokemon.id
                            }
                        }
                    }
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
