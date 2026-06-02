import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var flutterEngine: FlutterEngine?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Pre-warm Flutter engine to avoid VSync race condition
    flutterEngine = FlutterEngine(name: "app_engine")
    flutterEngine?.run()
    GeneratedPluginRegistrant.register(with: flutterEngine!)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
