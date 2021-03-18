import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injector/injector.dart';
import 'package:tetris/dao/local/local_rank_dao.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/screens/keyboard_listener.dart';
import 'package:tetris/screens/tetris_screen.dart';
import 'package:tetris/web/audio_manager.dart';

void main() {
  Injector.appInstance.registerSingleton<AudioManager>(
      () => kIsWeb ? WebAudioManager() : AudioManagerImpl());
  Injector.appInstance.registerSingleton<RankDao>(() => LocalRankDao());
  runApp(TetrisApp());
}

class TetrisApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Pixel",
        ),
        home: KeyboardListener(child: TetrisScreen()));
  }
}
