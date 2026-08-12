import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "brain_adventure/narrator",
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "Narrator")!.messenger()
    )
    let synthesizer = AVSpeechSynthesizer()
    channel.setMethodCallHandler { call, result in
      if call.method == "speak",
         let args = call.arguments as? [String: Any],
         let text = args["text"] as? String {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ar")
        utterance.rate = 0.42
        synthesizer.speak(utterance)
        result(nil)
      } else if call.method == "stop" {
        synthesizer.stopSpeaking(at: .immediate)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
