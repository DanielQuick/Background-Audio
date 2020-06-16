package com.quickdevelopment.background_audio

import androidx.annotation.NonNull;
import android.media.MediaPlayer
import android.media.AudioManager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** BackgroundAudioPlugin */
public class BackgroundAudioPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mediaPlayer : MediaPlayer

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val mediaPlayer = MediaPlayer()
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "background_audio")
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val mediaPlayer = MediaPlayer()
      val channel = MethodChannel(registrar.messenger(), "background_audio")
      channel.setMethodCallHandler(BackgroundAudioPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "play") {
      play(call, result)
    } else if (call.method == "pause") {
      pause(call, result)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  fun play(@NonNull call: MethodCall, @NonNull result: Result) {
    val arguments = call.arguments as HashMap<String,Any>;
    var title = ""
    var urlString = ""
    if(arguments.containsKey("title")) {
      title = arguments["title"] as String
    }
    if(arguments.containsKey("url")) {
      urlString = arguments["url"] as String
    }

    try {
      mediaPlayer.apply {
        setAudioStreamType(AudioManager.STREAM_MUSIC)
        setDataSource(urlString)
        prepareAsync() // might take long! (for buffering, etc)
      }
      mediaPlayer.setOnPreparedListener(object: MediaPlayer.OnPreparedListener {
        override fun onPrepared(mediaPlayer: MediaPlayer) {
          mediaPlayer.start()
        }
      })
    } catch (e : Exception) {

    }
  }

  fun pause(@NonNull call: MethodCall, @NonNull result: Result) {
    mediaPlayer.pause()
  }
}
