import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    @State private var dealt = Set<Int>()
    @Namespace private var dealingNamespace
    @State var username: String
    
    init(game: EmojiMemoryGame) {
        self.game = game
        self.username = game.userId
    }
    
    var body: some View {
        ZStack {
            if dealt.isEmpty {
                ranksBody
            }
            ZStack(alignment: .bottom) {
                gameBody
                footerBody
                deckBody
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: Consts.aspectRatio) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture { withAnimation { game.choose(card) } }
            }
        }
        .foregroundColor(game.levelColor)
    }
    
    private var footerBody: some View {
        ZStack(alignment: .bottomLeading) {
            HStack(alignment: .bottom) {
                Text("Points: \(game.points)")
            }
            HStack(alignment: .bottom) {
                Spacer(minLength: 0)
                if !game.levelDone && dealt.count == game.cards.count {
                    reset
                } else { Spacer(minLength: 0) }
                if game.levelDone {
                    nextLevel
                } else {
                    Spacer(minLength: 0)
                }
            }
            HStack(alignment: .bottom) {
                if !game.levelDone {
                    Spacer(minLength: 0)
                    Text("Level: \(game.level)")
                }
            }
        }
    }
    
    private var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: Consts.undealthWidth, height: Consts.undealthHeight)
        .foregroundColor(game.levelColor)
        .onTapGesture {
            game.setUserId(username)
            game.cards.forEach { card in
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    private var ranksBody: some View {
        VStack {
            HStack {
                Text("Username:")
                    .font(.system(size: Consts.rankFontSize))
                TextField("", text: $username, onCommit: {
                    game.setUserId(username)
                })
                .autocapitalization(.none)
                .border(Color(.white))
                .lineLimit(1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .padding(.bottom, 50)

            VStack {
                Text("Ranks")
                    .fontWeight(.bold)
                    .font(.system(size: Consts.rankTitleFontSize))
                LazyVGrid(columns: [GridItem(.flexible(minimum: 300), spacing: 0, alignment: .leading), GridItem(alignment: .trailing)],
                          alignment: .center, spacing: 10, pinnedViews: []) {
                    ForEach(game.ranks) { item in
                        Text(item.value)
                            .lineLimit(1)
                            .font(.system(size: Consts.rankFontSize))
                    }
                }
            }
            .padding()

            Spacer()
        }
        .transition(.opacity)
    }
    
    private var nextLevel: some View {
        Button(game.done ? "New Game" : "Next") {
            dealt = []
            game.nextLevel()
        }
        .font(.system(size: Consts.buttonFontSize))
    }
    
    private var reset: some View {
        Button("Reset") {
            dealt = []
            game.reset()
        }
        .font(.system(size: Consts.buttonFontSize))
    }
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (Consts.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: Consts.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    private struct Consts {
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealthHeight: CGFloat = 90
        static let undealthWidth = undealthHeight * aspectRatio
        static let rankTitleFontSize: CGFloat = 32
        static let rankFontSize: CGFloat = 16
        static let buttonFontSize: CGFloat = 20
    }
}

struct EmojiMemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        return EmojiMemoryGameView(game: game)
    }
}
