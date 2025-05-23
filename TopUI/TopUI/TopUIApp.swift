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

    @State private var contentViewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
                .onAppear {
                    for window in NSApplication.shared.windows {
                        window.styleMask = [.borderless]
                        window.isOpaque = false
                        window.level = .floating
                        window.titleVisibility = .hidden
                        window.titlebarAppearsTransparent = true
                        window.isMovableByWindowBackground = true
                        window.backgroundColor = .clear
                        window.contentView?.wantsLayer = true
                        window.contentView?.layer?.cornerRadius = 20
                        window.contentView?.layer?.masksToBounds = true
                    }
                }
        }
        .windowResizability(.contentSize)
    }
}
