//
//  AppDelegate.swift
//  TopUI
//
//  Created by Ghislain Leblanc on 2024-05-19.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarController = StatusBarController.shared
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
}
