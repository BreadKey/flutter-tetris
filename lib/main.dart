import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:tetris/dao/local/local_rank_dao.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/audio_manager.dart';
import 'package:tetris/retro_colors.dart';
import 'package:tetris/screens/tetris_game.dart';
import 'package:tetris/screens/tetris_screen.dart';

void main() {
  Injector.appInstance
      .registerSingleton<IAudioManager>(() => AudioManager());
  Injector.appInstance.registerSingleton<RankDao>(() => LocalRankDao());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: navyBlue,
      systemNavigationBarIconBrightness: Brightness.light));
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
      home: TetrisGame(),
    );
  }
}
