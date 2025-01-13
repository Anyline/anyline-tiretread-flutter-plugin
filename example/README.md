# anyline_tire_tread_plugin_example

This Flutter plugin enables the integration of Anyline Tire Tread SDK features.

## Create .env file

- Navigate to path_to_plugin_root_folder/example
- Create .env file and add below line of code
> licenseKey="{REPLACE WITH YOUR LICENSE KEY}"

## How to run the example app

### Via Android Studio

Open up plugin root folder in Android Studio, update dependencies, select device to run on and run.

### Via command line (Terminal)

Run the following commands
`cd example` # navigate to example app directory
`flutter pub get` # update flutter dependencies
`flutter run -android` # run on Android
`flutter run -ios` # run on iOS
`flutter devices` # list connected devices, take note of ID of device you want to run
`flutter run -d DEVICE_ID` # run flutter example on specific device

