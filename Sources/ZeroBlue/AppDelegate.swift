//
//  AppDelegate.swift
//  ZeroBlue
//
//  Created by Kevin Liao on 7/24/26.
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "ZeroBlue")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        
        let intensity = UserDefaults.standard.double(forKey: "zb.intensity")
        let enabled = UserDefaults.standard.object(forKey: "zb.enabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "zb.enabled")
        if enabled {
            GammaController.apply(intensity: intensity == 0 ? 0.5 : intensity)
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    func applicationWillTerminate(_ notification: Notification) {
        GammaController.reset()
    }
}
