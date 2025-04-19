//
//  BackgroundShineView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2025-04-19.
//

import SwiftUI

struct GlassShineBackgroundView: View {
    @State private var animateShine = false

    var body: some View {
        ZStack {
            // Glassy background
            Color.black.opacity(0.2)
                .blur(radius: 10)
                .background(.ultraThinMaterial)
//                .cornerRadius(20)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )

            // Shine gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
//            .frame(width: 200)
//            .rotationEffect(.degrees(30))
//            .offset(x: animateShine ? 600 : -600)
            .blendMode(.screen)
            .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animateShine)
        }
//        .padding()
        .onAppear {
            animateShine = true
        }
    }
}

#Preview {
    GlassShineBackgroundView()
}
