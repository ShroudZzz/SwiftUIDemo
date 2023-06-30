import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.heightAnchor
              .constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor
              .constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

extension View {
    func blurBackground(style: UIBlurEffect.Style) -> some View {
        ZStack {
            BlurView(style: style)
            self
        }
    }
}

struct PokemonInfoPanel: View {
    
    let model: PokemonViewModel
    
    var abilities: [AbilityViewModel] {
        AbilityViewModel.sample(pokemonID: model.id)
    }
    
    var topIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .frame(width: 40, height: 6)
            .opacity(0.2)
    }
    
    var pokemonDescription: some View {
        Text(model.descriptionTextEN)
            .font(.callout)
            .foregroundColor(Color(hex: 0x666666))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                topIndicator
                Header(model: model)
                pokemonDescription
                Divider()
                AblilityList(model: model, abilityModels: abilities)
            }
        }.padding(EdgeInsets(top: 12, leading: 20, bottom: 30, trailing: 30))
            .blurBackground(style: .systemMaterial)
            .cornerRadius(20)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension PokemonInfoPanel {
    struct Header: View {
        let model: PokemonViewModel
        
        var body: some View {
            HStack(spacing: 18){
                pokemonIcon
                nameSpecies
                verticalDivider
                VStack(spacing: 12) {
                    bodyStatus
                    typeInfo
                }
            }
        }
        
        var pokemonIcon: some View {
            Image("Pokemon-\(model.id)")
                .resizable()
                .frame(width: 68, height: 68)
        }
        
        var nameSpecies: some View {
            VStack(spacing: 10) {
                VStack{
                    Text(model.name)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                    Text(model.nameEN)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(model.color)
                }
                Text(model.genus)
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
        }
        
        var verticalDivider: some View {
            RoundedRectangle(cornerRadius: 1)
                .frame(width: 1, height: 44)
                .opacity(0.1)
        }
        
        var bodyStatus: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("身高").modifier(BodyStatusTagModifier())
                    Text(model.height).modifier(BodyStatusTagResultModifier(model: model))
                }
                
                HStack {
                    Text("体重").modifier(BodyStatusTagModifier())
                    Text(model.weight).modifier(BodyStatusTagResultModifier(model: model))
                }
            }
        }
        
        var typeInfo: some View {
            HStack {
                ForEach(model.types) { type in
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(type.color)
                            .frame(width: 36, height: 14)
                        Text(type.name)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct BodyStatusTagModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 11))
            .foregroundColor(.gray)
    }
}

struct BodyStatusTagResultModifier: ViewModifier {
    let model: PokemonViewModel
    
    func body(content: Content) -> some View {
        content.font(.system(size: 11))
            .foregroundColor(model.color)
    }
}

extension PokemonInfoPanel {
    struct AblilityList: View {
        let model: PokemonViewModel
        
        let abilityModels: [AbilityViewModel]?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("技能")
                    .font(.headline)
                    .fontWeight(.bold)
                
                if abilityModels != nil {
                    ForEach(abilityModels!) { ability in
                        Text(ability.name)
                            .font(.subheadline)
                            .foregroundColor(model.color)
                        Text(ability.descriptionText)
                            .font(.footnote)
                            .foregroundColor(Color(hex: 0xAAAAAA))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PokemonInfoPanel_Previews: PreviewProvider {
    static var previews: some View {
        PokemonInfoPanel(model: .sample(id: 1))
    }
}
