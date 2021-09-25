import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Game = MemoryGame<String>
    typealias Card = MemoryGame<String>.Card
    
    private static let emojis = ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚐", "🛻", "🚚", "🚛", "🚜", "✈️", "🛩", "🚀", "🚁", "🚆", "🚲", "🦽", "🛴", "🛥", "⛵️", "🚤", "🛶", "🛸", "⛴"]
    private static let levelColors = [0: Color.red]
    
    private static func createMemoryGame() -> Game {
        Game { pairIndex in emojis[pairIndex] }
    }
    
    @Published private var model = createMemoryGame()
    
    var levelColor: Color = levelColors[0]!
    var cards: Array<Card> { model.cards }
    var level: Int { model.level + (model.done ? 0 : 1) }
    var levelDone: Bool { model.levelDone }
    var done: Bool { model.done }
    var points: Int { model.points }
    var userId: String { model.userId }
    var ranks: [RankItem] {
        let sorted = model.ranks.sorted { $0.points > $1.points }
        var items: [RankItem] = []
        var index = 1
        sorted.prefix(10).forEach { rank in
            items.append(RankItem(id: rank.id + "id", value: "\(index). \(rank.id)"))
            items.append(RankItem(id: rank.id + "points", value: rank.points.formatted()))
            index += 1
        }
        return items
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func nextLevel() {
        model.nextLevel()
        updateColor()
    }
    
    func reset() {
        model.reset()
        updateColor()
    }
    
    func setUserId(_ userId: String) {
        model.userId = userId.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    private func updateColor() {
        levelColor = EmojiMemoryGame.levelColors[model.level] ?? Color.red
    }
    
    struct RankItem: Identifiable {
        var id: String
        let value: String
    }
}
