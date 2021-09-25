import Foundation
import SwiftUI

struct MemoryGame<CardContent> where CardContent: Equatable {
    let levels = [4, 10, 15, 28]
    var done: Bool { level >= levels.count }
    var userId: String {
        get { UserDefaults.standard.string(forKey: "userId") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "userId") }
    }
    
    private(set) var cards: Array<Card> = []
    private(set) var levelDone = false
    private(set) var level = 0
    private(set) var points = 0
    private(set) var ranks: [Rank] = []

    private var createCardContent: (Int) -> CardContent
    private let maxBonusPoints: Double = 10

    private var prevFaceUpCardIndex: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).singleOrNil }
        set { cards.indices.forEach { cards[$0].isFaceUp = $0 == newValue } }
    }
    
    mutating func choose(_ card: Card) {
        let firstMatchingIndex = cards.firstIndex(where: { $0.id == card.id })

        if let choosenIndex = firstMatchingIndex,
           !cards[choosenIndex].isFaceUp,
           !cards[choosenIndex].isMatched
        {
            if let potentialMatchIndex = prevFaceUpCardIndex {
                if cards[potentialMatchIndex].content == cards[choosenIndex].content {
                    cards[choosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    points += Int(ceil(cards[choosenIndex].bonusRemaining*maxBonusPoints)) + Int(ceil(cards[potentialMatchIndex].bonusRemaining*maxBonusPoints)) + 1
                }
                cards[choosenIndex].isFaceUp = true
            } else {
                prevFaceUpCardIndex = choosenIndex
            }
            
            if cards.allSatisfy({ $0.isMatched }) {
                levelDone = true
                level += 1
            }
        }
        
        if done {
            updateRank()
        }
    }

    mutating func nextLevel() {
        if level >= levels.count {
            return reset()
        }
        
        updateRank()
        cards = []
        levelDone = false
        
        for pairIndex in 0..<levels[level] {
            let content = createCardContent(pairIndex)
            cards.append(Card(id: pairIndex*2, content: content))
            cards.append(Card(id: pairIndex*2+1, content: content))
        }
        
        cards.shuffle()
    }
    
    mutating func reset() {
        level = 0
        points = 0
        nextLevel()
    }
    
    mutating func updateRank() {
        if userId.isEmpty {
            return
        }
        
        if let index = ranks.firstIndex(where: { $0.id == userId }) {
            if points > ranks[index].points {
                ranks[index].points = points
            }
        } else {
            ranks.append(Rank(id: userId, points: points))
        }
        
        if let encoded = try? JSONEncoder().encode(ranks) {
            UserDefaults.standard.set(encoded, forKey: "ranks")
        }
    }

    init(createCardContent: @escaping (Int) -> CardContent) {
        if let ranksData = UserDefaults.standard.object(forKey: "ranks") as? Data {
            if let ranks = try? JSONDecoder().decode(Array<Rank>.self, from: ranksData) {
                self.ranks = ranks
            }
        }

        self.createCardContent = createCardContent
        self.nextLevel()
    }
    
    struct Rank: Identifiable, Codable {
        let id: String
        var points: Int
    }
    
    struct Card: Identifiable {
        let id: Int
        let content: CardContent

        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }

        var isMatched = false {
            didSet {
                if isMatched {
                    stopUsingBonusTime()
                }
            }
        }
        
        // MARK: - Bonus Time
        var bonusTimeLimit: TimeInterval = 6
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        var bonusRemaining: Double {
            bonusTimeRemaining > 0 ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            }
            return pastFaceUpTime
        }
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpDate = nil
        }
    }
}

extension Array {
    var singleOrNil: Element? {
        if self.count == 1 {
            return self.first
        }
        return nil
    }
}
