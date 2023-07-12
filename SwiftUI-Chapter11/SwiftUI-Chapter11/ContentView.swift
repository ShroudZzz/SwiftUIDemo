import SwiftUI

struct ContentView: View {
    var body: some View {
        //AligmentView()
        CustomView()
//        VStack {
//            HStack {
//                Image(systemName: "person.circle")
//                Text("User:")
//                Text("Shroud")
//            }
//            .lineLimit(1)
//            
//            HStack {
//                Image(systemName: "person.circle")
//                    .background(Color.yellow)
//                Text("User:")
//                    .background(Color.red)
//                Text("onevcat | Wei Wang")
//                    .layoutPriority(1) //.layoutPriority，控制计算布局的优先级
//                    .background(Color.green)
//            }
//            .lineLimit(1)
//            .fixedSize() //User will show  被修饰的 View 使用它在无约束下原本应有的理想尺寸
//            .frame(width: 200)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/**
 SwiftUI 系统经历了以下步骤来进行布局:
 1. rootView使用整个屏幕尺寸作为“提议”，向HStack请求尺寸。
 2. HStack在接收到这个尺寸后，会向它的子View们进行“提议”。
 3. 第一步，扣除掉默认的 HStack spacing 后，把剩余宽度三等分 (因为 HStack 中存在三个子 View)，并以其中一份向第一个子 View 的 Image 进行提议。
 4. Image会按照它要显示的内容决定自身宽度，并把这个宽度汇报给HStack。
 5. HStack从3中向子View提案的总宽度中，扣除掉4里Image汇报的宽度， 然后将剩余的宽度平分为两部分，把其中一份作为提案宽度提供给 Text("User:")。
 6.Text也根据自身内容来决定宽度。不过和Image不太一样，Text并不“盲目” 遵守自身内容的尺寸，而是会更多地尊重提案的尺寸，通过换行 (在没有设定 .lineLimit(1) 的情况下) 或是把部分内容省略为 “...” 来修改内容，去尽量满足 提案。注意，父 View 的提案对于子 View 来说只是一种建议。比如这个 Text 如果无论如何，需要使用的宽度都比提案要多，那么它也会将这个实际需要的 尺寸返回。
 
 7. 对于最后一个 Text，采取的步骤和方法与 6 类似。在这里，由于我们没有过多 约束，分配给两个 Text 的宽度也完全足够，因此它们都会按照内容宽度进行 汇报。在三个子 View 都决定好各自尺寸后，HStack 会按照设定的对齐和排 列方式把子 View 们水平顺序放置。
 
 8. 不要忘记，HStack 是 rootView 的子 View，因此，它也有义务将它的尺寸向 上汇报。由于 HStack 知道了三个子 View 和使用的 spacing 的数值 (在例子 中我们使用了默认的 spacing 值)，HStack 的尺寸也得以确定。最后它把这个 尺寸上报
 
 9最后，rootView 把 HStack 以默认方式放到自己的座标系中，也即在水平和竖 直方向上都居中。
 
 */

/**
 Frame
 新创建一个 View，并强制地用 其指定的尺寸，对内容 (其实也就是它的子 View) 进行提案
 
 fixedSize 写在 frame 之后会变得没有效果的原因:因为 frame 这个 View 的理想尺寸就是宽度 200，它已经是按照原本的理想尺寸进行布局了，再用 fixedSize 包装也 不会带来任何改变
 
 alignment 指定的是 frame View 中的内容在其内部的对齐方式，如果不指 定宽度或者高度，那么 frame 的尺寸将完全由它的内容决定。换言之，内容都已经 占据了 frame 的全部空间，不论采用哪种方式，内容在 frame 里都是 “贴边的”。对 齐也就没有任何意义了
 */

/**
 Alignment
 HStack，VStack 和 ZStack 的初始化方法都可以接受名为 alignment 的参数，不过
 它们的类型却略有不同:
 → HStack接受VerticalAlignment，典型值为.top、.center、.bottom、
 lastTextBaseline 等。
 → VStack接受HorizontalAlignment，典型值为.leading、.center和.trailing。
 → ZStack在两个方向上都有对齐的需求，它接受Alignment。Alignment其实 就是对 VerticalAlignment 和 HorizontalAlignment 组合的封装。
 
 */
