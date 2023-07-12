//https://github.com/qizhemotuosangeyan/blog/blob/master/SwiftUI-alignmentGuide-%E8%87%AA%E5%AE%9A%E4%B9%89%E5%B8%83%E5%B1%80%E5%9F%BA%E7%A1%80.md

import SwiftUI

extension VerticalAlignment {
    private enum MyAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[.bottom]
        }
    }//自定义Mylignment：返回.bottom
    static let myAlignment = VerticalAlignment(MyAlignment.self)//标明使用的是竖直Alignment
}

struct CustomView: View {
    @State private var selectedIdx = 0
    
    let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
            HStack(alignment: .myAlignment,spacing: 0) {
                Image(systemName: "arrow.right.circle.fill")
                    .alignmentGuide(.myAlignment, computeValue: { d in d[VerticalAlignment.center] })//对对勾设置刚刚自定义的Guide，返回竖直Alignment.center
                    .foregroundColor(.green)
                    .background(Color.orange)

                VStack(alignment: .leading) {
                    ForEach(days.indices, id: \.self) { idx in
                        Group {
                            if idx == self.selectedIdx {
                                Text(self.days[idx])
                                    .transition(AnyTransition.identity)
                                    .alignmentGuide(.myAlignment, computeValue: { d in d[VerticalAlignment.center] })
                            } else {
                                Text(self.days[idx])
                                    .transition(AnyTransition.identity)
                                    .onTapGesture {
                                        withAnimation {
                                            self.selectedIdx = idx
                                        }
                                }
                            }
                        }
                    }
                }.background(Color.orange)
                
                Text("xxx").background(Color.orange)
            }
            //.padding(20)
            .font(.largeTitle)
            .background(Color.red)
    }
}

struct CustomView_Previews: PreviewProvider {
    static var previews: some View {
        CustomView()
    }
}
