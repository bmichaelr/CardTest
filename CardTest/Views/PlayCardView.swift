//
//  PlayCardView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/7/24.
//

import SwiftUI

struct PlayCardView: View {
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 1000
    @State private var opacity: CGFloat = 0.0
    @Namespace var ns
    var cardToShow: Card
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all).opacity(opacity)
                .zIndex(1.0)
            VStack(alignment: .leading) {
                
                buildCardView()
                    .matchedGeometryEffect(id: "card", in: ns)
                Button("Play Card") {
                    
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
        .onTapGesture {
            close()
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
            RoundedRectangle(cornerRadius: 10)
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
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
    }
}

#Preview {
    PlayCardView(isShowing: .constant(true), cardToShow: Card(number: 5))
}
