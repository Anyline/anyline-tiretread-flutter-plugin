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

* `UploadAborted` event has been removed and consolidated into `ScanAborted` to simplify communication with the app.
* `UploadCompleted` event has been removed and consolidated into `ScanProcessCompleted` to simplify communication with the app.
* `UploadFailed` event has been removed and consolidated into `ScanFailed` to simplify communication with the app.

## 0.0.1

* Initial stable release of the Anyline Tire Tread Flutter Plugin.

## 0.0.1-alpha.3

* Fix pub.dev scores.

## 0.0.1-alpha.2

* Fix pub.dev scores.

## 0.0.1-alpha.1

* Initial alpha release of the Anyline Tire Tread Flutter Plugin. Please see the included Readme.md for details and usage instructions.