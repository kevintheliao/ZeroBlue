//
//  GammaController.swift
//  ZeroBlue
//
//  Created by Kevin Liao on 7/24/26.
//
import CoreGraphics

enum GammaController {
    static func apply(intensity: Double) {
        let clamped = min(max(intensity, 0), 1)
        let blueMax = Float(1.0 - clamped * 0.85)
        let greenMax = Float(1.0 - clamped * 0.45)

        for display in activeDisplay() {
            CGSetDisplayTransferByFormula(
                display,
                0.0, 1.0, 1.0,
                0.0, greenMax, 1.0,
                0.0, blueMax, 1.0
            )
        }
    }

    static func applyZeroBlue(orange: Bool) {
        if orange {
            for display in activeDisplay() {
                CGSetDisplayTransferByFormula(
                    display,
                    0.0, 1.0, 1.0,
                    0.0, 0.55, 1.0,
                    0.0, 0.0, 1.0
                )
            }
            return
        }
        // Gray needs R≈G≈B for a blue pixel's output, but a blue UI color's
        // red/green input starts near 0 - scaling alone can't lift a 0
        // input, so a floor (redMin/greenMin) is required to bring red and
        // green up to meet blue instead of leaving blue dominant. Blue
        // itself is pinned to 0/0 so no blue light ever reaches the panel.
        for display in activeDisplay() {
            CGSetDisplayTransferByFormula(
                display,
                0.3, 0.6, 1.0,
                0.1, 0.6, 1.0,
                0.0, 0.0, 1.0
            )
        }
    }

    static func reset() {
        CGDisplayRestoreColorSyncSettings()
    }
    
    private static func activeDisplay() -> [CGDirectDisplayID] {
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)
        guard displayCount > 0 else { return [] }
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &displays, &displayCount)
        return displays
    }
}
