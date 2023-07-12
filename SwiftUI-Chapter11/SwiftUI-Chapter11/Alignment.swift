import SwiftUI

extension VerticalAlignment {
    struct SelectAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let select = VerticalAlignment(SelectAlignment.self)
}

struct AligmentView: View {

    @State var selectedIndex = 0

    let names = [
        "TextZzzz",
        "ShroudZzz",
        "GewenZzz"
    ]

    var body: some View {
      HStack(alignment: .select) {
        Text("User:")
          .font(.footnote)
          .foregroundColor(.green)
          .alignmentGuide(.select) { d in
              print("sss-u",d[VerticalAlignment.center])
              return d[VerticalAlignment.bottom] //+ CGFloat(self.selectedIndex) * 20.3
          }.background(Color.gray)
          VStack(alignment: .trailing) {
              Image(systemName: "person.circle")
                .foregroundColor(.green)
                .alignmentGuide(.select) { d in
                    print("sss-i",d[VerticalAlignment.center])
                  return d[VerticalAlignment.center]
                }
              Image(systemName: "person.circle")
                .foregroundColor(.green)
                .alignmentGuide(.select) { d in
                    print("sss-i",d[VerticalAlignment.center])
                  return d[VerticalAlignment.center]
                }
          }
        VStack(alignment: .trailing) {
          ForEach(0..<names.count) { index in
            Text(self.names[index])
              .foregroundColor(self.selectedIndex == index ? .green : .black)
              .alignmentGuide(self.selectedIndex == index ? .select : .center) { d in
                if self.selectedIndex == index {
                    print("sss-n",d[VerticalAlignment.center])
                  return d[VerticalAlignment.center]
                } else {
                  return d[VerticalAlignment.center]
                }
              }.onTapGesture {
                self.selectedIndex = index
              }
          }
        }
      }.animation(.linear(duration: 0.2))
            .background(Color.red)
    }
}

struct AligmentView_Previews: PreviewProvider {
    static var previews: some View {
        AligmentView()
    }
}

