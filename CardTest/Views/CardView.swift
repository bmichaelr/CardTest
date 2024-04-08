//
//  CardView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/6/24.
//

import SwiftUI

public enum CardSize {
    case small, large
}

struct CardView: View {
    
    @ObservedObject var card: Card
    @Namespace var ns
    let namespace: Namespace.ID
    let size: CardSize
    
    var body: some View {
        let w: CGFloat = size == .small ? 60 : 80
        let h: CGFloat = size == .small ? 90 : 110
        let color = card.faceDown ? Color.red : Color.green
        
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(color)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke())
            
            buildCard()
        }
        .frame(width: w, height: h)
        .matchedGeometryEffect(id: card.id, in: namespace, properties: .frame, anchor: .center)
        .transition(.scale(scale: 1))
        .rotation3DEffect(.degrees(card.faceDown ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
    
    @ViewBuilder
    private func buildCard() -> some View {
        if card.faceDown {
            Text("Loot")
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
        } else {
            Text(String(card.number))
        }
    }
}

struct CardView_Previews: PreviewProvider {
    struct Wrapper: View {
        @Namespace var animation
        var body: some View {
            CardView(card: Card(number: 1), namespace: animation, size: .small)
                .padding()
                .background(Color.gray)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
