import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The Maps SDK needs its key before any GMSMapView is created, which is
    // why this happens here rather than from Dart. The value comes from
    // MAPS_API_KEY in the gitignored Flutter/Maps.xcconfig, surfaced through
    // Info.plist — the key is never committed, matching how Android reads it
    // from local.properties.
    //
    // Left unset, the app still runs; maps render blank rather than crashing.
    if let key = Bundle.main.object(forInfoDictionaryKey: "MapsApiKey") as? String,
       !key.isEmpty, !key.hasPrefix("$(") {
      GMSServices.provideAPIKey(key)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
