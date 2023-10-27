//
//  TopUIApp.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2023-10-24.
//

import SwiftUI

@main
struct TopUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400, height: 460)
                .onAppear {
                    for window in NSApplication.shared.windows {
                        window.level = .floating
                    }
                }
        }
        .windowResizability(.contentSize)
    }
}
