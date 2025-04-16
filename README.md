

# Anyline Tire Tread Flutter Plugin

This Flutter plugin provides an interface to the Anyline Tire Tread SDK, allowing you to integrate tire tread scanning capabilities into your Flutter applications.

## Requirements
In order to use the Anyline Tire Tread SDK Flutter Plugin, please see to it that the following requirements are met:

### Android

#### Device
- Android 8.0 - Oreo - or newer (API level 26+)
- Decent camera functionality (recommended: ≥ 720p and adequate  **auto focus**)
- 'Flash' capability
- Stable internet connection

#### Environment
Your development/application environment is required to have at least the following tools and versions (or newer) available:

- JDK 17
- Gradle 8.1.0
    - id 'com.android.application' version '8.1.0' apply false
- Kotlin 1.9.0
    - id 'org.jetbrains.kotlin.android' version '1.9.0' apply false
- compileSdk 34
    - android { compileSdk 34 ...
- minSdk 26
    - ... minSdk 26 ...
- Compose Compiler 1.5.0
    - ... composeOptions { kotlinCompilerExtensionVersion = "1.5.0" } ...

### iOS
- iOS Version >= 16.4
- Stable internet connection
- 'Flash' capability

## How it works

The Anyline Tire Tread SDK processes scans asynchronously. Once a scan is completed, the SDK uploads and processes the scan data in the background, allowing integrators to benefit from this behavior.

After initiating and completing a scan, your application can continue with any desired workflow without needing to wait for immediate results. When you need to access the results, such as measurement data or heatmaps, simply query them using the `getResult` or `getHeatMap` methods with the relevant `measurementUUID`.

This design enhances the user experience by keeping the application responsive and separating the scanning process from result retrieval.

## Anyline Tire Tread Flutter Plugin Guide

In this guide, we want to show you how you can make the most out of Anyline Tire Tread using our Flutter plugin. Feel free to contact us if you feel that it is incomplete or particular sections need elaboration.

### Get an Anyline License

To be able to use the Flutter plugin you will have to get a license key by following the steps detailed in our  [documentation](https://documentation.anyline.com/main-component/license-key-generation.html).

### Install the Anyline Tire Tread Plugin

Add the following dependency to your `pubspec.yaml` :
```yaml dependencies:    
anyline_tire_tread_plugin: ^x.y.z  
 ```
### Add the Anyline Tire Tread SDK as dependency

To integrate the Anyline Tire Tread SDK into your Android project, follow these steps:

* Open your project in Android Studio.
* Locate the build.gradle file of your project. This file is typically found in the root directory of your project.
* Add the Anyline Maven registry to your repositories section. This allows your project to access the Anyline Tire Tread SDK from the specified Maven repository. Update your repositories block to include the Anyline Maven registry URL:
```bash
repositories {
    // ... your other repositories ...
    mavenCentral()
    // Anyline Maven registry
    maven { url "https://europe-maven.pkg.dev/anyline-ttr-sdk/maven" }
}
```
> **_NOTE:_**  Find more inforamtion about adding Anyline Tire Tread SDK as dependency [here](https://documentation.anyline.com/tiretreadsdk-component/latest/android/getting-started.html#add-the-anyline-tire-tread-sdk-as-dependency).

### Install via pub.dev

Install the package dependencies from the command line:  
```bash flutter pub get ```  
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
### Initialize the SDK

During app startup, before calling any other plugin method, initialize the Anyline Tire Tread SDK by calling the plugin object’s  `initialize` method, providing it with your license key:
```dart  
try {
    await tireTreadPlugin.initialize(licenseKey);
} catch (error) {    
    print("error initializing Anyline Tire Tread SDK: $error");
}  
```  
### Start scanning

With an instance of  `TireTreadPlugin`, call  `scan` on it with the config options:
```dart  
scanWithAnyline() async {  
 tireTreadPlugin.scan(options: ScanOptions());
}  
```  
### Audio Feedback
The Tire Tread Plugin can provide audio feedback to guide users through the scan process.

To make use of these audio feedbacks, your application needs to provide the audio files inside the below folders.
1. path_to_plugin_root_folder/example/ios/Resources for iOS
2. path_to_plugin_root_folder/example/android/app/src/main/assets for Android

The audio feedbacks (with their respective files names) on iOS/Android are played on:

Focus Point Found

```tiretread_focuspoint_found.wav```

Scan Started

```tiretread_sound_start.wav```

Scan Stopped

```tiretread_sound_stop.wav```

Phone too close to the Tire

```tiretread_sound_beep_too_close.wav```

Phone too distant from the Tire

```tiretread_sound_beep_too_far.wav```

The SDK only supports these file names, and the .wav extension.


### Configuring the scanning behavior

You can customize how the scanning behavior works by passing in a `ScanOptions` object to the `scan` call:

```dart
tireTreadPlugin.scan(options: ScanOptions());
```

A `ScanOptions` object, constructed without parameters, contains sensible defaults to help you get quickly started.

If you wish, you can also specify the scan speed (fast or slow), and measurement system (metric or imperial units) in this way:

```dart
var scanOptions = ScanOptions(measurementSystem: MeasurementSystem.Imperial, scanSpeed: ScanSpeed.Fast);
tireTreadPlugin.scan(options: scanOptions);
```

If you wish, you can also specify the tire width in this way:

```dart
var scanOptions = ScanOptions(tireWidth: 236);
tireTreadPlugin.scan(options: scanOptions);
```

Alternatively, you can provide a string containing the SDK's Tire Tread ScanView configuration JSON to the `ScanOptions` object, for example:

```dart
const configJSON = '{
  "scanSpeed": "Fast",
  "measurementSystem": "Metric",
  ...
}';

tireTreadPlugin.scan(options: ScanOptions(configFileContent: configJSON));
```

More information about the JSON configuration can be found here: https://documentation.anyline.com/tiretreadsdk-component/latest/scanconfiguration.html



## Handling the SDK’s events
Handling SDK's events with an instance of `TireTreadPlugin` call `onScanningEvent`.
```dart  
 tireTreadPlugin.onScanningEvent.listen((event) { 
   switch (event) {
     case ScanAborted(): 
       debugPrint('measurementUUID : ${event.measurementUUID}');
     case ScanProcessCompleted(): 
       debugPrint('measurementUUID : ${event.measurementUUID}'); 
       setState(() => _uuid = event.measurementUUID ?? ''); 
     case ScanFailed(): 
       debugPrint('error : ${event.error}');
       debugPrint('measurementUUID : ${event.measurementUUID}');
}
 });  
```  

## Results

### Obtaining the Measurement Results
After the upload of your scanned frames is completed (that is, the  `UploadCompletedEvent` ), your measurement results may still take a few seconds to become available. To fetch the results, call the function  `getResult(measurementUuid)`:
```dart  
TreadDepthResult? result = await tireTreadPlugin.getResult(measurementUUID:measurementUUID);  
```

## User Corrected Values and Comments

### User Comments
To send a comment on a measurement, use the `sendFeedbackComment` function of the TireTreadPlugin.
```dart
await tireTreadPlugin.sendFeedbackComment(measurementUUID: _uuid, comment: comment);
```

### User Corrected Region Values
To send user corrected region values, use the `sendTreadDepthResultFeedback` function from the TireTreadPlugin. The result feedback should be provided as a list of `TreadResultRegion`, ordered from left to right.

> **_IMPORTANT:_**  You can only provide feedback for the regions returned by the SDK in the `TreadDepthResult` object. 
> The values of all regions need be added to the list before sending the feedback.


The TreadResultRegion objects can be initialized with Millimeters or Inches, e.g.:
```dart
TreadResultRegion regionMm = TreadResultRegion.initMm(available: true,valueMm: 1.2);
TreadResultRegion regionInch = TreadResultRegion.initInch(available: true,valueInch: 0.047);

List<TreadResultRegion>  myCorrectedResults =  [regionMm, regionInch];

await tireTreadPlugin.sendTreadDepthResultFeedback(measurementUUID: _uuid, resultRegions: myCorrectedResults);
```

## Error Codes

| Error Code | Error Origin        | Error Message                                                                                                                                       |
|------------|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| 100        | Platform-native SDK | General Processing Error: Please try again or contact support, if this error persists.                                                              |
| 110        | Platform-native SDK | Bad Images: too fev images -> record for longer; images too blurry -> move device slower.                                                           |
| 111        | Platform-native SDK | Unexpected image Count: Server did not receive all send images.                                                                                     |
| 150        | Platform-native SDK | Processing Error: Measurement could not be processed, please try again. See the documentation for advice on how to perform successful measurements. |
| 1000       | Flutter Plugin      | Plugin Not Attached To Activity: The plugin has not been integrated with the main activity.                                                         |
| 1001       | Flutter Plugin      | SDK Initialization Failed: Tire Tread SDK could not be initialized                                                                                  |

## Analytics

### Heatmap
After the upload of your scanned frames is completed (that is, the  `UploadCompletedEvent` ), your heatmap result may still take a few seconds to become available. To fetch the heatmap, call the function  `getHeatMap(measurementUuid)`:
```dart  
String heatmap = await tireTreadPlugin.getHeatMap(measurementUUID:measurementUUID);  
```

## Experimental Flags (internal use only)

When a new TTR SDK feature is implemented, it’s sometimes put behind an experimental flag. This enables the engineering team to provide new features to you more quickly, while still being able to change feature APIs before they move to a stable release. The experimental flag is then removed once the feature moves to a stable release.

Using functionality that’s behind an experimental flag requires you to enable the flag, or flags, in your application.

You should always enable/disable the experimental flags before using the functionality provided by it. Changing flags in the middle of the process might result in unexpected behaviour.

> **_WARNING:_**   Consuming functionality that’s behind an experimental flag might result in unwanted behaviour in your application.

### Enabling flags
To enable an experimental flag in your project, use the `setExperimentalFlags` function of the TireTreadPlugin.
```dart  
await tireTreadPlugin.setExperimentalFlags(experimentalFlags:[ExperimentalFlags.ExperimentalContinuousPictureFocusMode, "Another_Flag_Name"]);  
```
> **_NOTE:_**   Trying to set a flag that does not exist will not produce any effect, and the flag will be ignored. You will not be notified.

### Removing flags
To remove all experimental flags from your project, use the `clearExperimentalFlags` function of the TireTreadPlugin.
```dart  
await tireTreadPlugin.clearExperimentalFlags();  
```

### Experimental Flags available
The Tire Tread SDK currently includes the following experimental flags:
- Experimental_Continuous_Picture_Focus_Mode




