import 'package:flutter/material.dart';
import 'package:background_audio/background_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    BackgroundAudio.initialize(
      onPause: () {
        print("pausing!");
      },
      onPlay: () {
        print("playing!");
      }
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              RaisedButton(
                child: Text("Play"),
                onPressed: () {
                  BackgroundAudio.play(title: "title", url: "http://185.105.7.217:8015/Stream");
                },
              ),
              RaisedButton(
                child: Text("Pause"),
                onPressed: () {
                  BackgroundAudio.pause();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
