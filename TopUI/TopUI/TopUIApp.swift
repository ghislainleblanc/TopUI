//
//  TopUIApp.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import SwiftUI

@main
struct TopUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    static let width: CGFloat = 500
    static let height: CGFloat = 500

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: Self.width, height: Self.height)
                .onAppear {
                    for window in NSApplication.shared.windows {
                        window.styleMask = [.borderless]
                        window.isOpaque = false
                        window.alphaValue = 0.9
                        window.level = .floating
                        window.titleVisibility = .hidden
                        window.titlebarAppearsTransparent = true
                        window.isMovableByWindowBackground = true
                    }
                }
        }
        .windowResizability(.contentSize)
    }
}
