//
//  StatusBarController.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2024-05-19.
//

import SwiftUI

@MainActor
class StatusBarController {
    static let shared = StatusBarController()

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private init() {
        statusItem.button?.image = NSImage(systemSymbolName: "server.rack", accessibilityDescription: "TopUI")

        let menu = NSMenu()
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)

        statusItem.menu = menu
    }
}

private extension StatusBarController {
    @MainActor
    @objc
    func quit() {
        NSApp.terminate(nil)
    }
}
