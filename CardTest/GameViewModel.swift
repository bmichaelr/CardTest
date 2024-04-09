//
//  GameViewModel.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/6/24.
//

import Foundation
import SwiftUI

struct GamePlayer {
    let name: String
    let id: UUID
    var isOut: Bool
    var isSafe: Bool
    var isHost: Bool
}

let player1: GamePlayer = GamePlayer(name: "Ben", id: UUID(), isOut: false, isSafe: true, isHost: false)
let player2: GamePlayer = GamePlayer(name: "Josh", id: UUID(), isOut: false, isSafe: true, isHost: false)
let player3: GamePlayer = GamePlayer(name: "Caleb", id: UUID(), isOut: true, isSafe: false, isHost: false)
let player4: GamePlayer = GamePlayer(name: "John", id: UUID(), isOut: false, isSafe: true, isHost: false)

let testPlayers: [GamePlayer] = [player1, player2, player3, player4]

enum HandType {
    case holding, discard
}

// A representation of a playing card
class Card: ObservableObject, Identifiable, Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
    let id = UUID()
    let number: Int
    var name: String = ""
    var description: String = ""
    @Published var faceDown: Bool = true
    init(number: Int) {
        self.number = number
    }
    init(from card: String) {
        self.number = 0
    }
}

// A representation of a player's hand of cards
class Hand: ObservableObject, Identifiable {
    let id = UUID()
    @Published var cards = [Card]()
}

class GameState: ObservableObject {
    
    @Published var players = [Player]()
    @Published var me: Player?
    @Published var deck = Hand()
    @Published var myId = player1.id
    @Published var showCard: Bool = false
    @Published var playCard: Bool = false
    @Published var myTurn: Bool = false
    @Published var cardToShow: Card = Card(number: 5)
    @Published var message: String = ""
    @Published var showCompareCards = false
    @Published var cardsToCompare = [Card]()
    init() {
        if let mePlayer = testPlayers.first(where: { $0.id == myId }) {
            self.me = Player(from: mePlayer)
        } else {
            fatalError("Player with specified ID not found")
        }
        
        self.players = testPlayers
            .filter { $0.id != myId }
            .map { Player(from: $0) }
        
        self.deck.cards.append(Card(number: 0))
        self.deck.cards.append(Card(number: 0))
    }
    
    
    func getPlayer(from id: UUID) -> Player? {
        return players.first(where: {
            $0.id == id
        })
    }
    
    func dealCard(to hand: Hand, card: Card) {
        deck.cards.append(card)
        
        withAnimation {
            guard let index = deck.cards.firstIndex(of: card) else {
                print("Could not find card in deck!")
                return
            }
            let dealtCard = deck.cards.remove(at: index)
            hand.cards.append(dealtCard)
        }
    }
    
    func remove(card: Card, from hand: Hand) {
        withAnimation {
            guard let index = hand.cards.firstIndex(of: card) else {
                fatalError("Failed to find tapped card in hand")
            }
            
            hand.cards.remove(at: index)
            deck.cards.append(card)
        }
    }
    
    func discard(card: Card, from hand: Hand, to pile: Hand) {
        withAnimation {
            guard let index = hand.cards.firstIndex(of: card) else {
                fatalError("oops")
            }
            hand.cards.remove(at: index)
            pile.cards.append(card)
        } completion: {
            withAnimation {
                card.faceDown = false
            }
        }
    }
    
    func dealToAll() {
        withAnimation {
            func dealNextPlayer(index: Int) {
                guard index < players.count else { return }
                
                let player = players[index]
                let cardToDeal = Card(number: Int.random(in: 0...15))
                let hand = player.getHand(type: .holding)
                dealCard(to: hand, card: cardToDeal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dealNextPlayer(index: index + 1)
                }
            }
            dealNextPlayer(index: 0)
        }
        
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(players.count)) {
                let cardToDeal = Card(number: Int.random(in: 0...15))
                cardToDeal.faceDown = false
                let hand = self.me!.getHand(type: .holding)
                self.dealCard(to: hand, card: cardToDeal)
            }
        }
    }
    
    func dealToOne() {
        let len = players.count
        let randIndex = Int.random(in: 0...len)
        var player: Player
        if randIndex == len {
            player = me!
        } else {
            player = players[randIndex]
        }
        
        withAnimation {
            let cardToDeal = Card(number: Int.random(in: 0...15))
            let hand = player.getHand(type: .holding)
            dealCard(to: hand, card: cardToDeal)
        }
    }
    
    func cleanUpCards() {
        for player in players {
            for hand in player.hands {
                for card in hand.cards {
                    remove(card: card, from: hand)
                }
            }
        }
        for hand in me!.hands {
            for card in hand.cards {
                remove(card: card, from: hand)
            }
        }
        deck.cards.append(Card(number: 0))
    }
    
    func showCard(card: Card) {
        cardToShow = card
        showCard = true
    }
    
    func playCard(card: Card) {
        cardToShow = card
        playCard = true
    }
    
    func getPlayerOptions(for card: Int) -> [String] {
        var options = [String]()
        for player in players {
            if !player.isSafe || !player.isOut {
                options.append(player.name)
            }
        }
        if card == 5 || options.count == 0 {
            options.append(me!.name)
        }
        return options
    }
    
    func getCardOptions(for power: Int) -> [String] {
        var options = [String]()
        options.append(contentsOf: [
            "Maul Rat",
            "Duck of Doom",
            "Wishing Ring",
            "Net Troll",
            "Dread Gazebo",
            "Turbonium Dragon",
            "Loot"
        ])
        return options
    }
    
    func playCard(player playerName: String, card cardName: String, play card: Card) {
        print("Playing card: \(card.number)")
        
        if playerName.isNotEmpty() {
            if cardName.isNotEmpty() {
                playGuessingCard(playerName, cardName, card)
            } else {
                playTargetedCard(playerName, card)
            }
        }
        
    }
    
    private func playGuessingCard(_ playerName: String, _ cardName: String, _ card: Card) {
        guard let player = getPlayerFromName(playerName) else {
            print("Unable to find player from given name!")
            return
        }
        guard let power = getCardNumberFromName(cardName) else {
            print("Unable to find card from given name!")
            return
        }
        // TODO: build the card payload and send
        print("Playing a guessing card (\(card.number): On player -> (\(player.name)), Guessing card -> (\(power))")
    }
    private func playTargetedCard(_ playerName: String, _ card: Card) {
        guard let player = getPlayerFromName(playerName) else {
            print("Unable to find player from given name!")
            return
        }
        // TODO: build card payload and send
        print("Playing a targeted card (\(card.number)): On player -> (\(player.name))")
    }
    
    private func getCardNumberFromName(_ name: String) -> Int? {
        switch name {
        case "Maul Rat": return 2
        case "Duck of Doom": return 3
        case "Wishing Ring": return 4
        case "Net Troll" : return 5
        case "Dread Gazebo": return 6
        case "Turbonium Dragon": return 7
        case "Loot": return 8
        default: return nil
        }
    }
    
    private func getPlayerFromName(_ name: String) -> Player? {
        if me!.name == name {
            return me!
        }
        guard let player = players.first(where: { $0.name == name }) else {
            return nil
        }
        return player
    }
}


class Player: ObservableObject, Identifiable {
    let id = UUID()
    @Published var hands = [Hand(), Hand()]
    @Published var name: String
    @Published var isOut: Bool
    @Published var isSafe: Bool
    @Published var playerId: UUID
    init(from player: GamePlayer) {
        self.name = player.name
        self.isOut = player.isOut
        self.isSafe = player.isSafe
        self.playerId = player.id
    }
    func getHand(type: HandType) -> Hand {
        switch type {
        case .discard:
            return hands[1]
        case .holding:
            return hands[0]
        }
    }
    func updatePlayer(with p: GamePlayer) {
        self.isOut = p.isOut
        self.isSafe = p.isSafe
    }
}

extension String {
    func isNotEmpty() -> Bool {
        return !self.isEmpty
    }
}
