import Flutter
import UIKit

public final class InteractionFoundationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let player = NativeInteractionSoundPlayer { packageAssetPath in
      let assetKey = registrar.lookupKey(
        forAsset: packageAssetPath,
        fromPackage: "interaction_foundation"
      )
      let candidates = [
        Bundle.main.url(forResource: assetKey, withExtension: nil),
        Bundle.main.bundleURL
          .appendingPathComponent("Frameworks/App.framework/flutter_assets")
          .appendingPathComponent(assetKey),
        Bundle.main.bundleURL
          .appendingPathComponent("flutter_assets")
          .appendingPathComponent(assetKey),
      ]
      return candidates.compactMap { $0 }.first {
        FileManager.default.fileExists(atPath: $0.path)
      }
    }
    NativeInteractionFeedbackHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: NativeInteractionFeedbackService(soundPlayer: player)
    )
  }
}
