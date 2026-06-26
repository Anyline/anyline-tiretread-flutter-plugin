import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvInfo {
  static String runTimeLicenseKey = '';

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String? get licenseKey {
    return (runTimeLicenseKey.isNotEmpty)
        ? runTimeLicenseKey
        : dotenv.env['licenseKey'] ?? (throw AssertionError());
  }

  /// Client ID used by the Tire Sidewall (TSW) scanner. Set `sidewallClientId`
  /// in `.env`; empty when unset (the scan will then fail server-side).
  static String get sidewallClientId => dotenv.env['sidewallClientId'] ?? '';
}
