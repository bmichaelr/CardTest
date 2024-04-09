//
//  ShowCardView.swift
//  CardTest
//
//  Created by Benjamin Michael on 4/7/24.
//

import SwiftUI

struct CompareCardView: View {
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 1000
    @State private var opacity: CGFloat = 0.0
    var card1: Card
    var card2: Card
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all).opacity(opacity)
                .zIndex(1.0)
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(Color.green)
                            VStack {
                                Text(String(card1.number))
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
                    .frame(width: 150, height: 240)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke())
                    .onAppear {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                    .offset(y: offset)
                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(Color.green)
                            VStack {
                                Text(String(card2.number))
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
                    .frame(width: 150, height: 240)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke())
                    .onAppear {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                    .offset(y: offset)
                }
                .onTapGesture {
                    close()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color.green)
                    Text("Submit")
                }
                .frame(width: 200, height: 60, alignment: .center)
                .overlay(RoundedRectangle(cornerRadius: 25).stroke())
                .onAppear {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
                .onTapGesture {
                    print("Playing card")
                }
                .offset(y: offset)
            }
            .zIndex(2.0)
        }
        .onAppear {
            withAnimation {
                opacity = 0.5
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
}

#Preview {
    ShowCardView(isShowing: .constant(true), cardToShow: Card(number: 5))
}
