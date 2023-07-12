import SwiftUI

extension VerticalAlignment {
    private enum MyAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.bottom]
        }
    }//自定义Mylignment：返回.bottom
    static let myAlignment2 = VerticalAlignment(MyAlignment.self)//标明使用的是竖直Alignment
}

struct CustomView2: View {
    var body: some View {
            HStack(alignment: .myAlignment2,spacing: 0) {
               Text("Shroud")
                    .alignmentGuide(.myAlignment2) { d in
                        d[VerticalAlignment.top]
                    }.background(Color.orange)
                Text("Chen")
                     .alignmentGuide(.myAlignment2) { d in
                         d[VerticalAlignment.bottom]
                     }.background(Color.blue)
            }
            .font(.largeTitle)
            .background(Color.red)
    }
}

struct CustomView2_Previews: PreviewProvider {
    static var previews: some View {
        CustomView2()
    }
}

