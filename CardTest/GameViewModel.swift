//
//  GameViewModel.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/6/24.
//

import Foundation
import SwiftUI

struct pPlayer {
    let name: String
    let id: UUID
    var isOut: Bool
    var isSafe: Bool
    var isHost: Bool
}

let player1: pPlayer = pPlayer(name: "Ben", id: UUID(), isOut: false, isSafe: true, isHost: false)
let player2: pPlayer = pPlayer(name: "Josh", id: UUID(), isOut: true, isSafe: false, isHost: false)
let player3: pPlayer = pPlayer(name: "Caleb", id: UUID(), isOut: false, isSafe: false, isHost: false)
let player4: pPlayer = pPlayer(name: "John", id: UUID(), isOut: false, isSafe: false, isHost: false)

let testPlayers: [pPlayer] = [player1, player2, player3, player4]

enum HandType {
    case holding, discard
}

// A representation of a playing card
struct Card: Identifiable, Equatable {
    let id = UUID()
    let number: Int
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
    @Published var cardToShow: Card = Card(number: 5)
    
    init() {
        if let mePlayer = testPlayers.first(where: { $0.id == myId }) {
            self.me = Player(from: mePlayer)
        } else {
            fatalError("Player with specified ID not found")
        }
        
        self.players = testPlayers
            .filter { $0.id != myId }
            .map { Player(from: $0) }
        
        self.deck.cards = (1...20).map { Card(number: $0) }.shuffled()
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
        withAnimation {
            func cleanUpNextPlayer(index: Int) {
                guard index < players.count else { return }
                let player = players[index]
                for (index, card) in player.hands[0].cards.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.25) {
                        self.remove(card: card, from: player.hands[0])
                    }
                }
                for (index, card) in player.hands[1].cards.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.25) {
                        self.remove(card: card, from: player.hands[1])
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(player.hands[0].cards.count + player.hands[1].cards.count) * 0.25) {
                    cleanUpNextPlayer(index: index + 1)
                }
            }
            cleanUpNextPlayer(index: 0)
        }
        
        withAnimation {
            for (_, card) in me!.hands[0].cards.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.remove(card: card, from: self.me!.hands[0])
                }
            }
            for (_, card) in me!.hands[1].cards.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.remove(card: card, from: self.me!.hands[1])
                }
            }
        }
    }
    
    func showCard(card: Card) {
        cardToShow = card
        showCard = true
    }
}


class Player: ObservableObject, Identifiable {
    let id = UUID()
    var hands = [Hand(), Hand()]
    @Published var gamePlayer: pPlayer
    init(from player: pPlayer) {
        gamePlayer = player
    }
    func getHand(type: HandType) -> Hand {
        switch type {
        case .discard:
            return hands[1]
        case .holding:
            return hands[0]
        }
    }
    func updatePlayer(with p: pPlayer) {
        gamePlayer.isOut = p.isOut
        gamePlayer.isSafe = p.isSafe
        self.objectWillChange.send()
    }
}

