////
////  PlayerView.swift
////  CardTest
////
////  Created by Benjamin Michael on 4/6/24.
////
//
//import SwiftUI
//
//struct PlayerView: View {
//    let ns: Namespace.ID
//    let player: Player
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("Hand")
//                HStack(alignment: .bottom) {
//                    ForEach(player.holdingCards) { card in
//                        CardView(card: card, namespace: ns, size: .small)
//                    }
//                }
//            }
//            VStack(alignment: .center) {
//                Text("Discard")
//                HStack {
//                    ForEach(player.playedCards) { card in
//                        CardView(card: card, namespace: ns, size: .large)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct PlayerView_Previews: PreviewProvider {
//    struct Wrapper: View {
//        @Namespace var namespace
//        
//        var player: Player {
//            var hand = [Card]()
//            hand.append(contentsOf: [
//                Card(number: 1),
//                Card(number: 2)
//            ])
//            var discard = [Card]()
//            discard.append(contentsOf: [
//                Card(number: 5),
//                Card(number: 11)
//            ])
//            let player =  Player(hand, discard)
//            return player
//        }
//        
//        var body: some View {
//            PlayerView(ns: namespace, player: player)
//        }
//    }
//    
//    static var previews: some View {
//        Wrapper()
//    }
//}
