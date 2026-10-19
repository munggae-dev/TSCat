# TSCat changes

Based on RunCat Neo revision 82d55b6 (full upstream history retained).

## 2026-10-20

- Added `ChargingInfo` and `ChargingInfoClient` to read battery-side power and charging estimates.
- Extended Metrics, AppDependencies, SystemMetricsService, Dashboard, and RunnerBar to pass charging information through the existing update stream.
- Updated RunnerBarView to render watts beside the cat and DashboardView to show the new ChargingInfoView.
- Added ChargingInfoTests covering power conversion, unavailable estimates, disconnection, signed/wrapped current, full charge, and paused charging.
- Updated the Xcode project and InfoPlist string catalog to use TSCat and an independent bundle identifier, removing the upstream signing team.
- Removed the upstream donation tab from SettingsView.
- Removed the inherited GitHub Actions workflow; public CI is not configured.
- Replaced the project README with fork-specific build instructions and limitations; added NOTICE and dependency license texts.

The local prototype was called RunCat Charge. Public TSCat builds use a different application identifier and do not automatically inherit that prototype's settings or login registration.
