//
//  PlayCardView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/7/24.
//

import SwiftUI

struct PlayCardView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 1000
    @State private var opacity: CGFloat = 0.0
    @State private var playing: Bool = false
    @State private var pickedPlayer: String = ""
    @State private var pickedCard: String = ""
    @Namespace var ns
    var cardToShow: Card
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all).opacity(opacity)
                .zIndex(1.0)
                .onTapGesture {
                    close()
                }
            VStack(alignment: .center) {
                if !playing {
                    buildCardView()
                        .matchedGeometryEffect(id: "card", in: ns)
                    Button("Play Card") {
                        withAnimation {
                            playing.toggle()
                        }
                    }
                } else {
                    buildPlayingView()
                        .matchedGeometryEffect(id: "card", in: ns)
                }
            }
            .foregroundStyle(Color.black)
            .zIndex(2.0)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
            .offset(y: offset)
        }
        .onAppear {
            withAnimation {
                opacity = 0.15
            }
        }
    }
    
    private func close() {
        withAnimation {
            opacity = 0
            offset = 1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShowing = false
        }
    }
    
    @ViewBuilder
    private func buildCardView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Color.green)
            VStack {
                Text(String(cardToShow.number))
                Spacer()
                Image(systemName: "globe")
                    .font(.title)
                    .scaledToFill()
                Text("Some wordy description here about how the card works")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .frame(width: 250, height: 400)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke())
    }
    
    @ViewBuilder
    private func buildPlayingView() -> some View {
        let width = UIScreen.main.bounds.width - 40
        let height = getHeight()
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Color.green)
            VStack(alignment: .leading) {
                Text("Playing: \(cardToShow.name)")
                    .padding(.leading, 20)
                Spacer()
                buildCardSpecificData()
                HStack {
                    Button("Cancel") {
                        withAnimation {
                            playing = false
                        } completion: {
                            close()
                        }
                    }
                    Spacer()
                    Button("Play") {
                        if cardNotAbleToBePlayed() { return }
                        gameState.playCard(player: pickedPlayer, card: pickedCard)
                        withAnimation {
                            playing = false
                        } completion: {
                            close()
                        }
                    }
                }
            }
            .padding()
        }
        .frame(width: width, height: height)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke())
    }
    
    @ViewBuilder
    private func buildCardSpecificData() -> some View {
        switch cardToShow.number {
        case 1:
            VStack {
                HStack {
                    Text("Choose player to play on: ")
                    Spacer()
                    Picker("Select player:", selection: $pickedPlayer) {
                        Text("").tag("")
                        ForEach(gameState.getPlayerOptions(for: cardToShow.number), id: \.self) { name in
                            Text(name)
                        }
                    }
                }
                HStack {
                    Text("Pick card to guess:")
                    Spacer()
                    Picker("Select player:", selection: $pickedCard) {
                        Text("").tag("")
                        ForEach(gameState.getCardOptions(for: cardToShow.number), id: \.self) { card in
                            Text(card)
                        }
                    }
                }
            }
        case 2, 3, 5, 6:
            HStack {
                Text("Choose player to play on: ")
                Spacer()
                Picker("Select player:", selection: $pickedPlayer) {
                    ForEach(gameState.getPlayerOptions(for: cardToShow.number), id: \.self) { name in
                        Text(name)
                    }
                }
            }
        default:
            EmptyView()
        }
    }
    
    private func getHeight() -> CGFloat {
        switch cardToShow.number {
        case 1:
            return CGFloat(integerLiteral: 200)
        case 2, 3, 5, 6:
            return CGFloat(integerLiteral: 150)
        default:
            return CGFloat(integerLiteral: 100)
        }
    }
    
    private func cardNotAbleToBePlayed() -> Bool {
        switch cardToShow.number {
        case 1:
            return pickedPlayer.isEmpty || pickedCard.isEmpty
        case 2, 3, 5, 6:
            return pickedPlayer.isEmpty
        default:
            return false
        }
    }
}

#Preview {
    PlayCardView(isShowing: .constant(true), cardToShow: Card(number: 8))
        .environmentObject(GameState())
}
