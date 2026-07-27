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
    @AppStorage("zb.zeroBlue") private var zeroBlue: Bool = false
    @AppStorage("zb.zeroBlueOrange") private var zeroBlueOrange: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Filter enabled", isOn: $enabled)
                .onChange(of: enabled) { _ in update() }

            Text ("Intensity: \(Int(intensity * 100))")
            Slider(value: $intensity, in: 0...1)
                .onChange(of: intensity) { _ in update() }
                .disabled(!enabled || zeroBlue)

            HStack {
                presetButton("Low", 0.25)
                presetButton("Medium", 0.5)
                presetButton("High", 0.8)
            }

            Divider()

            Toggle("Zero Blue mode", isOn: $zeroBlue)
                .onChange(of: zeroBlue) { _ in update() }
                .disabled(!enabled)

            Picker("Tint", selection: $zeroBlueOrange) {
                Text("Orange").tag(true)
                Text("Green").tag(false)
            }
            .pickerStyle(.segmented)
            .disabled(!enabled || !zeroBlue)
            .onChange(of: zeroBlueOrange) { _ in update() }

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
            zeroBlue = false
            update()
        }
    }

    private func update() {
        guard enabled else {
            GammaController.reset()
            return
        }
        if zeroBlue {
            GammaController.applyZeroBlue(orange: zeroBlueOrange)
        } else {
            GammaController.apply(intensity: intensity)
        }
    }
}
