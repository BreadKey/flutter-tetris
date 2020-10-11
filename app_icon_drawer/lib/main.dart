import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tetris/models/direction.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/tetromino_renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final renderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          renderKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);

      final docsDir = (await getApplicationDocumentsDirectory()).path;

      File("$docsDir/app_icon.png").writeAsBytesSync(pngBytes);

      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: renderKey,
          child: AppIcon(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _capturePng,
        label: Text("Capture"),
      ),
    );
  }
}

class AppIcon extends StatelessWidget {
  AppIcon({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
      width: 256,
      height: 256,
      color: Colors.white,
      child: Transform.translate(
        offset: Offset(-32, 48),
        child: Stack(
          children: [
            TetrominoRenderer(TetrominoName.J,
                rotateCount: 3, kicks: [Direction.up]),
            TetrominoRenderer(
              TetrominoName.T,
              rotateCount: 2,
              kicks: [Direction.right, Direction.up],
            )
          ],
        ),
      ));
}
