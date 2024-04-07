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
    
    let card: Card
    let namespace: Namespace.ID
    let size: CardSize
    
    var body: some View {
        let w: CGFloat = size == .small ? 60 : 80
        let h: CGFloat = size == .small ? 90 : 110
        
        ZStack {
            RoundedRectangle(cornerRadius: 20,
                             style: .continuous)
            .fill(Color.green)
            RoundedRectangle(cornerRadius: 20,
                             style: .continuous)
            .stroke(.black, lineWidth: 2)
            
            Text("\(card.number)")
        }
        .frame(width: w, height: h)
        .matchedGeometryEffect(id: card.id, in: namespace, properties: .frame, anchor: .center)
        .transition(.scale(scale: 1))
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
