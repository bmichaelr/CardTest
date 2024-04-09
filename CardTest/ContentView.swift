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
                    Button("Update") {
                        changeStatus()
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
        .compareCards(isPresented: $gameState.showCard, compare: gameState.cardToShow, to: gameState.cardToShow)
        .showCard(isPresented: $gameState.showCard, show: gameState.cardToShow)
        .showPlayCard(isPresented: $gameState.playCard, show: gameState.cardToShow, game: gameState, myTurn: $gameState.myTurn)
    }
    
    @ViewBuilder
    private func buildPlayerView(from player: Player) -> some View {
        HStack {
            VStack {
                HandView(hand: player.getHand(type: .holding),
                         player: player,
                         namespace: animation,
                         onCardTap: {
                    gameState.discard(card: $0, from: player.getHand(type: .holding), to: player.getHand(type: .discard))
                }, cardSize: .small)
            }
            VStack {
                HandView(hand: player.getHand(type: .discard),
                         player: player,
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
                    player: player,
                    isMe: true,
                    namespace: animation,
                    onCardTap: { gameState.showCard(card: $0) },
                    cardSize: .small)
            HandView(
                hand: player.getHand(type: .holding), 
                player: player,
                isMe: true,
                namespace: animation,
                onCardTap: { gameState.playCard(card: $0) },
                cardSize: .large
            )
        }
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
        .padding(.leading, 10)
    }
    
    // MARK: Private functions
    private func changeStatus() {
        let thingToChange = Bool.random()
        if thingToChange {
            gameState.players.first!.isOut = false
            gameState.players.first!.isSafe = true
        } else {
            gameState.players.first!.isSafe = false
            gameState.players.first!.isOut = true
        }
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
    func compareCards(isPresented: Binding<Bool>, compare card: Card, to card2: Card) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CompareCardView(isShowing: isPresented, card1: card, card2: card2)
            }
        }
    }
}

extension View {
    func showPlayCard(isPresented: Binding<Bool>, show card: Card, game: GameState, myTurn: Binding<Bool>) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                PlayCardView(isShowing: isPresented, isMyTurn: myTurn, gameState: game, cardToShow: card)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
