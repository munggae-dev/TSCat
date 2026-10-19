// Copyright 2026 TSCat contributors
// SPDX-License-Identifier: Apache-2.0
// Added for TSCat: battery charging information and tests.
import Foundation
import Testing
@testable import DataSource

struct ChargingInfoTests {
    @Test func chargingPowerUsesBatteryVoltageAndCurrent() {
        let info = ChargingInfo(properties: [
            "ExternalConnected": true, "IsCharging": true,
            "Voltage": 11582, "InstantAmperage": 3324, "AvgTimeToFull": 153,
        ])
        #expect(abs((info.watts ?? 0) - 38.498568) < 0.000001)
        #expect(info.minutesToFull == 153)
    }

    @Test(arguments: [0, -1, 65535])
    func unknownTimeIsNotShownAsAnEstimate(minutes: Int) {
        let info = ChargingInfo(properties: [
            "ExternalConnected": true, "IsCharging": true, "AvgTimeToFull": minutes,
        ])
        #expect(info.minutesToFull == nil)
    }

    @Test func disconnectedBatteryDoesNotShowStaleChargingReadings() {
        let info = ChargingInfo(properties: [
            "ExternalConnected": false, "IsCharging": true,
            "Voltage": 12000, "Amperage": 3000, "AvgTimeToFull": 60,
        ])
        #expect(!info.isCharging)
        #expect(info.watts == nil)
        #expect(info.minutesToFull == nil)
    }

    @Test func negativeOrUnsignedWrappedCurrentIsNotChargingPower() {
        for current in [NSNumber(value: -2500), NSNumber(value: UInt64.max - 2499)] {
            let info = ChargingInfo(properties: [
                "ExternalConnected": true, "IsCharging": true,
                "Voltage": 12000, "Amperage": current,
            ])
            #expect(info.watts == nil)
        }
    }

    @Test func fullAndPausedBatteryHaveNoETA() {
        let full = ChargingInfo(properties: [
            "ExternalConnected": true, "IsCharging": false, "FullyCharged": true,
            "AvgTimeToFull": 12,
        ])
        #expect(full.isFull)
        #expect(full.minutesToFull == nil)
        let paused = ChargingInfo(properties: ["ExternalConnected": true, "IsCharging": false])
        #expect(paused.isConnected && !paused.isCharging && !paused.isFull)
        #expect(paused.watts == nil)
    }
}
