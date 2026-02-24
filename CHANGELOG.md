## 3.0.1

### Fixed

- [Android] System bars are now hidden during scanning in the Flutter wrapper scan Activity to prevent scan instruction UI overlap with the navigation bar on some devices.

### Dependencies

Tire Tread SDK 14.0.1: [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#14-0-1)

## 3.0.0

### Breaking Changes

- **Updated to Anyline Tire Tread SDK 14.0.0**

- **UI Configuration API Change**: The `useDefaultUi` and `useDefaultHaptic` boolean properties in `UIConfig` have been replaced with a unified `appearance` enum property.

  **Migration Required**:
  - Replace `"useDefaultUi": true` with `"appearance": "Neon"` (or omit, as Neon is the new default)
  - Replace `"useDefaultUi": false` with `"appearance": "None"`

  **New Appearance Options**:
  - `"Neon"` - New neon UI appearance with haptic feedback (new default)
  - `"Classic"` - Classic UI appearance with haptic feedback (the previous default UI style)
  - `"None"` - Disables both UI and haptic feedback (replaces `useDefaultUi: false`)

### Added

- Support for new "Neon" UI theme with modern visual design
- Support for "Classic" UI theme (the previous default UI style)

### Deprecated

- [Android] The `skipButtonText` property in `TireWidthInputConfig` is now deprecated and will be removed in the next major SDK release. Tire width must be provided either via integration or through the SDK's UI input.

### Changed

- [Android] Build requirements increased:
  - Minimum Gradle version: 8.7 (up from 8.2.1)
  - Minimum Android Gradle Plugin: 8.5.1 (up from 8.2.1)
  - compileSdk: 36 (up from 34)
  - targetSdk: 36 (up from 34)
  - **Reason**: Compliance with Android 15+ page size requirements (see [Android Developer Guide](https://developer.android.com/guide/practices/page-sizes))

### Dependencies

Tire Tread SDK 14.0.0: [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#14-0-0)

## 2.0.2

### Fixed

- [Android] Fixed an issue that prevented the tire width to be set via the TireWidthInput screen.

### Dependencies

Tire Tread SDK 13.0: [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#13-0-3)

## 2.0.1

### Changed

- UI Behaviour is now aligned between Android and iOS. When the Default UI is disabled, no UI will be displayed neither on Android nor on iOS.

## 2.0.0

### Breaking Changes

- The `ScanOptions` class was removed.

  - The `tireTreadPlugin.scan()` function can now receive an instance of the new `TireTreadConfig` class to configure the Plugin instead.

### Added

- The `TireTreadConfig` class was introduced, enabling the configuration of a scan. It consists of:

  - `uiConfig`: Configuration for all UI-related settings and elements
  - `scanConfig`: Configuration for the scanning process parameters
  - `additionalContext`: Additional contextual information required for measurements

- The previous UI config properties have been reorganized under `uiConfig`:
  - `scanSpeed`
  - `measurementSystem`
  - `useDefaultUi`
  - `distanceIndicatorConfig`
  - `focusPointTooltipConfig`
  - `tapToStartScanningTooltipConfig`
  - `tireOverlayConfig`
  - `uploadViewConfig`
  - `orientationWarningConfig`
  - `countdownConfig`
  - `scanDirectionConfig`
  - `tireWidthInputConfig`
  - `missingPermissionConfig`

### Fixed

- Fixed a potential crash when parsing measurements with empty regional results
- Fixed NSInvalidArgumentException crash when using both the Anyline Mobile and Tire Tread SDKs in a single project.

### Dependencies

Tire Tread SDK 13.0: [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#13-0-2-2025-06-18)

## 1.2.1

### Added

- A new event is sent upon successfully starting scanning: `ScanStarted`.

### Fixed

- [Android] A `ScanAborted` event is now sent upon aborting a scan, even if the scan was not successfully started before.

### Dependencies

Tire Tread SDK 12.1.0 : [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#12-1-0-2025-04-23)

## 1.2.0

### Changed

- The default scan speed is now ScanSpeed.Fast.
  - The scan process will now, by default, take 7 seconds to be completed (instead of 10 seconds).
  - This configuration can still be changed by setting the scanSpeed property of the TireTreadScanView to ScanSpeed.Slow.

### Added

- The TireTreadScanView can now also be initialized without any config object/string.
  - In this scenario, the default config values will be used.
  - For more details, refer to the Scan Process - Overview page.

#### iOS

- Added support for iOS Simulator builds when using the SPM package
  - While the camera and scanning capabilites cannot be used in the simulator, the package from SPM now can also run on x64 and arm64 simulators, allowing running automated tests, or testing other features in your application.

### Dependencies

Tire Tread SDK 12.1.0 : [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#12-1-0-2025-04-23)

## 1.1.0

### Breaking Changes

#### Android

- Minimum required Gradle version and AGP version is 8.2.1

### Added

- Added a new MissingPermission screen to the DefaultUI, which can be configured via the MissingPermissionConfig
  - If DefaultUI is not used, a black screen will be shown, when the user denies camera permission.
- Added edge-to-edge support in the DefaultUI for Android API 35 and above

### Dependencies

Tire Tread SDK 12.0.1 : [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#12-0-1-2025-04-07)

## 1.0.0

This release officially marks the Anyline Tire Tread Flutter Plugin as feature complete, stable, and fully supported for the Anyline Tire Tread SDK.

### Added

- Introduced a new feature allowing users to send feedback values in 32" from the plugin. This will help us gather valuable insights and continuously improve the plugin.

### Fixed

- Resolved minor bugs to enhance overall performance and stability.

### Dependencies

Tire Tread SDK 11.2.0 : [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#11-2-0-2025-02-28)

## 0.0.3

### Added

- Introduced a new feature allowing users to send feedback comments directly from the plugin. This will help us gather valuable insights and continuously improve the plugin.

### Changed

- `tireTreadPlugin.getResult` now returns a `TreadDepthResult` object instead of a string. This change provides a more structured and detailed result.

### Fixed

- Resolved minor bugs to enhance overall performance and stability.

### Dependencies

Tire Tread SDK 11.1.0 : [Release Notes](https://documentation.anyline.com/tiretreadsdk-component/latest/release-notes.html#11-1-0-2025-02-13)

## 0.0.2

### Breaking Changes

#### Updated ScanEvent Handling:

There are changes in `ScanEvent` which now provides the current state of the scanning process. Some events have been removed and consolidated with new events:

- `UploadAborted` event has been removed and consolidated into `ScanAborted` to simplify communication with the app.
- `UploadCompleted` event has been removed and consolidated into `ScanProcessCompleted` to simplify communication with the app.
- `UploadFailed` event has been removed and consolidated into `ScanFailed` to simplify communication with the app.

## 0.0.1

- Initial stable release of the Anyline Tire Tread Flutter Plugin.

## 0.0.1-alpha.3

- Fix pub.dev scores.

## 0.0.1-alpha.2

- Fix pub.dev scores.

## 0.0.1-alpha.1

- Initial alpha release of the Anyline Tire Tread Flutter Plugin. Please see the included Readme.md for details and usage instructions.
