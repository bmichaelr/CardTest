//
//  MyHandView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/6/24.
//

import SwiftUI

struct MyHandView: View {
    
    @ObservedObject var player: Player
    var namespace: Namespace.ID
    var onHandTap: (Card) -> Void
    
    var body: some View {
        VStack {
            buildPlayedCardView()
            buildHoldingCardView()
        }
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
    }
    
    @ViewBuilder
    private func buildPlayedCardView() -> some View {
        let hand = player.getHand(type: .discard)
        let width = UIScreen.main.bounds.width - 20
        HStack(spacing: -25) {
            ForEach(hand.cards) { card in
                CardView(card: card, namespace: namespace, size: .small)
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .frame(width: width, height: 110)
    }
    
    @ViewBuilder
    private func buildHoldingCardView() -> some View {
        let hand = player.getHand(type: .holding)
        let size = hand.cards.count
        let offset: Double = size > 1 ? 10 : 0
        HStack(spacing: -30) {
            ForEach(Array(hand.cards.enumerated()), id: \.1.id) { (index, card) in
                CardView(card: card, namespace: namespace, size: .large)
                    .rotationEffect(Angle(degrees: index == 1 ? offset : -offset))
                    .onTapGesture {
                        onHandTap(card)
                    }
            }
        }
    }
}

struct MyHandView_Previews: PreviewProvider {
    struct Wrapper: View {
        @Namespace var namespace
        
        var hand: Hand {
            let hand = Hand()
            hand.cards.append(contentsOf: [
                Card(number: 1),
                Card(number: 2)
            ])
            return hand
        }
        
        var discard: Hand {
            let hand = Hand()
            hand.cards.append(contentsOf: [
                Card(number: 1),
                Card(number: 2),
                Card(number: 5),
                Card(number: 6),
                Card(number: 1),
                Card(number: 2),
                Card(number: 5),
                Card(number: 6)
            ])
            return hand
        }
        
        var player: Player {
            let gamePlayer = player1
            let player = Player(from: gamePlayer)
            player.hands[0] = hand
            player.hands[1] = discard
            return player
        }
        
        var body: some View {
            MyHandView(player: player, namespace: namespace, onHandTap: { _ in })
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
