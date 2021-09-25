import SwiftUI

struct Cardify: AnimatableModifier {
    var radius: Double
    var animatableData: Double {
        get { radius }
        set { radius = newValue }
    }
    
    init(isFaceUp: Bool) {
        radius = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: Consts.cornerRadius)
            if radius < 90 {
                shape.fill().foregroundColor(.white).opacity(0.1)
                shape.strokeBorder(lineWidth: Consts.lineWidth)
            } else {
                shape.fill()
            }
            content.opacity(radius < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(radius), axis: (0, 1, 0))
    }
    
    private struct Consts {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
