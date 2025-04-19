//
//  GlassShineBackgroundView.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2025-04-19.
//

import SwiftUI

struct GlassShineBackgroundView: View {
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).opacity(0.2)
                .blur(radius: 10)
                .background(.ultraThinMaterial)

            LinearGradient(
                gradient: Gradient(
                    colors: [.white.opacity(0.0), .white.opacity(0.2), .white.opacity(0.0)]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    GlassShineBackgroundView()
}
