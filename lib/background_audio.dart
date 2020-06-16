import 'package:flutter/services.dart';

class BackgroundAudio {
  static const MethodChannel _channel = const MethodChannel('background_audio');

  static void initialize({Function onPause, Function onPlay}) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPlay':
          if (onPlay != null) onPlay();
          break;
        case 'onPause':
          if (onPause != null) onPause();
          break;
        default:
          print("unknown method");
      }
    });
  }

  static void play({String url, String title}) {
    _channel.invokeMethod('play', {
      'url': url,
      'title': title,
    });
  }

  static void pause() {
    _channel.invokeMethod('pause');
  }
}
