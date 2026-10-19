# TSCat

A macOS menu bar cat with battery charging power and an estimated time to full charge.

**TSCat is an independent, unofficial derivative of [RunCat Neo](https://github.com/runcat-dev/RunCatNeo), created by Takuto Nakamura (Kyome22). It is not endorsed by or affiliated with the upstream developers.** The local prototype was named RunCat Charge; the public project uses TSCat.

## Features

- Shows battery charging power in watts beside the animated cat while charging.
- Shows the system-provided estimated time to full charge in the dashboard.
- Distinguishes charging, charge complete, charging paused, and unavailable estimates.
- Retains the upstream runner animation, system metrics, and custom metric features.

Power is calculated from battery voltage and current. It is **battery-side power**, not the adapter's rated output or total power drawn by the Mac. Estimates depend on macOS and battery firmware, may change, and are not guarantees. Missing estimates show a calculating status. New charging status text is currently Korean.

## Build

Install a full Xcode distribution compatible with the project and its dependencies (Swift 6.2 or later). Command Line Tools alone are insufficient. The project targets macOS 26.0 or later; validation was performed on the developer's Mac, not every supported system.

Open `RunCatNeo.xcodeproj` and select the `RunCatNeo` scheme. These internal project names are retained from upstream. The built app is named **TSCat**, with bundle identifier `io.github.munggae-dev.TSCat`. Select your own signing team when needed.

For an unsigned local build:

```sh
xcodebuild -project RunCatNeo.xcodeproj -scheme RunCatNeo \
  -configuration Debug -derivedDataPath DerivedData \
  -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO build
```

Output: `DerivedData/Build/Products/Debug/TSCat.app`.

This repository publishes source code. No notarized installer or App Store release is provided. The upstream App Store listing distributes RunCat Neo, not TSCat.

## Validation and limitations

- The public TSCat configuration built successfully with full Xcode on 2026-10-20.
- Five charging logic tests passed (including unknown-time parameter cases).
- Live battery readings were obtained on one Mac.
- Automated visual verification and physical charger connect/disconnect testing remain incomplete.
- Battery telemetry uses AppleSmartBattery registry fields and may be unavailable on other hardware or OS versions.

The test source is `LocalPackage/Tests/DataSourceTests/EntityTests/ChargingInfoTests.swift`.

## License and attribution

Licensed under [Apache License 2.0](LICENSE). Original copyright and attribution notices are retained. See [NOTICE](NOTICE), [CHANGES.md](CHANGES.md), and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Modified source files carry change notices. Original source, bundled runner assets, and upstream history are retained with their notices. Upstream documentation under `docs/` describes the original project and is retained as reference; its download, support, and donation links refer to upstream, not TSCat. TSCat removes the upstream in-app donation tab.

The license does not grant rights to upstream trademarks. References to RunCat Neo identify the origin of this work.
