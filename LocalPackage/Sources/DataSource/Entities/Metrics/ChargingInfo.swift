// Copyright 2026 TSCat contributors
// SPDX-License-Identifier: Apache-2.0
// Added for TSCat: battery charging information and tests.
import Foundation

/// Battery-side power, not the adapter's rated output or total Mac power draw.
public struct ChargingInfo: Sendable, Equatable {
    public var isConnected: Bool
    public var isCharging: Bool
    public var isFull: Bool
    public var watts: Double?
    public var minutesToFull: Int?

    public init(properties: [String: Any]) {
        isConnected = properties["ExternalConnected"] as? Bool ?? false
        isCharging = isConnected && (properties["IsCharging"] as? Bool ?? false)
        isFull = properties["FullyCharged"] as? Bool ?? false
        if isCharging,
           let voltage = properties["Voltage"] as? NSNumber,
           let current = (properties["InstantAmperage"] ?? properties["Amperage"]) as? NSNumber,
           voltage.doubleValue > 0, current.int64Value > 0,
           current.int64Value < 100_000, voltage.doubleValue < 100_000 {
            watts = voltage.doubleValue * current.doubleValue / 1_000_000
        }
        // 65535 is the firmware's unknown-time sentinel; zero is not an ETA.
        if isCharging, !isFull,
           let minutes = properties["AvgTimeToFull"] as? NSNumber,
           (1..<65535).contains(minutes.intValue) {
            minutesToFull = minutes.intValue
        }
    }
}
