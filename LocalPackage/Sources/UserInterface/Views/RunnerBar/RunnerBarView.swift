// Modified for TSCat (2026-10-20): battery charging display and independent fork configuration.
/*
 RunnerBarView.swift
 UserInterface

 Created by Takuto Nakamura on 2026/05/08.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Model
import SwiftUI

// The runner is animated by a CAKeyframeAnimation on `runnerLayer` instead of swapping the
// MenuBarExtra icon frame by frame. Every icon swap makes the menu bar snapshot the status item in
// both light and dark appearance for the other monitors, which measured 7-8% CPU constantly when
// this was last profiled, against about 0.1% for the layer-based animation.
//
// The trade-off is that the animation renders only on the active monitor, leaving an empty gap on
// the others, so `iconImage` is drawn as a static fallback. On the active monitor `backgroundLayer`
// erases it again via sourceOutCompositing, so the two never overlap. That filter does not work on
// Intel Macs, where `backgroundLayer` is therefore not installed and the gap stays empty.
struct RunnerBarView: View {
    @StateObject var store: RunnerBar

    private var iconImage: NSImage {
#if arch(arm64)
        let icon = store.icon
#endif
        let power = store.chargingInfo.flatMap { info in
            info.isCharging ? info.watts.map { String(format: "%.1f W", $0) } : nil
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.labelColor,
        ]
        let textSize = power.map { ($0 as NSString).size(withAttributes: attributes) } ?? .zero
        let runnerSize = store.size
        let size = CGSize(width: runnerSize.width + (power == nil ? 0 : textSize.width + 6),
                          height: runnerSize.height)
        let nsImage = NSImage(size: size, flipped: true) { rect in
#if arch(arm64)
            icon?.draw(in: CGRect(origin: .zero, size: runnerSize))
#endif
            if let power {
                (power as NSString).draw(
                    at: CGPoint(x: runnerSize.width + 6, y: (rect.height - textSize.height) / 2),
                    withAttributes: attributes
                )
            }
            return true
        }
        nsImage.isTemplate = store.isTemplate
        return nsImage
    }

    var body: some View {
        Label {
            Text(verbatim: "\0")
        } icon: {
            Image(nsImage: iconImage)
        }
        .labelStyle(isReady: store.isReady)
        .task {
            guard !store.isReady,
                  let statusBarButton = NSApp.statusBarButton(withTitle: "\0"),
                  let window = statusBarButton.window else {
                return
            }
            statusBarButton.tag = .zero
            let gap = 0.5 * statusBarButton.bounds.width
            statusBarButton.wantsLayer = true
            let backgroundLayer = BackgroundLayer(gap: gap)
#if arch(arm64)
            statusBarButton.layer?.addSublayer(backgroundLayer)
#endif
            let runnerLayer = RunnerLayer(gap: gap)
            statusBarButton.layer?.addSublayer(runnerLayer)
            StatusBarAppearanceBridge.shared.send(window.effectiveAppearance)
            await store.send(.viewAppeared(
                String(describing: Self.self),
                .init(
                    getBundleImage: { NSImage(resource: .init(name: $0, bundle: .module)) },
                    setSize: { backgroundLayer.setSize($0) },
                    setFrames: { runnerLayer.setFrames($0, $1) },
                    setColor: { runnerLayer.setColor($0, $1) },
                    setSpeed: { runnerLayer.setSpeed($0) }
                )
            ))
        }
        // This will not be called within the MenuBarExtra lifecycle,
        // but I am including it here for the sake of formality.
        .onDisappear {
            Task {
                await store.send(.viewDisappeared)
            }
        }
    }
}

extension RunnerBar: ObservableObject {}
