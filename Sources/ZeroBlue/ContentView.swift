//
//  ContentView.swift
//  ZeroBlue
//
//  Created by Kevin Liao on 7/24/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("zb.intensity") private var intensity: Double = 0.5
    @AppStorage("zb.enabled") private var enabled: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Filter enabled", isOn: $enabled)
                .onChange(of: enabled) { _ in update() }
            
            Text ("Intensity: \(Int(intensity * 100))")
            Slider(value: $intensity, in: 0...1)
                .onChange(of: intensity) { _ in update() }
                .disabled(!enabled)
            
            HStack {
                presetButton("Low", 0.25)
                presetButton("Medium", 0.5)
                presetButton("High", 0.8)
            }
            
            Button("Quit ZeroBlue") {
                GammaController.reset()
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 240)
        .onAppear { update() }
    }
    private func presetButton(_ label: String, _ value: Double) -> some View
    {
        Button(label) {
            intensity = value
            enabled = true
            update()
        }
    }
    
    private func update() {
        if enabled {
            GammaController.apply(intensity: intensity)
        } else {
            GammaController.reset()
        }
    }
}
