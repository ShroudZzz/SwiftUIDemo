import SwiftUI
import Foundation

struct FlowRectangle: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 0.3 * proxy.size.height)
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 0.4 * proxy.size.width)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 0.4 * proxy.size.height)
                        Rectangle()
                            .fill(Color.orange)
                            .frame(height: 0.3 * proxy.size.height)
                    }.frame(width: 0.6 * proxy.size.width)
                }
                    
            }
        }
    }
}

struct FlowRectangle_Previews: PreviewProvider {
    static var previews: some View {
        FlowRectangle()
    }
}
