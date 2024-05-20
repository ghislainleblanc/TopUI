//
//  StatusBarController.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2024-05-19.
//

import AppKit
import SwiftUI

class StatusBarController {
    static let shared = StatusBarController()

    private var statusItem: NSStatusItem?
    private var popover = NSPopover()

    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "server.rack", accessibilityDescription: nil)
            button.action = #selector(togglePopover(_:))
        }

        popover.contentSize = NSSize(width: 300, height: 300)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        let menu = NSMenu()
        let showAppMenuItem = NSMenuItem(title: "Show", action: #selector(togglePopover(_:)), keyEquivalent: "")
        showAppMenuItem.target = nil // Ensure the action looks up the responder chain
        menu.addItem(showAppMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = nil // Ensure the action looks up the responder chain
        menu.addItem(quitMenuItem)

        statusItem?.menu = menu
    }
}

private extension StatusBarController {
    @objc
    func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    @objc
    func quit() {
        NSApp.terminate(nil)
    }
}
