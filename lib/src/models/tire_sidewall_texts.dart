/// Localizable UI strings shown by the sidewall scanner overlay.
///
/// Mirrors the SDK's `TswScannerTexts`. Every field is optional: leave a field
/// `null` to keep the SDK's English default, or set it to override that one
/// string. Only non-null fields are sent across the method channel.
///
/// ```dart
/// final texts = TireSidewallTexts()
///   ..alignTire = 'Align the tire'
///   ..holdSteady = 'Hold steady';
/// ```
class TireSidewallTexts {
  /// Shown while the scanner is starting up. SDK default: "Initializing scanner".
  String? initializing;

  /// Shown when the tire must be aligned within the overlay.
  /// SDK default: "Align the tire within the overlay".
  String? alignTire;

  /// Shown when the user is too far from the tire. SDK default: "Move closer".
  String? moveCloser;

  /// Shown when the user is too close to the tire. SDK default: "Move away".
  String? moveAway;

  /// Shown when the device is at too steep an angle.
  /// SDK default: "Face tire more directly".
  String? faceTire;

  /// Shown when framing is good and capture can start.
  /// SDK default: "Ready to capture".
  String? ready;

  /// Shown while the capture is taken. SDK default: "Hold steady".
  String? holdSteady;

  /// Shown while the camera refocuses after capture. SDK default: "Focusing...".
  String? focusing;

  /// Shown while white balance calibrates after capture.
  /// SDK default: "Calibrating white balance...".
  String? calibratingWhiteBalance;

  /// Shown while exposure calibrates after capture.
  /// SDK default: "Calibrating exposure...".
  String? calibratingExposure;

  /// Shown when the scanner turns the torch on for a dark environment.
  /// SDK default: "Too dark, turn on lights.".
  String? tooDark;

  /// Serializes only the overridden (non-null) strings.
  Map<String, dynamic> toJson() => {
        if (initializing != null) 'initializing': initializing,
        if (alignTire != null) 'alignTire': alignTire,
        if (moveCloser != null) 'moveCloser': moveCloser,
        if (moveAway != null) 'moveAway': moveAway,
        if (faceTire != null) 'faceTire': faceTire,
        if (ready != null) 'ready': ready,
        if (holdSteady != null) 'holdSteady': holdSteady,
        if (focusing != null) 'focusing': focusing,
        if (calibratingWhiteBalance != null)
          'calibratingWhiteBalance': calibratingWhiteBalance,
        if (calibratingExposure != null)
          'calibratingExposure': calibratingExposure,
        if (tooDark != null) 'tooDark': tooDark,
      };
}
