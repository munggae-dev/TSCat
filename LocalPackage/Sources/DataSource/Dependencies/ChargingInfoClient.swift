// Copyright 2026 TSCat contributors
// SPDX-License-Identifier: Apache-2.0
// Added for TSCat: battery charging information and tests.
import IOKit

public struct ChargingInfoClient: DependencyClient {
    public var current: @Sendable () -> ChargingInfo?

    public static let liveValue = Self(current: {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != IO_OBJECT_NULL else { return nil }
        defer { IOObjectRelease(service) }
        var properties: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let values = properties?.takeRetainedValue() as? [String: Any],
              values["BatteryInstalled"] as? Bool == true else { return nil }
        return ChargingInfo(properties: values)
    })

    public static let testValue = Self(current: { nil })
}
