# Anyline Tire Tread Flutter Plugin

This Flutter plugin provides an interface to the Anyline Tire Tread SDK, allowing you to integrate tire tread scanning capabilities into your Flutter applications.

## Requirements

This SDK requires devices with advanced camera capabilities that provide depth/distance information such as *lens focus distance*. Not all devices support this feature. We recommend testing on your target devices to verify compatibility. In order to use the Anyline Tire Tread SDK Flutter Plugin, please see to it that the following requirements are met:

### Android

#### Device

- Android 6.0 - Marshmallow - or newer (API level 23+)
- Decent camera functionality (recommended: ≥ 1080p and adequate **auto focus**)
- 'Flash' capability
- Stable internet connection

#### Environment

Your development/application environment is required to have at least the following tools and versions (or newer) available:

- JDK 17
- Gradle 8.7 (minimum required by Tire Tread SDK 14.0.0+)
  - id 'com.android.application' version '8.7.3' apply false
- Android Gradle Plugin 8.5.1+ (minimum required by Tire Tread SDK 14.0.0+)
- Kotlin 2.0.21
  - id 'org.jetbrains.kotlin.android' version '2.0.21' apply false
- compileSdk 36 (Android 15, required for 16KB page size compliance)
  - android { compileSdk 36 ...
- targetSdk 36
  - android { targetSdk 36 ...
- minSdk 23
  - ... minSdk 23 ...

> **Note**: Tire Tread SDK 15.0.0+ requires Gradle 8.7+ and AGP 8.5.1+ for Android 15 compliance (16KB page sizes).

### iOS

- iOS Version >= 13.4
- Stable internet connection
- 'Flash' capability

## How it works

The Anyline Tire Tread SDK processes scans asynchronously. Once a scan is completed, the SDK uploads and processes the scan data in the background, allowing integrators to benefit from this behavior.

After initiating and completing a scan, your application can continue with any desired workflow without needing to wait for immediate results. When you need to access the results, such as measurement data or heatmaps, simply query them using the `getResult` or `getHeatMap` methods with the relevant `measurementUUID`.

This design enhances the user experience by keeping the application responsive and separating the scanning process from result retrieval.

## Anyline Tire Tread Flutter Plugin Guide

In this guide, we want to show you how you can make the most out of Anyline Tire Tread using our Flutter plugin. Feel free to contact us if you feel that it is incomplete or particular sections need elaboration.

### Get an Anyline License

To be able to use the Flutter plugin you will have to get a license key by following the steps detailed in our [documentation](https://documentation.anyline.com/main-component/license-key-generation.html).

### Install the Anyline Tire Tread Plugin

Add the following dependency to your `pubspec.yaml` :

```yaml dependencies:
anyline_tire_tread_plugin: ^x.y.z
```

### Add the Anyline Tire Tread SDK as dependency

To integrate the Anyline Tire Tread SDK into your Android project, follow these steps:

- Open your project in Android Studio.
- Locate the build.gradle file of your project. This file is typically found in the root directory of your project.
- Add the Anyline Maven registry to your repositories section. This allows your project to access the Anyline Tire Tread SDK from the specified Maven repository. Update your repositories block to include the Anyline Maven registry URL:

```bash
repositories {
    // ... your other repositories ...
    mavenCentral()
    // Anyline Maven registry
    maven { url "https://europe-maven.pkg.dev/anyline-ttr-sdk/maven" }
}
```

> **_NOTE:_** Find more information about adding Anyline Tire Tread SDK as dependency [here](https://documentation.anyline.com/tiretreadsdk-component/latest/android/getting-started.html#add-the-anyline-tire-tread-sdk-as-dependency).

### Install via pub.dev

Install the package dependencies from the command line:  
`bash flutter pub get `  
Alternatively, your IDE might support `flutter pub get`. Check their documentation to learn more.

### Import Anyline into your Flutter project

Now in your Dart code, bring in Anyline with the following import:

```dart
import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
```

With this import, you can use the `TireTreadPlugin` class to call methods accessing the SDK and scanning functionality. Proceed by creating an object of this class:

```dart
var tireTreadPlugin = TireTreadPlugin();
```

### Check device support

Before initializing, you can verify that the current device meets the hardware requirements for tire tread scanning. `isDeviceSupported()` returns a `bool`:

```dart
final supported = await tireTreadPlugin.isDeviceSupported();
if (!supported) {
  // This device can't run tire tread scanning.
}
```

> **_NOTE:_** On Android, this check requires the camera permission — it throws a `PlatformException` with code `CAMERA_PERMISSION_DENIED` if it hasn't been granted at call time.

#### Automatic camera permission (Android)

For the SDK to request the camera permission **automatically** when you call `isDeviceSupported()`, your Android host activity must extend `FlutterFragmentActivity` instead of the default `FlutterActivity`:

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

If you keep `FlutterActivity`, request the camera permission yourself before calling `isDeviceSupported()`. This is only needed for `isDeviceSupported()` — the tread and sidewall **scanners request the camera permission themselves** and do **not** require it.

### Initialize the SDK

During app startup, before calling any other plugin method, initialize the Anyline Tire Tread SDK by calling the plugin object’s `initialize` method, providing it with your license key:

```dart
try {
    await tireTreadPlugin.initialize(licenseKey);
} catch (error) {
    print("error initializing Anyline Tire Tread SDK: $error");
}
```

Optionally, you can provide a custom tag that will be attached to all measurements:

```dart
await tireTreadPlugin.initialize(licenseKey, customTag: 'my-custom-tag');
```

### Start scanning

With an instance of `TireTreadPlugin`, call `scan` on it with the config options. The returned `Future` completes with a `ScanOutcome` once the scan finishes, is aborted, or fails:

```dart
scanWithAnyline() async {
  final outcome = await tireTreadPlugin.scan(config: TireTreadConfig());
  switch (outcome) {
    case ScanCompleted():
      // Results can now be queried with outcome.measurementUUID
      print('Scan completed: ${outcome.measurementUUID}');
    case ScanAborted():
      print('Scan aborted by the user');
    case ScanFailed():
      print('Scan failed [${outcome.error.code.name}]: ${outcome.error.message}');
  }
}
```

You can additionally pass `ScanOptions`, e.g. to enable verbose SDK debug logging:

```dart
await tireTreadPlugin.scan(
  config: TireTreadConfig(),
  options: ScanOptions(enableDebugLogging: true),
);
```

### Audio Feedback

The Tire Tread Plugin can provide audio feedback to guide users through the scan process.

To make use of these audio feedbacks, your application needs to provide the audio files inside the below folders.

1. path_to_plugin_root_folder/example/ios/Resources for iOS
2. path_to_plugin_root_folder/example/android/app/src/main/assets for Android

The audio feedbacks (with their respective files names) on iOS/Android are played on:

Focus Point Found

`tiretread_focuspoint_found.wav`

Scan Started

`tiretread_sound_start.wav`

Scan Stopped

`tiretread_sound_stop.wav`

Phone too close to the Tire

`tiretread_sound_beep_too_close.wav`

Phone too distant from the Tire

`tiretread_sound_beep_too_far.wav`

The SDK only supports these file names, and the .wav extension.

### Configuring the scanning behavior

You can customize how the scanning behavior works by passing in a `TireTreadConfig` object to the `scan` call:

```dart
tireTreadPlugin.scan(config: TireTreadConfig());
```

A `TireTreadConfig` object, constructed without parameters, contains sensible defaults to help you get quickly started. If you're interested in the defaults being used, please consult the documentation here: https://documentation.anyline.com/tiretreadsdk-component/latest/scan-process/overview.html

#### Tire Width Configuration

You can specify the tire width through the scan configuration:

```dart
var config = TireTreadConfig()
  ..scanConfig = (ScanConfig()..tireWidth = 185);
await tireTreadPlugin.scan(config: config);
```

#### Basic UI Configuration

You can configure UI options by setting properties directly on the `TireTreadConfig`'s `uiConfig` object:

```dart
var config = TireTreadConfig()
  ..uiConfig = (UiConfig()
    ..measurementSystem = MeasurementSystem.Imperial
    ..scanSpeed = ScanSpeed.Fast);
await tireTreadPlugin.scan(config: config);
```

#### Full UI Configuration

If needed, you can customize all UI elements and messages displayed during the scanning process:

```dart
var config = TireTreadConfig()
  ..uiConfig = (UiConfig()
    ..measurementSystem = MeasurementSystem.Metric
    ..scanSpeed = ScanSpeed.Fast
    ..distanceIndicatorConfig = (DistanceIndicatorConfig()
      ..textMoveAway = 'Move device away'
      ..textMoveCloser = 'Move device closer'
      ..textOk = 'Hold distance')
    ..focusPointTooltipConfig = (FocusPointTooltipConfig()
      ..text = 'Locating tire...'
      ..smallText = 'Move device closer')
    ..tapToStartScanningTooltipConfig = (TapToStartScanningTooltipConfig()
      ..textNotOkImperial = 'Hold device 8in from tire to start.'
      ..textNotOkMetric = 'Hold device 20cm from tire to start.'
      ..textOk = 'Tap to start recording')
    ..uploadViewConfig = (UploadViewConfig()..text = 'Uploading...')
    ..orientationWarningConfig = (OrientationWarningConfig()
      ..text = 'Rotate device horizontally'
      ..rotationLockHint = 'Make sure auto-rotation is enabled.')
    ..missingPermissionConfig = (MissingPermissionConfig()
      ..title = 'Missing permissions'
      ..text = 'Please grant necessary permissions to use this feature.')
    ..tireWidthInputConfig = (TireWidthInputConfig()
      ..continueButtonText = 'Continue'
      ..explanationText = 'Choose tire width from options or enter manually.'
      ..titleText = 'Tire width'));
await tireTreadPlugin.scan(config: config);
```

#### Additional Context Configuration

You can provide additional context information including tire position and correlation ID:

```dart
var config = TireTreadConfig()
  ..additionalContext = (AdditionalContext()
    ..tirePosition = (TirePosition()
      ..axle = 1
      ..positionOnAxle = 2
      ..side = TireSide.Left)
    ..correlationId = '00000000-0000-0000-0000-000000000000'); // Make sure to only provide valid UUIDs!
await tireTreadPlugin.scan(config: config);
```

#### JSON Configuration

Alternatively, you can load configuration from a JSON file:

```dart
// Load from JSON file
TireTreadConfig config = TireTreadConfig();
var data = await rootBundle.loadString('assets/config.json');
var jsonData = jsonDecode(data) as Map<String, dynamic>;
config = TireTreadConfig.fromJson(jsonData);
await tireTreadPlugin.scan(config: config);
```

More information about the JSON configuration can be found here: https://documentation.anyline.com/tiretreadsdk-component/latest/scan-configuration.html

## Handling the scan outcome

> **_NOTE:_** The event stream (`onScanningEvent`) from plugin 3.x was removed in 4.0.0. The `scan` `Future` now completes directly with a `ScanOutcome` — see [Start scanning](#start-scanning).

A `ScanOutcome` is one of:

```dart
switch (outcome) {
  case ScanCompleted():
    // measurementUUID is non-null; use it to query results
    debugPrint('measurementUUID : ${outcome.measurementUUID}');
  case ScanAborted():
    // The user cancelled the scan; measurementUUID may be null
    debugPrint('measurementUUID : ${outcome.measurementUUID}');
  case ScanFailed():
    // error is a structured SdkError (code, type, message, debug)
    debugPrint('error : ${outcome.error.code.name} - ${outcome.error.message}');
}
```

## Results

### Obtaining the Measurement Results

After a scan completes (a `ScanCompleted` outcome), your measurement results may still take a few seconds to become available. To fetch the results, call the function `getResult`:

```dart
TreadDepthResult? result = await tireTreadPlugin.getResult(measurementUUID: measurementUUID);
```

`getResult` polls until the result is available; you can optionally adjust the polling timeout (default: 60 seconds) with `timeoutSeconds`.

## User Corrected Values and Comments

### User Comments

To send a comment on a measurement, use the `sendFeedbackComment` function of the TireTreadPlugin.

```dart
await tireTreadPlugin.sendFeedbackComment(measurementUUID: _uuid, comment: comment);
```

### User Corrected Region Values

To send user corrected region values, use the `sendTreadDepthResultFeedback` function from the TireTreadPlugin. The result feedback should be provided as a list of `TreadResultRegion`, ordered from left to right.

> **_IMPORTANT:_** You can only provide feedback for the regions returned by the SDK in the `TreadDepthResult` object.
> The values of all regions need be added to the list before sending the feedback.

The TreadResultRegion objects can be initialized with Millimeters or Inches, e.g.:

```dart
TreadResultRegion regionMm = TreadResultRegion.initMm(available: true,valueMm: 1.2);
TreadResultRegion regionInch = TreadResultRegion.initInch(available: true,valueInch: 0.047);

List<TreadResultRegion>  myCorrectedResults =  [regionMm, regionInch];

await tireTreadPlugin.sendTreadDepthResultFeedback(measurementUUID: _uuid, resultRegions: myCorrectedResults);
```

## Error Handling

Tire Tread SDK 15 reports structured errors. Scan failures are delivered as a `ScanFailed` outcome carrying an `SdkError` (`code`, `type`, `message`, and optional `debug` details). All other methods (`initialize`, `getResult`, `getHeatMap`, feedback methods) throw a `PlatformException` whose `code` is the name of the SDK `ErrorCode` (e.g. `INVALID_LICENSE`, `NO_CONNECTION`, `TIMEOUT`).

The possible error codes are defined by the `ErrorCode` enum (e.g. `invalidLicense`, `licenseKeyForbidden`, `invalidArgument`, `initializationFailed`, `sdkNotInitialized`, `alreadyRunning`, `cameraPermissionDenied`, `measurementError`, `resultError`, `heatmapError`, `noConnection`, `uploadFailed`, `timeout`, `internalError`, `unknownError`), grouped into `ErrorType` categories (`licenseError`, `configError`, `networkError`, `scanError`, `resultError`).

## Analytics

### Heatmap

After a scan completes (a `ScanCompleted` outcome), your heatmap result may still take a few seconds to become available. To fetch the heatmap, call the function `getHeatMap`. It returns the **URL** of the generated heatmap image:

```dart
String? heatmapUrl = await tireTreadPlugin.getHeatMap(measurementUUID: measurementUUID);
```

`getHeatMap` polls until the heatmap is available; you can optionally adjust the polling timeout (default: 60 seconds) with `timeoutSeconds`.

## Tire Sidewall (TSW) Scanner

The Tire Sidewall scanner reads a tire's sidewall markings (e.g. the tire size) end to end. It presents a guided, full-screen camera experience, **captures the sidewall automatically** once it is correctly framed, uploads the photo to the Anyline Cloud API on your behalf, and returns the structured reading together with the captured image. It is a separate scanner from tire tread and does **not** require `initialize()`.

### What you need

- A **Cloud API client ID** — a string that authenticates the upload to the Anyline Cloud API. This is **separate** from your SDK license key and is provided by Anyline.
- **Camera permission.** The scanner requests it at runtime (no special Android host-activity setup required). On iOS, add an `NSCameraUsageDescription` entry to your `Info.plist`.

### Create the plugin

```dart
import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';

final tireSidewallPlugin = TireSidewallPlugin();
```

### Check device support (optional)

`isSupported()` reports whether the device can run the sidewall scanner and does not require initialization. On Android, if the failure is user-resolvable (e.g. Google Play Services needs updating), call `resolvePlayServices()` to show the system dialog. On iOS it is always supported.

```dart
final support = await tireSidewallPlugin.isSupported();
if (!support.supported) {
  if (support.userResolvable) await tireSidewallPlugin.resolvePlayServices();
  return;
}
```

### Start a scan

Call `scan` with your Cloud API client ID (and an optional `TireSidewallConfig`). The returned `Future` completes once with a `TswScanOutcome`:

```dart
final outcome = await tireSidewallPlugin.scan(clientId: '<YOUR_CLOUD_API_CLIENT_ID>');
switch (outcome) {
  case TswScanCompleted():
    final reading = outcome.resultJson;   // raw cloud reading (JSON string)
    final image = outcome.imageBytes;     // captured image (Uint8List), e.g. Image.memory(image)
    final lighting = outcome.lighting;    // EnvironmentLighting? — Dark / Bright / Good / null
  case TswScanAborted():
    // the user dismissed the scanner before a capture was taken
  case TswScanFailed():
    // outcome.error is a structured SdkError (code, type, message)
    debugPrint('${outcome.error.code.name}: ${outcome.error.message}');
}
```

The captured `imageBytes` is returned in **3:4 (portrait)** orientation — size any preview accordingly. Parse `resultJson` with your JSON library of choice.

### Configuration (optional)

Pass a `TireSidewallConfig` to override the defaults:

```dart
final config = TireSidewallConfig()
  ..correlationId = '00000000-0000-0000-0000-000000000000' // optional, v4 UUID
  ..texts = (TireSidewallTexts()..alignTire = 'Align the tire'); // optional overlay-string overrides
final outcome = await tireSidewallPlugin.scan(clientId: clientId, config: config);
```

- `correlationId` — an optional **version-4 UUID** used to correlate this scan with a matching Tire Tread scan (the same value is available on the tread scan's `AdditionalContext`). An invalid value fails the scan with `INVALID_UUID`.
- `texts` — overridable strings shown on the scanner overlay (`alignTire`, `holdSteady`, …); any field you leave unset keeps its English default.

### Errors

A `TswScanFailed` carries a structured `SdkError`. Codes a sidewall scan can surface include `INVALID_LICENSE` (client ID missing, invalid, or unauthorized), `CAMERA_PERMISSION_DENIED`, `NO_CONNECTION` / `TIMEOUT`, `UPLOAD_FAILED`, `INVALID_UUID`, and `ALREADY_RUNNING`. See [Error Handling](#error-handling) for the `SdkError` structure.

## Experimental Flags (internal use only)

When a new TTR SDK feature is implemented, it’s sometimes put behind an experimental flag. This enables the engineering team to provide new features to you more quickly, while still being able to change feature APIs before they move to a stable release. The experimental flag is then removed once the feature moves to a stable release.

Using functionality that’s behind an experimental flag requires you to enable the flag, or flags, in your application.

You should always enable/disable the experimental flags before using the functionality provided by it. Changing flags in the middle of the process might result in unexpected behaviour.

> **_WARNING:_** Consuming functionality that’s behind an experimental flag might result in unwanted behaviour in your application.

### Enabling flags

To enable an experimental flag in your project, use the `setExperimentalFlags` function of the TireTreadPlugin.

```dart
await tireTreadPlugin.setExperimentalFlags(experimentalFlags:[ExperimentalFlags.ExperimentalContinuousPictureFocusMode, "Another_Flag_Name"]);
```

> **_NOTE:_** Trying to set a flag that does not exist will not produce any effect, and the flag will be ignored. You will not be notified.

### Removing flags

To remove all experimental flags from your project, use the `clearExperimentalFlags` function of the TireTreadPlugin.

```dart
await tireTreadPlugin.clearExperimentalFlags();
```

### Experimental Flags available

The Tire Tread SDK currently includes the following experimental flags:

- Experimental_Continuous_Picture_Focus_Mode
