import Foundation
import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var gameState = GameState()
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button("Deal All") {
                        gameState.dealToAll()
                    }
                    Button("Deal") {
                        gameState.dealToOne()
                    }
                    Button("Clean") {
                        gameState.cleanUpCards()
                    }
                    Spacer()
                    VStack {
                        DeckView(deck: gameState.deck,
                                 namespace: animation)
                        Text("Deck")
                            .fontWeight(.bold)
                    }
                }
                .padding([.leading, .trailing], 10)
                
                ForEach(gameState.players) { player in
                    buildPlayerView(from: player)
                }
                Spacer()
                buildMyPlayingView(from: gameState.me!)
                    .offset(y: 20)
            }
            .environmentObject(gameState)
        }
        .showCard(isPresented: $gameState.showCard, show: gameState.cardToShow)
    }
    
    @ViewBuilder
    private func buildPlayerView(from player: Player) -> some View {
        HStack {
            VStack {
                HandView(hand: player.getHand(type: .holding),
                         player: player.gamePlayer,
                         namespace: animation,
                         onCardTap: {
                    gameState.discard(card: $0, from: player.getHand(type: .holding), to: player.getHand(type: .discard))
                }, cardSize: .small)
            }
            VStack {
                HandView(hand: player.getHand(type: .discard),
                         namespace: animation,
                         onCardTap: { gameState.showCard(card: $0)},
                         cardSize: .large)
            }
            Spacer()
        }
        .padding(.leading, 10)
    }
    
    @ViewBuilder
    private func buildMyPlayingView(from player: Player) -> some View {
        VStack {
            HandView(hand: player.getHand(type: .discard),
                    player: player.gamePlayer,
                    isMe: true,
                    namespace: animation,
                    onCardTap: { gameState.remove(card: $0, from: player.getHand(type: .discard))},
                    cardSize: .small)
            HandView(
                hand: player.getHand(type: .holding),
                isMe: true,
                namespace: animation,
                onCardTap: {
                    gameState.discard(card: $0, from: player.getHand(type: .holding), to: player.getHand(type: .discard))
                },
                cardSize: .large
            )
        }
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
        .padding(.leading, 10)
    }
    
    @ViewBuilder
    private func buildMyView(from player: Player) -> some View {
        EmptyView()
    }
    
    // MARK: Private functions
    private func changeStatus() {
        let len = gameState.players.count
        let randIndex = Int.random(in: 0..<len)
        let player = gameState.players[randIndex]
        var underlying = player.gamePlayer
        if Bool.random() {
            if Bool.random() {
                underlying.isSafe = false
                underlying.isOut = true
            } else {
                underlying.isOut = false
                underlying.isSafe = true
            }
        } else {
            underlying.isSafe = false
            underlying.isOut = false
        }
        player.objectWillChange.send()
        player.updatePlayer(with: underlying)
    }
}

extension View {
    func showCard(isPresented: Binding<Bool>, show card: Card) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                ShowCardView(isShowing: isPresented, cardToShow: card)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
