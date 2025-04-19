//
//  GlassShineBackgroundView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2025-04-19.
//

import SwiftUI

struct GlassShineBackgroundView: View {
    @State private var animateShine = false

    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).opacity(0.2)
                .blur(radius: 10)
                .background(.ultraThinMaterial)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.0),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.screen)
            .animation(Animation.linear(duration: 2).repeatForever(autoreverses: true), value: animateShine)
        }
        .onAppear {
            animateShine = true
        }
    }
}

#Preview {
    GlassShineBackgroundView()
}
