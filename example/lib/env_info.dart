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
}
