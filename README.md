

# Anyline Tire Tread Plugin

This Flutter plugin provides an interface to the Anyline Tire Tread SDK, allowing you to integrate tire tread scanning capabilities into your Flutter applications.

## Requirements
In order to use the Anyline Tire Tread SDK Flutter Plugin, please see to it that the following requirements are met:

### Android
- Android 8.0 - Oreo - or newer (API level 26+)
- Decent camera functionality (recommended: ≥ 720p and adequate  **auto focus**)
- 'Flash' capability
- Stable internet connection

### iOS
- iOS Version >= 16.4
- Stable internet connection
- 'Flash' capability

## Anyline Tire Tread Plugin Guide

In this guide, we want to show you how you can make the most out of Anyline Tire Tread using our Flutter plugin. Feel free to contact us if you feel that it is incomplete or particular sections need elaboration.

### Get an Anyline License

To be able to use the Flutter plugin you will have to get a license key by following the steps detailed in our  [documentation](https://documentation.anyline.com/main-component/license-key-generation.html).

**_NOTE:_**  
License <> Bundle Identifier  
Every license is bound to a  **Bundle Identifier**. If you change your Bundle Identifier, you will require a new license. This also ensures that your license key cannot be used in any other application.

### Install the Anyline Tire Tread Plugin

Add the following dependency to your `pubspec.yaml` :
```yaml dependencies:    
anyline_tire_tread_plugin: ^1.0.0   
 ```  
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
 tireTreadPlugin.scan({});
}  
```  

## Handling the SDK’s events
Handling SDK's events with an instance of `TireTreadPlugin` call `onScanningEvent`.
```dart  
 tireTreadPlugin.onScanningEvent.listen((event) { 
   switch (event) { 
     case ScanningAborted(): 
       debugPrint('measurementUUID : ${event.measurementUUID}');
     case UploadAbortedEvent(): 
       debugPrint('measurementUUID : ${event.measurementUUID}'); 
     case UploadCompletedEvent(): 
       debugPrint('measurementUUID : ${event.measurementUUID}'); 
       setState(() => _uuid = event.measurementUUID ?? ''); 
     case UploadFailedEvent(): 
       debugPrint('measurementUUID : ${event.error}');
   }
 });  
```  

## Results

### Obtaining the Measurement Results
After the upload of your scanned frames is completed (that is, the  `UploadCompletedEvent` ), your measurement results may still take a few seconds to become available. To fetch the results, call the function  `getResult(measurementUuid)`:
```dart  
String result = await tireTreadPlugin.getResult(measurementUUID:measurementUUID);  
```

## Analytics

### Heatmap
After the upload of your scanned frames is completed (that is, the  `UploadCompletedEvent` ), your heatmap result may still take a few seconds to become available. To fetch the heatmap, call the function  `getHeatMap(measurementUuid)`:
```dart  
String heatmap = await tireTreadPlugin.getHeatMap(measurementUUID:measurementUUID);  
```