//
//  LikeButtonView.swift
//  IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI
import AVFoundation

fileprivate struct CircleBurst: View {
    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Circle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 6, height: 6)
                    .offset(y: -20)
                    .rotationEffect(.degrees(Double(i) / 6 * 360))
            }
        }
        .scaleEffect(1)
        .opacity(0)
        .animation(nil, value: UUID())
    }
}

struct LikeButtonView: View {
    @Binding var isLiked: Bool
    var onToggle: ((Bool) -> Void)? = nil
    @State private var showBurst = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isLiked.toggle()
                if isLiked {
                    showBurst = true
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()

                    AudioServicesPlaySystemSound(1101) // Pop sound
                }
                onToggle?(isLiked)
            }
        }) {
            ZStack {
                if showBurst {
                    CircleBurst()
                        .scaleEffect(1.5)
                        .opacity(0)
                        .transition(.scale)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation { showBurst = false }
                            }
                        }
                }

                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isLiked ? .pink : .gray)
                    .scaleEffect(isLiked ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isLiked)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @State var isLiked = true
    LikeButtonView(isLiked: $isLiked)
}
