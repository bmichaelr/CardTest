//
//  ShowCardView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/7/24.
//

import SwiftUI

struct ShowCardView: View {
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 1000
    @State private var opacity: CGFloat = 0.0
    var cardToShow: Card
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all).opacity(opacity)
                .zIndex(1.0)
            VStack(alignment: .leading) {
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
            }
            .foregroundStyle(Color.black)
            .zIndex(2.0)
            .frame(width: 250, height: 400)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
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
}

#Preview {
    ShowCardView(isShowing: .constant(true), cardToShow: Card(number: 5))
}
