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
    private var panel: NSPanel!
    private var hostingController: NSHostingController<AnyView>!
    private var outsideClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "ZeroBlue")
            button.action = #selector(togglePanel)
            button.target = self
        }

        panel = makePanel()

        let intensity = UserDefaults.standard.double(forKey: "zb.intensity")
        let enabled = UserDefaults.standard.object(forKey: "zb.enabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "zb.enabled")
        let zeroBlue = UserDefaults.standard.bool(forKey: "zb.zeroBlue")
        let zeroBlueOrange = UserDefaults.standard.object(forKey: "zb.zeroBlueOrange") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "zb.zeroBlueOrange")
        if enabled && zeroBlue {
            GammaController.applyZeroBlue(orange: zeroBlueOrange)
        } else if enabled {
            GammaController.apply(intensity: intensity == 0 ? 0.5 : intensity)
        }
    }

    private func makePanel() -> NSPanel {
        hostingController = NSHostingController(rootView: AnyView(ContentView().preferredColorScheme(.dark)))
        let size = hostingController.view.fittingSize
        hostingController.view.frame = NSRect(origin: .zero, size: size)

        let effect = NSVisualEffectView(frame: hostingController.view.frame)
        effect.material = .popover
        effect.state = .active
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 12
        effect.layer?.masksToBounds = true
        effect.autoresizingMask = [.width, .height]
        effect.addSubview(hostingController.view)

        let p = NSPanel(
            contentRect: effect.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.isFloatingPanel = true
        p.level = .popUpMenu
        p.hasShadow = true
        p.isOpaque = false
        p.backgroundColor = .clear
        p.contentView = effect
        return p
    }

    @objc private func togglePanel() {
        guard let button = statusItem.button, let buttonWindow = button.window else { return }
        if panel.isVisible {
            closePanel()
            return
        }

        let buttonFrameInScreen = buttonWindow.convertToScreen(button.frame)
        let size = hostingController.view.fittingSize
        let gap: CGFloat = 4
        let origin = NSPoint(
            x: buttonFrameInScreen.minX,
            y: buttonFrameInScreen.minY - size.height - gap
        )
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
        panel.orderFront(nil)

        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePanel()
        }
    }

    private func closePanel() {
        panel.orderOut(nil)
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
            outsideClickMonitor = nil
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        GammaController.reset()
    }
}
