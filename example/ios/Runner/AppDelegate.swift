import Flutter
import UIKit
import AnylineTireTreadSdk
import anyline_tire_tread_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
