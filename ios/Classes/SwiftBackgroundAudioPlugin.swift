import Flutter
import UIKit
import AVFoundation
import MediaPlayer

public class SwiftBackgroundAudioPlugin: NSObject, FlutterPlugin {

  static var assetPlaybackManager: AssetPlaybackManager!
  static var remoteCommandManager: RemoteCommandManager!
  
  fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

  override init() {
    super.init()
    
    SwiftBackgroundAudioPlugin.assetPlaybackManager = AssetPlaybackManager()

    SwiftBackgroundAudioPlugin.remoteCommandManager = RemoteCommandManager(assetPlaybackManager: SwiftBackgroundAudioPlugin.assetPlaybackManager)
    SwiftBackgroundAudioPlugin.remoteCommandManager.activatePlaybackCommands(true)

    let audioSession = AVAudioSession.sharedInstance()

    if #available(iOS 10, *) {
      do {
        try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
      }
      catch {
        print("An error occured setting the audio session category: \(error)")
      }
    }
            
    // Set the AVAudioSession as active.  This is required so that your application becomes the "Now Playing" app.
    do {
      try audioSession.setActive(true)
    }
    catch {
      print("An Error occured activating the audio session: \(error)")
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "background_audio", binaryMessenger: registrar.messenger())
    let instance = SwiftBackgroundAudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    SwiftBackgroundAudioPlugin.assetPlaybackManager.onPause = { () -> () in
      channel.invokeMethod("onPause", arguments: nil)
    }

    SwiftBackgroundAudioPlugin.assetPlaybackManager.onPlay = { () -> () in
      channel.invokeMethod("onPlay", arguments: nil)
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
      case "play":
        play(call: call, result: result)
        break;
      case "pause":
        pause(call: call, result: result)
        break;
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  func play(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
      let title = args["title"] as? String,
      let urlString = args["url"] as? String,
      let url = URL(string: urlString) {
      
      var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

      nowPlayingInfo[MPMediaItemPropertyTitle] = title

      nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
      
      SwiftBackgroundAudioPlugin.assetPlaybackManager.asset = AVAsset(url: url)
    } else {
      result(FlutterError.init(code: "bad args", message: nil, details: nil))
    }
  }

  func pause(call: FlutterMethodCall, result: @escaping FlutterResult) {
    SwiftBackgroundAudioPlugin.assetPlaybackManager.pause()
  }
}
