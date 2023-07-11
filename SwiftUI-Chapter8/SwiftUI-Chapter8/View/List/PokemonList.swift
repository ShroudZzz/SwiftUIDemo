import SwiftUI

struct PokemonList: View {
    @State var searchText: String = ""
    
    @EnvironmentObject var store: Store
    
    var pokemonList: AppState.PokemonList { store.appState.pokemonList }

    var body: some View {
        ScrollView {
            LazyVStack {
                TextField("搜索", text: $searchText)
                    .frame(height: 40)
                    .padding(.horizontal, 25)
                //ForEach(PokemonViewModel.all) {
                ForEach(store.appState.pokemonList.allPokemonsById) {
                    pokemon in
                    PokemonInfoRow(
                        model: pokemon,
                        expanded: pokemonList.selectionState.isExpanding(pokemon.id)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.425, blendDuration: 0)) {
                            self.store.dispatch(.toggleListSelection(index: pokemon.id))
                        }
                    }
                }
            }
        }
    }
}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PokemonList().environmentObject(Store())
    }
}
