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
        let greenMax = Float(1.0 - clamped * 0.25)
        
        for display in activeDisplay() {
            CGSetDisplayTransferByFormula(
                display,
                0.0, 1.0, 1.0,
                0.0, greenMax, 1.0,
                0.0, blueMax, 1.0
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
