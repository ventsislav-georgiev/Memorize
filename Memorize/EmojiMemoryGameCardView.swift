import SwiftUI

struct CardView: View {
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: -90),
                            endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                        .onAppear {
                            animatedBonusRemaining = card.bonusRemaining
                            withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                animatedBonusRemaining = 0
                            }
                        }
                    } else {
                        if -90 == (1-card.bonusRemaining)*360-90 {
                            Circle()
                        } else {
                            Pie(startAngle: Angle(degrees: -90),
                                endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                        }
                    }
                }
                .opacity(Consts.pieOpacity)
                .padding(Consts.piePadding)

                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(.easeInOut(duration: 1.2), value: card.isMatched)
                    .font(Font.system(size: Consts.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (Consts.fontSize / Consts.fontScale)
    }
    
    private struct Consts {
        static let fontSize: CGFloat = 42
        static let fontScale: CGFloat = 0.7
        static let pieOpacity: CGFloat = 0.5
        static let piePadding: CGFloat = 6
    }
}
